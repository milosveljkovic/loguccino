#!/usr/bin/bash
# set path in csv files
RUNNER_PATH=$(pwd)

sed -i "s@<PATH>@${RUNNER_PATH}@g" e2e_tests/level1-test.csv
sed -i "s@<PATH>@${RUNNER_PATH}@g" e2e_tests/level1-test-patched.csv
sed -i "s@<PATH>@${RUNNER_PATH}@g" e2e_tests/level2-test.csv
sed -i "s@<PATH>@${RUNNER_PATH}@g" e2e_tests/level2-test-patched.csv
sed -i "s@<PATH>@${RUNNER_PATH}@g" e2e_tests/levelN-test.csv
sed -i "s@<PATH>@${RUNNER_PATH}@g" e2e_tests/levelN-test-patched.csv