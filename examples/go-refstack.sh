#!/bin/bash -ex

# Require these checkouts
stat -t $HOME/temp/charm-test-infra
stat -t $HOME/temp/openstack-charm-testing

# Get refstack repo
cd $HOME/temp
stat -t refstack-client ||\
    git clone https://github.com/openstack/refstack-client --depth 1

# Use alternate setup which requires no sudo
cp -fv $HOME/temp/charm-test-infra/fixtures/refstack/setup_venv_no_sudo refstack-client
cd refstack-client
./setup_venv_no_sudo

# Build venv
deactivate ||:
stat -t refstack-venv ||\
    ln -s .venv/bin/activate refstack-venv
. refstack-venv
pip install -r $HOME/temp/charm-test-infra/clients-requirements.txt
openstack --version

# Render tempest template
cd $HOME/temp/openstack-charm-testing
./configure refstack_only
cp -fv $HOME/temp/openstack-charm-testing/tempest_refstack.conf $HOME/temp/refstack-client/tempest.conf

# One short test first, then go for the full refstack run
cd $HOME/temp/refstack-client
time ./refstack-client test -c tempest.conf -v -- --regex TokensV3Test
time ./refstack-client test -c tempest.conf -v
