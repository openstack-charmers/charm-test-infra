#!/bin/bash -ex
# This example can be used to manually run a scenario.  Some edits and
# customizations may be necessary to match a specific lab.
#
# Typically, the variables set here are representative of the variables
# which would normally be passed from Jenkins jobs to the runner.

export BUNDLE_SCENARIO="openstack-base"
export BUNDLE_STABILITY="development"
export UBUNTU_RELEASE="xenial"
export OPENSTACK_RELEASE="newton"
export ARCH="arm64"
export TAGS="gigabyte"
export CLOUD_NAME="ruxton-maas"

# 45m is not enough for the Gigabyte arm64 machines to reach ready state.
export WAIT_TIMEOUT="75"

# WIP and workaround for https://bugs.launchpad.net/bugs/1567807
export BUNDLE_REPO_BRANCH="automation-lp1567807"

# WIP post-deploy tools
export OCT_REPO="lp:~1chb1n/openstack-charm-testing/update-tools-1703"

# ----------------------------------------------------------------------------

openstack-base/run.sh
