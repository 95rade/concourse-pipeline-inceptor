#!/usr/bin/env bash
set -x

echo "Running inception of pipeline"
cd template-repo/ci/tools
ruby generate_pipeline.rb $1
cd -
mkdir pipeline
ls -la
mv template-repo/ci/templates/pipeline.yml pipeline/pipeline.yml

# fly -t $2 sync
fly -t local login -c $2
fly -t local pipelines # -u $3 -p $4
fly -t local set-pipeline -n -p $5 -c pipeline/pipeline.yml
