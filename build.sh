#!/usr/bin/env bash
mkdir -p src/ruby
docker run --interactive --tty --rm --volume $PWD:/workdir mqsoh/knot *.md src/*.md
docker build -t conjur-policy-generator .
