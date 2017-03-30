#!/bin/bash -ex
# This is a temporary example to illustrate, exercise and fine-tune how
# this can be used in a CI job with variables.

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
