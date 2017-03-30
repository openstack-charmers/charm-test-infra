#!/bin/bash -ex
#
# This is a temporary example to illustrate, exercise and fine-tune how
# this can be used in a CI job with variables.


# igor ocata
export REMOTE=10.245.168.39
export BUNDLE_FILE="bundle-ocata.yaml"
export WORKSPACE="/tmp/WORKSPACE-IGOR"

./runners/openstack-on-lxd/run.sh
