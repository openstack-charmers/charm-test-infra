#!/bin/bash -ex
#
# An example test runner for ARM64 OpenStack-Base bundle deploy on MAAS
#
# Default environment variable values represent a specific lab and must
# be adjusted to suit.  These default values will only take effect if an
# environment variable is not already set.

## Per-job env vars
: ${UBUNTU_RELEASE:="xenial"}
: ${OPENSTACK_RELEASE:="ocata"}
: ${BUNDLE_STABILITY:="development"}
: ${BUNDLE_SCENARIO:="openstack-base"}

## Tool env vars
: ${JUJU_WAIT_CODIR:="$HOME/temp/juju-wait"}
: ${OCT_CODIR:="$HOME/temp/openstack-charm-testing"}
: ${BC_CODIR:="$HOME/temp/bot-control"}
: ${BUNDLE_CODIR:="$HOME/temp/openstack-bundles"}
: ${CTI_CODIR:="$HOME/temp/charm-test-infra"}

: ${JUJU_WAIT_CMD:="time timeout 60m $JUJU_WAIT_CODIR/juju-wait -v"}
: ${CONFIGURE_CMD:="./configure arm64"}

# Cloud env vars
: ${CLOUD_NAME:="ruxton-maas"}

## Controller env vars
: ${CONTROLLER_NAME:="${CLOUD_NAME}-arm64"}
: ${BOOTSTRAP_CONSTRAINTS:="arch=arm64 tags=gigabyte"}

## Model env vars
: ${MODEL_NAME:="${BUNDLE_SCENARIO}-${UBUNTU_RELEASE}-${OPENSTACK_RELEASE}-${BUNDLE_STABILITY}"}
: ${MODEL_CONSTRAINTS:="$BOOTSTRAP_CONSTRAINTS"}

## Bundle env vars
: ${DATA_PORT_INTERFACE:="enP2p1s0f2"}
: ${REF_BUNDLE_FILE:="${BUNDLE_STABILITY}/${BUNDLE_SCENARIO}-${UBUNTU_RELEASE}-${OPENSTACK_RELEASE}/bundle.yaml"}
: ${BUNDLE_FILE:="$(mktemp)"}

## Fixture env vars
: ${TEST_IMAGE_URL_XENIAL:="http://10.245.161.162/swift/v1/images/xenial-server-cloudimg-arm64-uefi1.img"}

## Gather tools if not present
    # NOT YET IMPLEMENTED

## Add cloud if not present
juju show-cloud ${CLOUD_NAME} ||\
    # NOT YET IMPLEMENTED
    exit 1

## Bootstrap if not bootstrapped
juju switch $CONTROLLER_NAME ||\
    time juju bootstrap --bootstrap-constraints="$BOOTSTRAP_CONSTRAINTS" \
                       --auto-upgrade=false \
                       --model-default=$CTI_CODIR/juju-configs/model-default.yaml \
                       --config=$CTI_CODIR/juju-configs/controller-default.yaml \
                       $CLOUD_NAME $CONTROLLER_NAME

## Add model if it doesn't exist
juju switch ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    juju add-model $MODEL_NAME $CLOUD_NAME --config=$CTI_CODIR/juju-configs/model-default.yaml

juju set-model-constraints -m $MODEL_NAME "$MODEL_CONSTRAINTS"

## Fetch and modify bundle
cp -fvp $BUNDLE_CODIR/$REF_BUNDLE_FILE $BUNDLE_FILE
sed -e "s/data-port: br-ex:eth1/data-port: br-ex:${DATA_PORT_INTERFACE}/g" -i $BUNDLE_FILE

## Deploy
time timeout 90m juju deploy -m ${CONTROLLER_NAME}:${MODEL_NAME} $BUNDLE_FILE

## Wait for Juju model deployment to complete
$JUJU_WAIT_CMD

## Build openstack client virtualenv
cd $BC_CODIR/tools/openstack-client-venv
deactivate ||:
tox
. $BC_CODIR/tools/openstack-client-venv/.tox/openstack-client/bin/activate
openstack --version
cd $HOME



exit 0


## Configure
export TEST_IMAGE_URL_XENIAL
cd $OCT_CODIR
$CONFIGURE_CMD
cd $HOME

## Test
cd $OCT_CODIR
./instance_launch.sh 6 xenial-uefi
cd $HOME
    # TODO: Run tempest tests

## Collect
    # NOT YET IMPLEMENTED

## Destroy
    # NOT YET IMPLEMENTED
