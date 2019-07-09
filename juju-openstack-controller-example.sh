#!/bin/bash -e
# OpenStack Tenant User - Juju Controller and Example Model Setup

if [ -z "${OS_PROJECT_NAME}" ]; then
  echo "ERROR: Have you sourced novarc?"
  exit 1
fi

set -ux

: ${CLOUD_NAME:="$OS_REGION_NAME"}
: ${CONTROLLER_NAME:="${OS_PROJECT_NAME}-${CLOUD_NAME}"}
: ${MODEL_NAME:="${OS_PROJECT_NAME:0:12}"}
: ${NETWORK_ID:=$(openstack network list | awk "/${OS_PROJECT_NAME}_admin_net/"'{ print $2 }')}
: ${BOOTSTRAP_CONSTRAINTS:="virt-type=kvm cores=4 mem=8G"}
: ${MODEL_CONSTRAINTS:="virt-type=kvm"}
: ${WORKSPACE:="/tmp"}


grep ${CLOUD_NAME}-keystone juju-configs/clouds.yaml && sed -e "s#http://${CLOUD_NAME}-keystone:5000/v3#${OS_AUTH_URL}#g" -i juju-configs/clouds.yaml ||:

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

juju add-cloud --replace $CLOUD_NAME juju-configs/clouds.yaml

juju switch $CONTROLLER_NAME && juju show-controller $CONTROLLER_NAME ||\
    time juju bootstrap --bootstrap-constraints "$BOOTSTRAP_CONSTRAINTS" \
                        --constraints "$MODEL_CONSTRAINTS" \
                        --auto-upgrade=false \
                        --model-default=juju-configs/model-default-serverstack.yaml \
                        --config=juju-configs/controller-default.yaml \
                        --config network=$NETWORK_ID \
                        $CLOUD_NAME/$OS_REGION_NAME $CONTROLLER_NAME

juju model-defaults network=$NETWORK_ID

juju show-model ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    juju add-model $MODEL_NAME $CLOUD_NAME \
                        --config=juju-configs/model-default-serverstack.yaml \
                        --config network=$NETWORK_ID

# Ensure the model has contstraints set. Currently this must be done on every model due to bug:
#     https://bugs.launchpad.net/juju/+bug/1653813
juju models --format json &> $WORKSPACE/juju-models-before-constraints.json.txt
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
