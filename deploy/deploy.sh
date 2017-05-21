#!/usr/bin/env bash

set -v

VAULT_FILE="${PWD}/vault"
DEPLOYMENT_ENVIRONMENT=${1:-staging}

# Only execute deployment if $TRAVIS is null (we are not on CI) or we are on CI merging to master and the build has ended successfully
if [[ -z "${TRAVIS}" ]] || [[ "${TRAVIS_PULL_REQUEST}" == "false" && "${TRAVIS_TEST_RESULT}" == 0 && "${TRAVIS_BRANCH}" == 'master' ]]; then
  echo "${VAULT_PASSWORD}" > "${VAULT_FILE}"
  docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:/app" \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    fiunchinho/wimpy /app/deploy/deploy.yml --vault-password-file "/app/vault" \
      --extra-vars "wimpy_release_version=${TRAVIS_COMMIT} wimpy_deployment_environment=${DEPLOYMENT_ENVIRONMENT}" -vv
fi
