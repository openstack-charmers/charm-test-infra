#!/bin/bash -ex
# This is a temporary example to illustrate, exercise and fine-tune how
# this can be used in a CI job with variables.

export BUNDLE_SCENARIO="openstack-base"
export BUNDLE_STABILITY="development"
export UBUNTU_RELEASE="xenial"
export OPENSTACK_RELEASE="mitaka"
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

./runners/openstack-base/run.sh
