#!/bin/bash -ex
# Deploy a bundle. Parts of this example may be specific to a particular
# lab in OpenStack Charms CI.
. ~/novarc
. ~/oscirc

bundle=$HOME/temp/openstack-bundles/development/openstack-refstack-xenial-ocata/bundle.yaml
bundle_tmp=$(mktemp)
cp $bundle $bundle_tmp
grep data-port $bundle_tmp
juju deploy $bundle_tmp
# rm -fv $bundle_tmp
