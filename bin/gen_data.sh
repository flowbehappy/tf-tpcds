#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

set -eu

function gen_data()
{
	if [ -d ${dbgen_result_dir} ]; then
		echo "Data already exists: ${dbgen_result_dir}"
		return
	fi

	dbgen_result_dir_tmp=${dbgen_result_dir}_tmp
	cd ${toolkit_dir}/tools/
	mkdir -p ${dbgen_result_dir_tmp}
	${toolkit_dir}/tools/dsdgen -sc ${scale_factor} -dir ${dbgen_result_dir_tmp} -f
	cd -
	mv ${dbgen_result_dir_tmp} ${dbgen_result_dir}

	echo "Generate data with scale factor ${scale_factor} done! Location: ${dbgen_result_dir}"
}


build_toolkit
gen_data
