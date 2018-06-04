#!/bin/bash -uex
# Destroy models which have a name beginning with "zaza-"

zaza_models="$(juju models --format yaml | awk '/short-name: zaza-/{ print $2 }')"

for MODEL_NAME in $zaza_models; do
    juju destroy-model -y --destroy-storage ${MODEL_NAME}
done
