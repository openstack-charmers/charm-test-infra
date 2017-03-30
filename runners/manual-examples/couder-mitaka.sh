#!/bin/bash -ex
#
# This is a temporary example to illustrate, exercise and fine-tune how
# this can be used in a CI job with variables.


# couder mitaka
export REMOTE=10.245.168.56
export BUNDLE_FILE="bundle-mitaka.yaml"
export WORKSPACE="/tmp/WORKSPACE-COUDER"

./runners/openstack-on-lxd/run.sh
