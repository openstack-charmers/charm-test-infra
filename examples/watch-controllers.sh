#!/bin/bash -uex
watch --color --interval=30 "timeout 9 juju controllers && timeout 9 juju models && timeout 9 juju machines --color"
