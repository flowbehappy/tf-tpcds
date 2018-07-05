#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

n="$1"
is_qualify="$2"

set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	echo "<bin> usage: <bin> [-q] n(1|2|3|...99)" >&2
	exit 1
elif [ "$#" -eq 1 ]; then
	is_qualify="no"
	n="$1"
else
	if [ "$1" = "-q" ]; then
		is_qualify="yes"
	else
		is_qualify="no"
	fi
	n="$2"
fi

echo "query: ${n}, is_qualify: ${is_qualify}"

define_line=`cat "${tf_home}/benchmark/_env.sh" | grep "default_partitionsPerSplit"`
eval "$define_line"

partitionsPerSplit=$default_partitionsPerSplit

if [ "$is_qualify" = "qualify" ]; then
	queries_dir="${repo_dir}/qualification-queries"
else
	queries_dir="${queries_gen_result_dir}"
fi

sql=`cat ${queries_dir}/query${n}.sql | perl -pe "s/--.*//g" | perl -pe "s/;//g" | perl -pe "s/\n/ /g"`

echo "## Running query #"$n", partitionsPerSplit=$partitionsPerSplit"
old_dir=`pwd` && cd ${tf_home}/benchmark
${tf_home}/benchmark/spark-q.sh "$sql" "$partitionsPerSplit" "${tpcds_database}"
cd $old_dir
echo ""
