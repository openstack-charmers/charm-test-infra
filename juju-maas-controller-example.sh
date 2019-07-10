#!/bin/bash -uex
# Example:  Juju Controller on MAAS Provider and Example Model Setup
# ============================================================================
# Expects CLOUD_NAME to be set in advance, and CLOUD_NAME should match
# one of the clouds defined in the clouds.yaml and credentials.yaml files.
# Further, you must update juju-configs/credentials.yaml with your MAAS
# oauth key prior to usage.
#
# For example usage, see:  virt-controller-icarus-example.sh

: ${CONTROLLER_NAME:="${CLOUD_NAME}"}
: ${MODEL_NAME:="default"}
: ${BOOTSTRAP_CONSTRAINTS:="arch=amd64 tags=dell"}
: ${BOOTSTRAP_PLACEMENT:=""}
: ${MODEL_CONSTRAINTS:="arch=amd64 tags=dell"}

juju add-cloud $CLOUD_NAME juju-configs/clouds.yaml ||\
    juju update-cloud $CLOUD_NAME -f juju-configs/clouds.yaml

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

# EXAMPLE OUTPUT:
# ubuntu@foo-bastion:~/charm-test-infraâŸ« juju clouds
# Cloud           Regions  Default          Type        Description
# aws                  15  us-east-1        ec2         Amazon Web Services
# aws-china             2  cn-north-1       ec2         Amazon China
# aws-gov               1  us-gov-west-1    ec2         Amazon (USA Government)
# azure                27  centralus        azure       Microsoft Azure
# azure-china           2  chinaeast        azure       Microsoft Azure China
# cloudsigma           12  dub              cloudsigma  CloudSigma Cloud
# google               18  us-east1         gce         Google Cloud Platform
# joyent                6  us-east-1        joyent      Joyent Cloud
# oracle                4  us-phoenix-1     oci         Oracle Cloud Infrastructure
# oracle-classic        5  uscom-central-1  oracle      Oracle Cloud Infrastructure Classic
# rackspace             6  dfw              rackspace   Rackspace Cloud
# localhost             1  localhost        lxd         LXD Container Hypervisor
# icarus-maas           0                   maas        Metal As A Service
#
# ubuntu@foo-bastion:~/charm-test-infraâŸ« juju controllers
# Use --refresh option with this command to see the latest information.
#
# Controller    Model    User   Access     Cloud/Region  Models  Nodes    HA  Version
# icarus-maas*  default  admin  superuser  icarus-maas        2      1  none  2.6.6
#
# ubuntu@foo-bastion:~/charm-test-infraâŸ« juju models
# Controller: icarus-maas
#
# Model       Cloud/Region  Type  Status     Machines  Cores  Access  Last connection
# controller  icarus-maas   maas  available         1      2  admin   just now
# default*    icarus-maas   maas  available         0      -  admin   2 seconds ago
