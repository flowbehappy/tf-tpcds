#!/usr/bin/env bash

this_dir=$(cd $(dirname $0); echo $PWD)
source ${this_dir}/_env.sh

is_qualify="$1"
log_file="${repo_dir}/report/tpcds.log"
report_file="${repo_dir}/report/tpcds.log.md"

set -eu

mkdir -p ${repo_dir}/report

function run_quries()
{
	for q in {1..99}; do
		${repo_dir}/bin/run_query.sh $is_qualify $q >> "$log_file"
		cat "$log_file" | python ${repo_dir}/bin/report_generator.py > "$report_file"
	done
}

if [ "$is_qualify" = "-q" ]; then
	q="yes"
else
	q="no"
fi
echo "is_qualify: $q"
echo "Check log: ${log_file}"
echo "Check report: ${report_file}"

for (( i = 0; i < $report_iteration; i++ )); do
	echo "iteration ${i}/${report_iteration}"
	run_quries
done

echo "Done."
