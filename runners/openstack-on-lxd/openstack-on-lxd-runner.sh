#!/bin/bash -ex
#
# A one-shot runner for exercising the 'openstack-on-lxd' scenario against a
# remote machine which can afford to be thrashed and trashed.
#
# Presumes, by whatever means, that you have a remotely-accessible, freshly-
# installed Xenial machine online, wired and ready to accept commands via ssh.
#
# WARNING: This should be run only against ephemeral, non-critical machines,
# as it will forcefully re-use (erase) disks for zpools.  Do not use for
# local developer machine deployment such as your laptop.  It will not end well.



[[ -z "$REMOTE" ]] && export REMOTE=10.245.168.39  # igor mitaka
[[ -z "$BUNDLE_FILE" ]] && export BUNDLE_FILE="bundle-mitaka.yaml"

#[[ -z "$REMOTE" ]] && export REMOTE=10.245.168.57   # egede Newton
#[[ -z "$BUNDLE_FILE" ]] && export BUNDLE_FILE="bundle-newton.yaml"

#[[ -z "$REMOTE" ]] && export REMOTE=10.245.168.56   # couder mitaka ext-port eth1
#[[ -z "$BUNDLE_FILE" ]] && export BUNDLE_FILE="bundle-newton.yaml"



[[ -z "$OS_CLIENT_UCA" ]] && export OS_CLIENT_UCA="newton"
[[ -z "$REMOTE_WORKSPACE" ]] && export REMOTE_WORKSPACE="/home/ubuntu/WORKSPACE"
[[ -z "$REMOTE_USER" ]] && export REMOTE_USER=ubuntu
[[ -z "$ZPOOL_NAME" ]] && export ZPOOL_NAME=pool0
[[ -z "$ZPOOL_DEVS" ]] && export ZPOOL_DEVS="/dev/sdb /dev/sdc"
[[ -z "$JUJU_PPA" ]] && export JUJU_PPA="ppa:juju/devel"

export JUJU_WAIT_CMD="time $REMOTE_WORKSPACE/juju-wait/juju-wait -v"
export NOVARC_CMD=". $REMOTE_WORKSPACE/openstack-on-lxd/novarc"
export SSH_OPTS="-oStrictHostKeyChecking=no"
export PKGS="$(tr \"\\n\" ' '<packages.txt)"

function rexec() {
  ssh -t $SSH_OPTS $REMOTE_USER@$REMOTE "$1"
}


# SAFEGUARD HUMANS
if [[ -z "$WORKSPACE" ]]; then
  set +x
  echo -e "\nWARNING:"
  echo -e "  This script is not intended to be used by humans.  It is intended to be used by
  CI automation for validation of bundles against an ephemeral machine, where complete
  destruction and dangerous behavior is OK.

  Please see the OpenStack Charm Guide (openstack-on-lxd section) for the procedure which is
  intended for developers and other humans."
  exit 1
fi


# CHECK CONNECTION, TRUST THE HOST
ssh-keygen -f "$HOME/.ssh/known_hosts" -R $REMOTE ||:
rexec "uname -a"


# INSTALL PACKAGES
mkdir -vp $WORKSPACE
if [[ -z "$(find $WORKSPACE -type f -name apt.touch -mmin +90)" ]]; then
rexec << EOF_PACKAGE_INSTALL
  mkdir -vp $REMOTE_WORKSPACE
  sudo add-apt-repository $JUJU_PPA -y
  sudo add-apt-repository cloud-archive:${OS_CLIENT_UCA} -y
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install $PKGS -y
  juju version
EOF_PACKAGE_INSTALL
touch $WORKSPACE/apt.touch
fi


# FETCH REPOS
rexec << EOF_CLONE_REPOS
  mkdir -vp $REMOTE_WORKSPACE
  git clone https://github.com/openstack-charmers/openstack-on-lxd $REMOTE_WORKSPACE/openstack-on-lxd
  (cd $REMOTE_WORKSPACE/openstack-on-lxd && git checkout add-ocata)
  git clone https://github.com/openstack-charmers/bot-control $REMOTE_WORKSPACE/bot-control
  git clone https://git.launchpad.net/juju-wait $REMOTE_WORKSPACE/juju-wait ||:
EOF_CLONE_REPOS


# TUNE SYSTEM
rexec << EOF_SYSCTL_TUNE
  echo fs.inotify.max_queued_events=1048576 | sudo tee -a /etc/sysctl.conf
  echo fs.inotify.max_user_instances=1048576 | sudo tee -a /etc/sysctl.conf
  echo fs.inotify.max_user_watches=1048576 | sudo tee -a /etc/sysctl.conf
  echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
EOF_SYSCTL_TUNE


# CREATE ZPOOL
rexec << EOF_ZPOOL_CREATE
  sudo zpool status $ZPOOL_NAME || sudo zpool create pool0 $ZPOOL_DEVS -f
  sudo zpool list
  sudo zpool iostat
EOF_ZPOOL_CREATE


# PREP LXD
rexec << EOF_LXD_INIT
  sudo lxd init --auto --storage-backend zfs --storage-pool $ZPOOL_NAME
  lxc config get storage.zfs_pool_name
  lxc profile create juju-default
  brctl show
  lxc list
EOF_LXD_INIT

