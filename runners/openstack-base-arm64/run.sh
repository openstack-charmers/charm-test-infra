#!/bin/bash -ex
#
# Example test runner for ARM64 OpenStack-Base bundle deploy on MAAS

## Tool env vars
export JUJU_WAIT_CODIR="$HOME/temp/juju-wait"
export JUJU_WAIT_CMD="time timeout 45m $JUJU_WAIT_CODIR/juju-wait -v"

## Controller env vars
export CONTROLLER_NAME="ruxton-maas"
export BOOTSTRAP_CONSTRAINTS="arch=arm64 tags=gigabyte"
export MODEL_CONSTRAINTS="$BOOTSTRAP_CONSTRAINTS"

## Model env vars
export MODEL_NAME="openstack-base-arm64"
export CONTROLLER_NAME="ruxton-maas"
export OPENSTACK_BUNDLES_CODIR="$HOME/temp/openstack-bundles"
export CTI_CODIR="$HOME/temp/charm-test-infra"

## Bundle env vars
export DATA_PORT_INTERFACE="enP2p1s0f2"
export REF_BUNDLE_FILE="development/openstack-base-xenial-mitaka/bundle.yaml"
export BUNDLE_FILE="$(mktemp)"

## Bootstrap if not bootstrapped
juju switch $CONTROLLER_NAME ||\
    juju bootstrap --bootstrap-constraints="$BOOTSTRAP_CONSTRAINTS" \
                   --auto-upgrade=false \
                   --bootstrap-series=xenial \
                   --model-default=$CTI_CODIR/juju-configs/model-default.yaml \
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

## Test

## Collect

## Destroy
