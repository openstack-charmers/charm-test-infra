#!/bin/bash -ex
# This example can be used to manually run a scenario.  Some edits and
# customizations may be necessary to match a specific lab.
#
# Typically, the variables set here are representative of the variables
# which would normally be passed from Jenkins jobs to the runner.


export BUNDLE_SCENARIO="ceph-base"
export BUNDLE_STABILITY="development"
export UBUNTU_RELEASE="xenial"
export OPENSTACK_RELEASE="mitaka"
export ARCH="arm64"
export TAGS="gigabyte"
export CLOUD_NAME="ruxton-maas"

# XXX: Workaround for https://bugs.launchpad.net/bugs/1567807
export BUNDLE_REPO_BRANCH="automation-lp1567807"

./runners/ceph-base/run.sh
