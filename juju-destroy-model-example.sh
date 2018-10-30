#!/bin/bash -e
# Example:  Destroy the model if the controller and the model both exist.
#           Exit cleanly if the controller and/or the model do not exist.

if [ -z "${OS_PROJECT_NAME}" ]; then
  echo "ERROR: Have you sourced novarc?"
  exit 1
fi

if [ -z "$1" ]; then
  echo "ERROR: Must specify -y to really destroy things."
  exit 1
fi

set -ux

: ${CLOUD_NAME:="$OS_REGION_NAME"}
: ${CONTROLLER_NAME:="${OS_PROJECT_NAME}-${CLOUD_NAME}"}
: ${MODEL_NAME:="${OS_PROJECT_NAME:0:12}"}

juju show-model ${CONTROLLER_NAME}:${MODEL_NAME} || \
    echo "Controller:Model not found (${CONTROLLER_NAME}:${MODEL_NAME})"

juju destroy-model --destroy-storage $1 ${CONTROLLER_NAME}:${MODEL_NAME}
