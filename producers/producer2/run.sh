#! /bin/bash

set -e

docker build -t producer2:latest .
docker run --rm -it -v $HOME/.aws/credentials:/root/.aws/credentials:ro producer2:latest