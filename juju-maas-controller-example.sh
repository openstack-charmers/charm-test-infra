#!/bin/bash -e
# Example:  Juju Controller on MAAS Provider and Example Model Setup

# novarc values for other clouds are used to construct model/controller names
# The undercloud novarc has no other purpose here.
if [ -z "${OS_PROJECT_NAME}" ]; then
  echo "ERROR: Have you sourced novarc?"
  exit 1
fi

set -ux

: ${CLOUD_NAME:="${OS_PROJECT_NAME}-maas"}
: ${CONTROLLER_NAME:="${OS_PROJECT_NAME}-${CLOUD_NAME}"}
: ${MODEL_NAME:="${OS_PROJECT_NAME:0:12}-${CLOUD_NAME}"}
: ${BOOTSTRAP_CONSTRAINTS:="arch=amd64 tags=dell"}
: ${BOOTSTRAP_PLACEMENT:=""}
: ${MODEL_CONSTRAINTS:="arch=amd64 tags=dell"}

# XXX: Must edit credentials.yaml locally in advance to populate oauth(s)
juju add-cloud --replace $CLOUD_NAME --local juju-configs/clouds.yaml
juju add-credential --replace $CLOUD_NAME -f juju-configs/credentials.yaml

juju switch $CONTROLLER_NAME ||\
    time juju bootstrap --bootstrap-constraints "$BOOTSTRAP_CONSTRAINTS" \
                        --constraints "$MODEL_CONSTRAINTS" \
                        --auto-upgrade=false \
                        --model-default=juju-configs/model-default.yaml \
                        --config=juju-configs/controller-default.yaml \
                        $BOOTSTRAP_PLACEMENT \
                        $CLOUD_NAME $CONTROLLER_NAME

juju show-model ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    juju add-model $MODEL_NAME $CLOUD_NAME \
                        --config=juju-configs/model-default.yaml

# Ensure the model has contstraints set. Currently this must be done on every model due to bug:
#     https://bugs.launchpad.net/juju/+bug/1653813
juju set-model-constraints -m $MODEL_NAME "$MODEL_CONSTRAINTS"

juju status --color

# EXAMPLE OUTPUT: results with serverstack osci user
#
# jenkins@juju-10f68a-osci-15:~/temp/charm-test-infra$ juju clouds
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
# ruxton-maas        0                 maas        Metal As A Service
#
# jenkins@juju-10f68a-osci-15:~/temp/charm-test-infra$ juju controllers
# Use --refresh flag with this command to see the latest information.
#
# Controller         Model             User   Access     Cloud/Region             Models  Machines    HA  Version
# auto-osci-lb00     -                 admin  superuser  serverstack/serverstack       2         1  none  2.1.2
# osci-ruxton-maas*  osci-ruxton-maas  admin  superuser  ruxton-maas                   2         1  none  2.1.2
#
# jenkins@juju-10f68a-osci-15:~/temp/charm-test-infra$ juju models
# Controller: osci-ruxton-maas
#
# Model              Cloud/Region  Status     Machines  Cores  Access  Last connection
# controller         ruxton-maas   available         1      8  admin   just now
# default            ruxton-maas   available         0      -  admin   10 hours ago
# osci-ruxton-maas*  ruxton-maas   available        19     56  admin   12 seconds ago
