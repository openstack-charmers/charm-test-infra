#!/bin/bash -e
# Example:  Juju Controller on MAAS Provider and Example Model Setup

# novarc values for other clouds are used to construct model/controller names
# The undercloud novarc has no other purpose here.
# 
# Added support for bootstrapping s390x
# $OPENSTACK_PUBLIC_IP is set by jenkins openstack slave plugin

set -x 

if [ -z "${OS_PROJECT_NAME}" ]; then
  echo "ERROR: Have you sourced novarc?"
  exit 1
fi

: ${CLOUD_NAME:="${OS_PROJECT_NAME}-maas"}
: ${CONTROLLER_NAME:="${OS_PROJECT_NAME}-${CLOUD_NAME}"}
: ${MODEL_NAME:="${OS_PROJECT_NAME:0:12}-${CLOUD_NAME}"}
: ${BOOTSTRAP_CONSTRAINTS:="arch=amd64 tags=dell"}
: ${BOOTSTRAP_PLACEMENT:=""}
: ${MODEL_CONSTRAINTS:="arch=amd64 tags=dell"}
: ${BOOTSTRAP_LOCAL:=""}

if [[ ${CLOUD_NAME} == *"390"* ]]; then
        S390X=true
        BOOTSTRAP_CONSTRAINTS=''
        MODEL_CONSTRAINTS=''
else
        S390X=false
fi

# XXX: Must edit credentials.yaml locally in advance to populate oauth(s)
if [[ ${S390X} != true ]]; then
juju add-cloud --replace $CLOUD_NAME juju-configs/clouds.yaml
juju add-credential --replace $CLOUD_NAME -f juju-configs/credentials.yaml
fi

if [[ ${S390X} == 'true' ]] || [[ ${BOOTSTRAP_LOCAL} == 'true' ]]; then
        BOOT_NAME="manual/${OPENSTACK_PUBLIC_IP}"
else
        BOOT_NAME=$CLOUD_NAME
fi

juju switch $CONTROLLER_NAME ||\
    time juju bootstrap --bootstrap-constraints "$BOOTSTRAP_CONSTRAINTS" \
                        --auto-upgrade=false \
                        --model-default=juju-configs/model-default.yaml \
                        --config=juju-configs/controller-default.yaml \
                        $BOOTSTRAP_PLACEMENT \
                        $BOOT_NAME $CONTROLLER_NAME

if [[ ${S390X} == 'true' ]] ; then
juju switch ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    juju add-model $MODEL_NAME manual \
                        --config=juju-configs/model-default.yaml
else
juju switch ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    juju add-model $MODEL_NAME $CLOUD_NAME \
                        --config=juju-configs/model-default.yaml
# Ensure the model has contstraints set. Currently this must be done on every model due to bug:
#     https://bugs.launchpad.net/juju/+bug/1653813
juju set-model-constraints -m $MODEL_NAME "$MODEL_CONSTRAINTS"
fi

juju status --color
