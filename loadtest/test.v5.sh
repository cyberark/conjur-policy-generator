#!/usr/bin/env bash

function dco {
    docker-compose -f docker-compose.v5.yml $@
}

function wait_for_conjur {
    local curl_exit='begin'
    while [[ "$curl_exit" != '0' ]]; do
        docker-compose -f docker-compose.v5.yml exec client curl -fsI conjur
        curl_exit="$?"
    done
    echo $curl_exit
}

dco down
dco run --no-deps --rm conjur data-key generate > data_key
export CONJUR_DATA_KEY="$(< data_key)"
dco up -d
time wait_for_conjur
apikey=$(dco logs conjur | grep API | cut -d: -f2 | tr -d ' ')
# dco exec conjur conjurctl account create loadtest
dco exec client conjur init -a loadtest -u conjur
dco exec client conjur authn login -u admin -p "$apikey"
# dco exec client bash
