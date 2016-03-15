#!/usr/bin/env bash
set -x

echo "Running inception of pipeline"
# cd inceptor-repo/ci/tools
ruby inceptor-repo/ci/tools/generate_pipeline.rb $1
cd -
ls -la
ls -la pipeline

# fly -t $2 sync
fly -t local login -c $2
fly -t local pipelines # -u $3 -p $4
fly -t local set-pipeline -n -p $5 -c pipeline/pipeline.yml
