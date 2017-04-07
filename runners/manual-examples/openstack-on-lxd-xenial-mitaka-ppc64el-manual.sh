#!/bin/bash -ex
# This example can be used to manually run a scenario.  Some edits and
# customizations may be necessary to match a specific lab.
#
# Typically, the variables set here are representative of the variables
# which would normally be passed from Jenkins jobs to the runner.

# mawhile ppc64el
export REMOTE=10.245.168.48  # Temp IP!
export BUNDLE_FILE="bundle-mitaka.yaml"
export WORKSPACE="/tmp/WORKSPACE-MAWHILE"
export ZPOOL_DEVS="/dev/sda /dev/sdb /dev/sdc /dev/sde"  # Disk order danger!

openstack-on-lxd/run.sh
