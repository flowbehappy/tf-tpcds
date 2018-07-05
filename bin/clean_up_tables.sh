#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

set -eu

old_dir=`pwd` && cd ${tf_home}/benchmark
sqls=""
for file_name in `ls ${repo_dir}/table-schemas/*.sql`; do
	table_file=$(echo "${file_name##*/}")
	table_name=$(echo "${table_file%.*}")
	sql="drop table if exists ${tpcds_database}.${table_name}"
	sqls+=("$sql")
done
sqls+=("drop database if exists ${tpcds_database}")
${tf_home}/benchmark/spark-q-m.sh "${sqls[@]}"
${tf_home}/benchmark/spark-drop-ch-database.sh "${tpcds_database}"
cd $old_dir

