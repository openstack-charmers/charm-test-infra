#!/bin/bash -ex
#
# An example test runner for ARM64 OpenStack-Base bundle deploy on MAAS
#
# Default environment variable values represent a specific lab and must
# be adjusted to suit.
#

## Tool env vars
: ${JUJU_WAIT_CODIR:="$HOME/temp/juju-wait"}
: ${JUJU_WAIT_CMD:="time timeout 45m $JUJU_WAIT_CODIR/juju-wait -v"}

: ${OCT_CODIR:="$HOME/temp/openstack-charm-testing"}
: ${OCT_CONFIGURE_CMD:="$OCT_CODIR/configure dellstack"}

## Controller env vars
: ${CONTROLLER_NAME:="ruxton-maas"}
: ${BOOTSTRAP_CONSTRAINTS:="arch=arm64 tags=gigabyte"}
: ${MODEL_CONSTRAINTS:="$BOOTSTRAP_CONSTRAINTS"}

## Model env vars
: ${MODEL_NAME:="openstack-base-arm64"}
: ${CONTROLLER_NAME:="ruxton-maas"}
: ${OPENSTACK_BUNDLES_CODIR:="$HOME/temp/openstack-bundles"}
: ${CTI_CODIR:="$HOME/temp/charm-test-infra"}

## Bundle env vars
: ${DATA_PORT_INTERFACE:="enP2p1s0f2"}
: ${REF_BUNDLE_FILE:="development/openstack-base-xenial-mitaka/bundle.yaml"}
: ${BUNDLE_FILE:="$(mktemp)"}

## Bootstrap if not bootstrapped
juju switch $CONTROLLER_NAME ||\
    time juju bootstrap --bootstrap-constraints="$BOOTSTRAP_CONSTRAINTS" \
                       --auto-upgrade=false \
                       --bootstrap-series=xenial \
                       --model-default=$CTI_CODIR/juju-configs/model-default.yaml \
                       --config=$CTI_CODIR/juju-configs/controller-default.yaml \
                       $CONTROLLER_NAME

## Add model if it doesn't exist
juju switch ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    juju add-model $MODEL_NAME $CONTROLLER_NAME --config=$CTI_CODIR/juju-configs/model-default.yaml

juju set-model-constraints -m $MODEL_NAME "$MODEL_CONSTRAINTS"

## Fetch and modify bundle
cp -fvp $OPENSTACK_BUNDLES_CODIR/$REF_BUNDLE_FILE $BUNDLE_FILE
sed -e "s/data-port: br-ex:eth1/data-port: br-ex:${DATA_PORT_INTERFACE}/g" -i $BUNDLE_FILE

## Deploy
time timeout 90m juju deploy -m ${CONTROLLER_NAME}:${MODEL_NAME} $BUNDLE_FILE

## Wait for Juju model deployment to complete
$JUJU_WAIT_CMD

## Configure
$OCT_CONFIGURE_CMD

## Test

## Collect

## Destroy
