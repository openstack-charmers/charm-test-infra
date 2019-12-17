#!/bin/bash -e
# OpenStack Tenant User - Juju Controller and Example Model Setup

if [ -z "${OVERCLOUD_NAME}" ]; then
  echo "ERROR: Does not appear that you are running this via mosci"
  echo '$OVERCLOUD_NAME not set'
fi
if [ -z "${OS_AUTH_URL}" ]; then
  echo "ERROR: Have you sourced openrc?"
  exit 1
fi

set -ux

: ${OS_SERIES:="bionic"}
CLOUD_NAME="overcloud"
: ${CONTROLLER_NAME:="${OS_PROJECT_NAME}-${CLOUD_NAME}"}
: ${MODEL_NAME:="${OS_PROJECT_NAME:0:12}"}
: ${NETWORK_ID:=$(openstack network list | awk /private/'{ print $2 }')}
: ${BOOTSTRAP_CONSTRAINTS:="arch=${ARCH}"}
: ${MODEL_CONSTRAINTS:="arch=${ARCH}"}
: ${WORKSPACE:="/tmp"}


grep serverstack-keystone juju-configs/clouds.yaml && sed -e "s#http://serverstack-keystone:5000/v3#${OS_AUTH_URL}#g" -i juju-configs/clouds.yaml ||:

if [ ! -d ~/simplestreams/images ] ; then
        mkdir -p ~/simplestreams/images
fi

IMAGE_ID=$(openstack image list | grep -v cirros | awk /bionic/'{print $2}')

#juju switch ${OVERCLOUD_NAME}:${OVERCLOUD_NAME}
CONMOD="${OVERCLOUD_NAME}-${OVERCLOUD_NAME}"
juju metadata generate-image -d ~/simplestreams -i ${IMAGE_ID} -s ${OS_SERIES} -r RegionOne -u $OS_AUTH_URL -a ${ARCH} -c ${OVERCLOUD_NAME}



# Tenant may need to do this, but disabling here, as the undercloud that required it is WIP.
#     https://bugs.launchpad.net/bugs/1680787
# openstack network set --enable-port-security ${OS_PROJECT_NAME}_admin_net

# Tenant may also need to do this as a work-around while the exact secgroup configuration is determined.
# openstack security group rule create default --ingress --protocol gre
# openstack security group rule create default --ingress --protocol icmp
# openstack security group rule create default --ingress --protocol tcp --dst-port 1:65535
# openstack security group rule create default --ingress --protocol udp --dst-port 1:65535
# openstack security group rule create default --egress  --protocol gre
# openstack security group rule create default --egress  --protocol icmp
# openstack security group rule create default --egress --protocol tcp --dst-port 1:65535
# openstack security group rule create default --egress --protocol udp --dst-port 1:65535

juju controller-config features="[multi-cloud]"
#juju add-cloud --replace $CLOUD_NAME juju-configs/clouds.yaml
juju update-cloud $CLOUD_NAME -f juju-configs/clouds.yaml --client

juju autoload-credentials <<EOF
1
overcloud
q
EOF

juju switch $CONTROLLER_NAME ||\
    time juju bootstrap --bootstrap-constraints "$BOOTSTRAP_CONSTRAINTS" \
                        --auto-upgrade=false \
                        --model-default=juju-configs/model-default-mosci-overcloud.yaml \
                        --config=juju-configs/controller-default.yaml \
                        --metadata-source=~/simplestreams/ \
                        --config network=$NETWORK_ID \
                        $CLOUD_NAME $CONTROLLER_NAME

juju model-defaults network=$NETWORK_ID

juju switch ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    juju add-model $MODEL_NAME $CLOUD_NAME \
                        --config=juju-configs/model-default-mosci-overcloud.yaml \
                        --config network=$NETWORK_ID

# Ensure the model has contstraints set. Currently this must be done on every model due to bug:
#     https://bugs.launchpad.net/juju/+bug/1653813
#juju models --format json &> $WORKSPACE/juju-models-before-constraints.json.txt
juju set-model-constraints -m $MODEL_NAME "$MODEL_CONSTRAINTS"

juju controllers
juju models
juju status --color

# EXAMPLE OUTPUT: results with serverstack osci user
#
# ubuntu@osci-bastion:~/deploy/charm-test-infra⟫ juju clouds
# Cloud        Regions  Default        Type        Description
# aws               14  us-east-1      ec2         Amazon Web Services
# aws-china          1  cn-north-1     ec2         Amazon China
# aws-gov            1  us-gov-west-1  ec2         Amazon (USA Government)
# azure             24  centralus      azure       Microsoft Azure
# azure-china        2  chinaeast      azure       Microsoft Azure China
# cloudsigma         5  hnl            cloudsigma  CloudSigma Cloud
# google             6  us-east1       gce         Google Cloud Platform
# joyent             6  eu-ams-1       joyent      Joyent Cloud
# rackspace          6  dfw            rackspace   Rackspace Cloud
# localhost          1  localhost      lxd         LXD Container Hypervisor
# serverstack        1  serverstack    openstack   Openstack Cloud

# ubuntu@osci-bastion:~/deploy/charm-test-infra⟫ juju controllers
# Use --refresh flag with this command to see the latest information.
#
# Controller         Model  User   Access     Cloud/Region             Models  Machines    HA  Version
# osci-serverstack*  osci   admin  superuser  serverstack/serverstack       2         1  none  2.1.2

# ubuntu@osci-bastion:~/deploy/charm-test-infra⟫ juju models
# Controller: osci-serverstack
#
# Model       Cloud/Region             Status     Machines  Cores  Access  Last connection
# controller  serverstack/serverstack  available         1      4  admin   just now
# default     serverstack/serverstack  available         0      -  admin   23 minutes ago
# osci*       serverstack/serverstack  available         0      -  admin   23 minutes ago
