#!/bin/bash -ex
#
# This is experimental and still needs work.  Saving as a WIP/reference.

# Require these checkouts
stat -t $HOME/temp/charm-test-infra
stat -t $HOME/temp/openstack-charm-testing

# Get refstack repo
cd $HOME/temp
stat -t refstack-client ||\
    git clone https://github.com/openstack/refstack-client --depth 1

# Set up refstack venv using alternate setup which does not require sudo or apt
cp -fv $HOME/temp/charm-test-infra/fixtures/refstack/setup_venv_no_sudo refstack-client
cd refstack-client
stat .tempest ||\
    ./setup_venv_no_sudo

# Build clients venv for tempest template render
deactivate ||:
cd $HOME/temp/charm-test-infra
tox
. $HOME/temp/charm-test-infra/clientsrc
cd $HOME/temp/openstack-charm-testing
./configure refstack_only
cp -fv $HOME/temp/openstack-charm-testing/tempest_refstack.conf $HOME/temp/refstack-client/tempest.conf

# One short test first, then go for the full refstack run
cd $HOME/temp/refstack-client
deactivate ||:
stat -t refstack-venv ||\
    ln -s .venv/bin/activate refstack-venv
. refstack-venv
time ./refstack-client test -c tempest.conf -v -- --regex TokensV3Test
time ./refstack-client test -c tempest.conf -v
