#!/usr/bin/bash
# set path in csv files
RUNNER_PATH=$(pwd)

sed -i "s@<PATH>@${RUNNER_PATH}@g" ./level1-test.csv
sed -i "s@<PATH>@${RUNNER_PATH}@g" ./level2-test.csv