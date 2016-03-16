#!/usr/bin/env bash
set -x

echo "Running inception of pipeline"
# cd inceptor-repo/ci/tools
ruby inceptor-repo/ci/tools/generate_pipeline.rb $1
# cd -
# ls -la
# ls -la pipeline
