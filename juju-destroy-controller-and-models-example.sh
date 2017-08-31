#!/bin/bash -e
# OpenStack Tenant User - Juju Controller and Example Model Destruction

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

if ! juju controllers | grep 'auto-osci-sv07.*superuser'; then
    exit 0
fi

juju switch ${CONTROLLER_NAME}:controller

if ! juju destroy-controller --destroy-all-models $1 $CONTROLLER_NAME; then
    juju kill-controller $1 $CONTROLLER_NAME
fi

