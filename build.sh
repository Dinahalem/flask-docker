#!/bin/bash

COMMIT_HASH=$(git rev-parse --short HEAD)

docker build -t dina2022/flaskdocker:${COMMIT_HASH} .
