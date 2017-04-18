#!/bin/bash -ex
# An example test runner for exercising "openstack-bundles" style bundles with
# MAAS 2.x and Juju 2.x.
#
# Default environment variable values represent a specific lab and may need to
# be adjusted to suit.
#
# Example of `juju models` during a manual run:
#   Model                                        Cloud/Region  Status     Machines  Cores  Access  Last connection
#   controller                                   ruxton-maas   available         1     48  admin   just now
#   default                                      ruxton-maas   available         0      -  admin   1 hour ago
#   openstack-base-xenial-newton-development-0*  ruxton-maas   available        16    144  admin   just now
#
# ----------------------------------------------------------------------------
# See the examples dir for usage with Jenkins and usage as a manual test case.
# ----------------------------------------------------------------------------

## All env vars below are global generic defaults

## Per-job env vars
: ${BUNDLE_SCENARIO:="openstack-base"}
: ${BUNDLE_STABILITY:="development"}
: ${UBUNTU_RELEASE:="xenial"}
: ${OPENSTACK_RELEASE:="ocata"}
: ${ARCH:="*"}
: ${TAGS:="*"}

## Manual run env vars
: ${JENKINS_HOME:="$HOME"}
: ${EXECUTOR_NUMBER:="0"}
: ${WORKSPACE:="$(mktemp -d /tmp/WORKSPACE.XXXXXXXXXX)"}

## Repo env vars
: ${BASE_CODIR:="${JENKINS_HOME}/tools/${EXECUTOR_NUMBER}"}

  # OCT + OS-BUNDLES will become one repo
: ${BUNDLE_REPO:="https://github.com/openstack-charmers/openstack-bundles"}
: ${BUNDLE_REPO_BRANCH:="master"}
: ${BUNDLE_CODIR:="${BASE_CODIR}/openstack-bundles"}
: ${OCT_REPO:="lp:openstack-charm-testing"}
: ${OCT_CODIR:="${BASE_CODIR}/openstack-charm-testing"}

  # BC + CTI will become one repo
: ${BC_REPO:="https://github.com/openstack-charmers/bot-control"}
: ${BC_REPO_BRANCH:="master"}
: ${BC_CODIR:="${BASE_CODIR}/bot-control"}
: ${CTI_REPO:="https://github.com/ryan-beisner/charm-test-infra"}  # WIP
: ${CTI_REPO_BRANCH:="master"}
: ${CTI_CODIR:="${BASE_CODIR}/charm-test-infra"}

  # Misc other tools with no pip capability
: ${JW_REPO:="https://git.launchpad.net/juju-wait"}
: ${JW_REPO_BRANCH:="master"}
: ${JW_CODIR:="${BASE_CODIR}/juju-wait"}

## Cloud, Controller, and Model env vars
: ${CLOUD_NAME:="ruxton-maas"}
: ${CONTROLLER_NAME:="${CLOUD_NAME}-${ARCH}"}
: ${BOOTSTRAP_CONSTRAINTS:="arch=${ARCH} tags=${TAGS}"}
: ${MODEL_CONSTRAINTS:="$BOOTSTRAP_CONSTRAINTS"}
: ${MODEL_NAME:="${BUNDLE_SCENARIO}-${UBUNTU_RELEASE}-${OPENSTACK_RELEASE}-${BUNDLE_STABILITY}-${EXECUTOR_NUMBER}"}

## Bundle env vars
: ${DATA_PORT_INTERFACE:="enP2p1s0f2"}
: ${REF_BUNDLE_FILE:="${BUNDLE_STABILITY}/${BUNDLE_SCENARIO}-${UBUNTU_RELEASE}-${OPENSTACK_RELEASE}/bundle.yaml"}
: ${BUNDLE_FILE:="$(mktemp /tmp/bundle.XXXXXXXXXX.yaml)"}
: ${DEPLOY_TIMEOUT:="90m"}
: ${DESTROY_TIMEOUT:="20m"}
: ${WAIT_TIMEOUT:="45"}

## Fixture env vars
: ${TEST_IMAGE_URL_XENIAL:="http://10.245.161.162/swift/v1/images/xenial-server-cloudimg-arm64-uefi1.img"}

