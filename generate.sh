#!/usr/bin/env bash

docker run --rm conjur-policy-generator run generate -- $@
