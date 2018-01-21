#!/usr/bin/env bash

curl 'localhost:4567/sarc' -sd '{"text": "you\'re really going for it, aren\'t you?"}' -H 'Content-Type: application/json' | jq
