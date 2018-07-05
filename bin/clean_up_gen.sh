#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

rm -rf "${data_gen_result_dir}"
rm -rf "${queries_gen_result_dir}"
