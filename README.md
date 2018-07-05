tf-tpcds
===

## Setup tf project. Make sure it can run TPCH benchmark.

Check the README of tf project.

## Use this project to run TPC-DS.

```
git clone git@github.com:flowbehappy/tf-tpcds.git
cd tf-tpcds
```

### Set envs in Configurations section to proper values, like `tf_home`, `scale_factor`, etc.

`vim tf-tpcds/_env.sh`

### Generate table data.

`bin/gen_data.sh`

### Generate benchmark queries.

`bin/gen_queries.sh`

### Run single query of generated queries.

`bin/run_query.sh 2`

### Run single qualification query. The qualification queries can only be run with `scale_factor=1`. Their result are used to check equality with `tpcds-toolkit/answer_sets/*.ans` .

`bin/run_query.sh -q 2`

### Run all queries.

`bin/run_all_queries.sh`

### Run all qualification queries.

`bin/run_all_queries.sh -q`

### Run all queries, and generate report.

`bin/run_all_queries_with_report.sh` or `bin/run_all_queries_with_report.sh -q`