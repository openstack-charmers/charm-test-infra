#!/bin/bash -ex
# Bootstrap a specific ppc64el machine as a Juju controller. Parts of this example
# may be specific to a particular lab in OpenStack Charms CI.
. ~/novarc
. ~/oscirc

# Destroy previous non-MAAS controller if exists
( cd ..
./juju-destroy-controller-and-models-example.sh -y

export CLOUD_NAME="ruxton-maas"
export MODEL_CONSTRAINTS="arch=amd64 tags=uosci"
export BOOTSTRAP_CONSTRAINTS="arch=amd64 tags=uosci"

# Bootstrap Juju controller on MAAS
./juju-destroy-controller-and-models-example.sh -y
./juju-maas-controller-example.sh
)
