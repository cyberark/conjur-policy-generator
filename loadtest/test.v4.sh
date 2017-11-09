#!/bin/bash -e

SUITES=(
  small
  # medium
  # large
)

function finish() {
  echo 'Destroying Conjur v4'
  compose down
}

trap finish EXIT

function main() {
  launch_conjur
  run_load_tests
}

function launch_conjur() {
  echo 'Launching Conjur v4'
  compose up -d conjur
  compose exec conjur /opt/conjur/evoke/bin/wait_for_conjur
  compose exec conjur conjur authn login -u admin -p secret
}

function run_load_tests() {
  echo 'Running policy load tests'

  for suite in "${SUITES[@]}"; do
    echo "-----"
    echo "Testing $suite policy load"
    echo "-----"
    time compose exec conjur conjur policy load --as-group security_admin "/src/policy.$suite.yml"
  done
}

# internal helpers

function compose() {
  docker-compose -f docker-compose.v4.yml "$@"
}

main
