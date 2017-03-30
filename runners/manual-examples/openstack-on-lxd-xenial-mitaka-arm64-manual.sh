#!/bin/bash -ex
# This is a temporary example to illustrate, exercise and fine-tune how
# this can be used in a CI job with variables.

# lohrmann arm64
export REMOTE=10.245.168.36/21
export BUNDLE_FILE="bundle-mitaka.yaml"
export WORKSPACE="/tmp/WORKSPACE-LOHRMANN"

./runners/openstack-on-lxd/run.sh