rexec "sudo debconf-communicate << EOF
set lxd/setup-bridge true
set lxd/bridge-domain lxd
set lxd/bridge-name lxdbr0
set lxd/bridge-ipv4 true
set lxd/bridge-ipv4-address 10.0.8.1
set lxd/bridge-ipv4-dhcp-first 10.0.8.32
set lxd/bridge-ipv4-dhcp-last 10.0.8.254
set lxd/bridge-ipv4-dhcp-leases 222
set lxd/bridge-ipv4-netmask 24
set lxd/bridge-ipv4-nat true
set lxd/bridge-ipv6 false
EOF
sudo rm -fv /etc/default/lxd-bridge
sudo dpkg-reconfigure lxd --frontend=noninteractive
sudo lxc finger"

rexec << EOF_LXD_PROFILES
  cat $REMOTE_WORKSPACE/openstack-on-lxd/lxd-profile.yaml | lxc profile edit juju-default
  lxc profile list
  lxc profile show juju-default
EOF_LXD_PROFILES

rexec << EOF_LXD_CHECK
  #lxc stop autotemptest ||:
  #lxc delete autotemptest ||:
  lxc launch -p default ubuntu:16.04 autotemptest
  lxc exec autotemptest -- sh -c "uname -a"
EOF_LXD_CHECK


# JUJU BOOTSTRAP AND DEPLOY
rexec << EOF_JUJU_BOOTSTRAP
  juju bootstrap --config $REMOTE_WORKSPACE/openstack-on-lxd/config.yaml localhost lxd
  $JUJU_WAIT_CMD
EOF_JUJU_BOOTSTRAP

rexec << EOF_JUJU_DEPLOY_BUNDLE
  juju deploy $REMOTE_WORKSPACE/openstack-on-lxd/$BUNDLE_FILE
  $JUJU_WAIT_CMD
EOF_JUJU_DEPLOY_BUNDLE


# CREATE GLANCE IMAGE
REMOTE_ARCH="$(rexec 'uname -p' | tr -d '\r')"
case "$REMOTE_ARCH" in
  "aarch64")
      IMAGE_URL="http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-arm64-uefi1.img"
      IMAGE_PROPERTY_STRING="--property hw_firmware_type=uefi"
      ;;
  *)
      IMAGE_URL="http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-${IMAGE_ARCH}-disk1.img"
      ;;
esac

rexec << EOF_IMAGE_CREATE
  $NOVARC_CMD
  curl $IMAGE_URL | openstack image create --public --container-format=bare --disk-format=qcow2 $IMAGE_PROPERTY_STRING xenial
EOF_IMAGE_CREATE


# CONFIGURE TENANT NETWORK
rexec << EOF_NETWORK_CONFIGURE
  $NOVARC_CMD
  cd $REMOTE_WORKSPACE/openstack-on-lxd
  ./neutron-ext-net -g 10.0.8.1 -c 10.0.8.0/24 -f 10.0.8.201:10.0.8.254 ext_net
  ./neutron-tenant-net -t admin -r provider-router -N 10.0.8.1 internal 192.168.20.0/24
  cd
EOF_NETWORK_CONFIGURE


# ADD NOVA KEYPAIR
rexec << EOF_KEYPAIR_CREATE
  $NOVARC_CMD
  ssh-keygen -t rsa -b 4096 -q -N '' -f /home/${REMOTE_USER}/.ssh/id_rsa
  openstack keypair create --public-key /home/${REMOTE_USER}/.ssh/id_rsa.pub mykey
EOF_KEYPAIR_CREATE


# ADD NOVA FLAVORS
rexec << EOF_FLAVOR_CREATE
  $NOVARC_CMD
  openstack flavor create --public --ram 512 --disk 1 --ephemeral 0 --vcpus 1 m1.tiny
  openstack flavor create --public --ram 1024 --disk 20 --ephemeral 40 --vcpus 1 m1.small
  openstack flavor create --public --ram 2048 --disk 40 --ephemeral 40 --vcpus 2 m1.medium
  openstack flavor create --public --ram 8192 --disk 40 --ephemeral 40 --vcpus 4 m1.large
  openstack flavor create --public --ram 16384 --disk 80 --ephemeral 40 --vcpus 8 m1.xlarge ||:
EOF_FLAVOR_CREATE


# CREATE NOVA INSTANCE
rexec << EOF_INSTANCE_CREATE
  $NOVARC_CMD
  openstack server create --image xenial --flavor m1.small --key-name mykey --wait --nic net-id=\$(neutron net-list | grep internal | awk '{ print \$2 }') openstack-on-lxd-ftw
  $REMOTE_WORKSPACE/openstack-on-lxd/float-all
EOF_INSTANCE_CREATE


#
# NOTE(beisner): confirmed good through here, 1-shot Newton and Mitaka
# ============================================================================


# ADD NOVA SECGROUPS
#rexec << EOF_SECGROUP_CREATE
#  $NOVARC_CMD
#  neutron security-group-rule-create --protocol icmp --direction ingress \$(openstack security group list | grep default | awk '{ print \$2 }')
#  neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress \$(openstack security group list | grep default | awk '{ print \$2 }')
#EOF_SECGROUP_CREATE


# TODO: launch nova instances

# TODO: confirm connectivity to nova instances

# TODO: destroy model

# TODO: destroy controller