## Command env vars
: ${JUJU_WAIT_CMD:="time timeout $WAIT_TIMEOUT $JW_CODIR/juju-wait -v"}
: ${CONFIGURE_CMD:="./configure arm64"}

## Gather tools
rm -rf $BUNDLE_CODIR
rm -rf $BC_CODIR
rm -rf $JW_CODIR
rm -rf $CTI_CODIR
rm -rf $OCT_CODIR
git clone --depth 1 $BUNDLE_REPO $BUNDLE_CODIR -b $BUNDLE_REPO_BRANCH
git clone --depth 1 $BC_REPO     $BC_CODIR     -b $BC_REPO_BRANCH
git clone --depth 1 $JW_REPO     $JW_CODIR     -b $JW_REPO_BRANCH
git clone --depth 1 $CTI_REPO    $CTI_CODIR    -b $CTI_REPO_BRANCH
bzr export $OCT_CODIR $OCT_REPO

## Validate existince of some required files
for _FILEDIR in $BUNDLE_CODIR/$REF_BUNDLE_FILE \
                $BUNDLE_CODIR \
                $BUNDLE_FILE \
                $BC_CODIR \
                $JW_CODIR \
                $CTI_CODIR \
                $OCT_CODIR; do
    stat -t $_FILEDIR
done

## Add cloud if not present
juju show-cloud $CLOUD_NAME ||\
    # NOT YET IMPLEMENTED - cloud should exist in advance for now
    exit 1

## Bootstrap if not bootstrapped
juju switch $CONTROLLER_NAME ||\
    time juju bootstrap --bootstrap-constraints="$BOOTSTRAP_CONSTRAINTS" \
                        --auto-upgrade=false \
                        --model-default=$CTI_CODIR/juju-configs/model-default.yaml \
                        --config=$CTI_CODIR/juju-configs/controller-default.yaml \
                        $CLOUD_NAME $CONTROLLER_NAME

## Add model if it doesn't exist
juju switch ${CONTROLLER_NAME}:${MODEL_NAME} ||\
    time juju add-model $MODEL_NAME $CLOUD_NAME --config=$CTI_CODIR/juju-configs/model-default.yaml

juju set-model-constraints -m $MODEL_NAME "$MODEL_CONSTRAINTS"

## Fetch and modify bundle
cp -fvp $BUNDLE_CODIR/$REF_BUNDLE_FILE $BUNDLE_FILE
sed -e "s/data-port: br-ex:eth1/data-port: br-ex:${DATA_PORT_INTERFACE}/g" -i $BUNDLE_FILE

## Deploy
time timeout $DEPLOY_TIMEOUT juju deploy -m ${CONTROLLER_NAME}:${MODEL_NAME} $BUNDLE_FILE

## Wait for Juju model deployment to complete
$JUJU_WAIT_CMD

## Build openstack client virtualenv
cd $BC_CODIR/tools/openstack-client-venv
deactivate ||:
tox
. $BC_CODIR/tools/openstack-client-venv/.tox/openstack-client/bin/activate
cd $WORKSPACE

## Source novarc creds and do very basic API validation of the cloud
cd $OCT_CODIR
. novarc
openstack catalog list
openstack service list
openstack hypervisor list
openstack hypervisor show 1
openstack network agent list
openstack network service provider list
cd $WORKSPACE

## Configure
export TEST_IMAGE_URL_XENIAL
cd $OCT_CODIR
$CONFIGURE_CMD
openstack image list
openstack subnet list
openstack security group list
cd $WORKSPACE

## Test basic instantiation and reachability
export WORKSPACE
cd $OCT_CODIR
tools/instance_launch.sh 6 xenial-uefi
tools/instance_wait.sh
tools/float_all.sh
openstack server list
tools/instance_ssh_ping_all.sh
tools/instance_delete_all.sh
cd $WORKSPACE

# Test with Tempest
# TODO: Run tempest tests

## Collect
    # NOT YET IMPLEMENTED

## Destroy
time timeout $DESTROY_TIMEOUT juju destroy-model -y ${CONTROLLER_NAME}:${MODEL_NAME}
# time timeout $DESTROY_TIMEOUT juju destroy-controller -y --destroy-all-models $CONTROLLER_NAME

echo "The end of $(basename $0)"

