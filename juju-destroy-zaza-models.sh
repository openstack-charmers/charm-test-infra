#!/bin/bash -uex
# Destroy models which have a name beginning with "zaza-"

if juju controllers &> /dev/null; then
    zaza_models="$(juju models --format yaml | awk '/short-name: zaza-/{ print $2 }')"
    for MODEL_NAME in $zaza_models; do
        # Use force due to juju 2.8 stopping destroy-model on hook errors
        # 5 Minute timeout to allow juju to attempt to destroy openstack resources
        juju destroy-model -y --destroy-storage ${MODEL_NAME} --force -t 300
    done
fi
