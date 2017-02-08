#!/bin/bash -ex
#
# This is a temporary example to illustrate, exercise and fine-tune how
# this can be used in a CI job with variables.


# igor mitaka
export REMOTE=10.245.168.39
export BUNDLE_FILE="bundle-mitaka.yaml"
export WORKSPACE="/tmp/WORKSPACE-IGOR"

./runners/openstack-on-lxd/openstack-on-lxd-runner.sh
