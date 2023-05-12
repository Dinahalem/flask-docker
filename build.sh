#!/bin/bash

COMMIT_HASH=$(git rev-parse --short HEAD | sed 's/[^a-zA-Z0-9._-]/-/g')

docker build -t dina2022/flaskdocker:${COMMIT_HASH} .
