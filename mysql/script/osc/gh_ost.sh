#!/bin/bash

<<COMMENT
gh_ost暂不支持旧表上有外键和触发器
COMMENT

#跟pt_osc.sh类似
echo -n "enter your password: "
read password

time ./gh-ost --host=$2 --port=$3 --user=$4 --password=${password} --database=${db_name} --table=${table_name} --alter="${sql_statement}" --allow-on-master --chunk-size=15000 --max-load=Threads_connected=20000,Threads_running=100 --initially-drop-ghost-table --initially-drop-old-table --throttle-control-replicas="" --approve-renamed-columns --max-lag-millis=5000 --switch-to-rbr --nice-ratio=1 --postpone-cut-over-flag-file=/tmp/gh_ost_postpone.file  --panic-flag-file=/tmp/gh_ost_panic.file --verbose --execute
