#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

set -eu

toolkit_dir=${repo_dir}/tpcds-toolkit
dbgen_result_dir=${data_dir}/gen-data-${scale_factor}
output_dir=${repo_dir}/gen-queries-${scale_factor}

query_id=""
function generate_query()
{
	cd ${toolkit_dir}/tools

	query_id=$1
	${toolkit_dir}/tools/dsqgen \
	-DIRECTORY "${toolkit_dir}/query_templates" \
	-INPUT "${toolkit_dir}/query_templates/templates.lst" \
	-OUTPUT_DIR ${output_dir} \
	-DIALECT netezza \
	-TEMPLATE "query${query_id}.tpl" \
	-QUALIFY Y \
	-SCALE ${scale_factor} \

	mv ${output_dir}/query_0.sql ${output_dir}/query_${query_id}.sql

	cd -
}

build_toolkit
rm -rf ${output_dir} && mkdir -p ${output_dir}

for i in {1..99}; do
    generate_query $i
done

