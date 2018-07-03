#!/usr/bin/env bash

export this_dir=$(cd $(dirname $0);echo $PWD)
export repo_dir=$(cd ${this_dir}/../;echo $PWD)

_get_is_mac() {
	local mac="no"
	if [ "`uname`" == "darwin" ]; then
		mac="yes"
	fi
	echo "$mac"
}
export is_mac=`_get_is_mac`

echo "repo dir: ${repo_dir}"

toolkit_dir=${repo_dir}/tpcds-toolkit

function build_toolkit()
{
	if [ -f ${toolkit_dir}/tools/dsdgen ]; then
		return
	fi
	os=""
	if [ is_mac == "no" ]; then
		os="LINUX"
	else
		os="MACOS"
	fi
	cd ${toolkit_dir}/tools/ && make os=$os -j4 && cd -
}


scale_factor="1"
data_dir="${repo_dir}"
