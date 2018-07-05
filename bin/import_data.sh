#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

set -eu

table=$1

if [ -z $table ]; then
	table="ALL"
elif [ $table = "-h" ]; then
	echo "Usage: <bin> table_name|ALL"
	exit
fi

function import_table()
{
	table_name=$1
	# Create local CSV table.
	schema=`cat ${repo_dir}/table-schemas/${table_name}.sql | perl -pe "s/#.*//g" | perl -pe "s/${table_name}\n/${tpcds_database}.${table_name}\n/g" | perl -pe "s/\n/ /g"`
	schema+=" USING csv OPTIONS(header 'false', delimiter '|', path '${dbgen_result_dir}/${table_name}.dat')"
	# echo ${schema}
	old_dir=`pwd` && cd ${tf_home}/benchmark
	
	${tf_home}/benchmark/spark-q-m.sh \
	"create database if not exists ${tpcds_database}" \
	"drop table if exists ${tpcds_database}.${table_name}" \
	"${schema}" \

	cd $old_dir

	# Load CSV table into tf storage.
	pkeys=`cat ${repo_dir}/table-schemas/${table_name}.sql | grep '#'`

	pkeys=${pkeys#"#"}
	pkeys=${pkeys#" "}
	pkeys=${pkeys%" "}
	pkeys=${pkeys%","}

	pk=""
	for key in $(echo $pkeys | tr "," "\n")
	do
	  pk+="\"${key}\","
	done
	pk=${pk%","}

	echo $pk

	old_dir=`pwd` && cd ${tf_home}/benchmark
	${tf_home}/benchmark/spark-create-ch-table.sh "${tpcds_database}" "${table_name}" "${tpcds_database}" "${table_name}" $pk
	cd $old_dir
}

function import_all()
{
	for file_name in `ls ${repo_dir}/table-schemas/*.sql`; do
		table_file=$(echo "${file_name##*/}")
		table_name=$(echo "${table_file%.*}")
		import_table ${table_name}
	done
}

if [ $table = "ALL" ] || [ $table = "all" ]; then
	import_all
else
	import_table ${table}
fi

