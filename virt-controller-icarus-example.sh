#!/bin/bash -uex
# Example script for creating a controller with virt nodes on icarus-maas
# Must update juju-configs/credentials.yaml with your MAAS oauth key

export CLOUD_NAME="icarus-maas"
export BOOTSTRAP_CONSTRAINTS="tags=virtual"
export MODEL_CONSTRAINTS="tags=virtual"
./juju-maas-controller-example.sh
