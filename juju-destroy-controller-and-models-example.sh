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

if juju controllers &> /dev/null; then
    juju switch ${CONTROLLER_NAME}:controller
    timeout 900 juju destroy-controller --destroy-storage --destroy-all-models $1 $CONTROLLER_NAME ||\
        timeout 900 juju kill-controller $1 $CONTROLLER_NAME
fi
