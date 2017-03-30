#!/bin/bash -ex
#
# This is a temporary example to illustrate, exercise and fine-tune how
# this can be used in a CI job with variables.


# egede newton
export REMOTE=10.245.168.57
export BUNDLE_FILE="bundle-newton.yaml"
export WORKSPACE="/tmp/WORKSPACE-EGEDE"

./runners/openstack-on-lxd/run.sh
