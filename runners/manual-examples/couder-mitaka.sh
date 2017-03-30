#!/bin/bash -ex
# This example can be used to manually run a scenario.  Some edits and
# customizations may be necessary to match a specific lab.
#
# Typically, the variables set here are representative of the variables
# which would normally be passed from Jenkins jobs to the runner.\


# couder mitaka
export REMOTE=10.245.168.56
export BUNDLE_FILE="bundle-mitaka.yaml"
export WORKSPACE="/tmp/WORKSPACE-COUDER"

./runners/openstack-on-lxd/run.sh
