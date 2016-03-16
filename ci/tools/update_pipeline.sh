#!/usr/bin/env bash
set -x

echo "Pushing pipeline.yml to Concourse server"

# ls -la
# ls -la pipeline

# fly -t $2 sync
fly -t local login -c $1 -u $2 -p $3
fly -t local pipelines
fly -t local set-pipeline -n -p $4 -c pipeline/pipeline.yml -l $5
