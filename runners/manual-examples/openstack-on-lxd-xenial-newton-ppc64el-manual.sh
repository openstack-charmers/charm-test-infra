#!/bin/bash -ex
# This example can be used to manually run a scenario.  Some edits and
# customizations may be necessary to match a specific lab.
#
# Typically, the variables set here are representative of the variables
# which would normally be passed from Jenkins jobs to the runner.

export REMOTE=10.245.168.37  # Temp IP! loudred
export BUNDLE_FILE="bundle-newton.yaml"
export WORKSPACE="/tmp/WORKSPACE-$REMOTE"
export ZPOOL_DEVS="/dev/sdb /dev/sdc /dev/sdd"  # Disk order danger!

openstack-on-lxd/run.sh
