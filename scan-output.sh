#!/usr/bin/bash
RUNNER_PATH=$(pwd)

sed -i "s/<PATH>/${RUNNER_PATH}/g" ./level1-test.csv