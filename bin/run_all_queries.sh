#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

is_qualify="$1"

set -eu

for q in {1..99}; do
	${repo_dir}/bin/run_query.sh $is_qualify $q
done
