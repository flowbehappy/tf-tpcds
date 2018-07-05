#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

set -eu

toolkit_dir=${repo_dir}/tpcds-toolkit

query_id=""
function generate_query()
{
	cd ${toolkit_dir}/tools

	query_id=$1
	${toolkit_dir}/tools/dsqgen \
	-DIRECTORY "${toolkit_dir}/query_templates" \
	-INPUT "${toolkit_dir}/query_templates/templates.lst" \
	-OUTPUT_DIR ${queries_gen_result_dir} \
	-DIALECT netezza \
	-TEMPLATE "query${query_id}.tpl" \
	-QUALIFY Y \
	-SCALE ${scale_factor} \

	mv ${queries_gen_result_dir}/query_0.sql ${queries_gen_result_dir}/query${query_id}.sql

	cd -
}

build_toolkit
rm -rf ${queries_gen_result_dir} && mkdir -p ${queries_gen_result_dir}

for i in {1..99}; do
    generate_query $i
done

