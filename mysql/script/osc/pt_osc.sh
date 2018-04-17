#!/bin/bash

<<COMMENT
要求旧表必须有主键

pt-osc会在旧表上创建3个触发器，而一个表上不能同时有2个相同类型的触发器
如果要支持有触发器存在的表是可以实现的，思路是先找到旧表触发器定义，重写旧表触发器，最后将旧表触发器定义应用到新表

旧表有外键需要设置--alter-foreign-keys-method=rebuild_constraints

指定--nodrop-old-table不删除旧表，反复执行此脚本会报错unknown error，观察一段时间后业务没有受到影响，通过rm_big_table.sh删除旧表
指定--drop-old-table则不会报错unknown error
COMMENT

sql_statement=""
db_name=""
table_name=""

case "$1" in
    '1' )
    	#sql_statement="add index ux_order_sn(order_sn)"
        sql_statement="drop index ux_order_sn"
	    db_name=mc_orderdb
        table_name=order_master
        ;;
    '2' )
        #一次执行多条SQL
        #sql_statement="add index i_product_id(product_id),
                    #add create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'"
        sql_statement="drop index i_product_id"
	    db_name=mc_orderdb
    	table_name=order_cart
        ;;
    * )
	    echo "1st parram error"
    	;;
esac

echo -n "enter your password: "
read password

#双引号中可以引用变量和转义字符，单引号则不行
time pt-online-schema-change --alter="${sql_statement}" --chunk-size=2000 --max-load="Threads_running=15" --critical-load="Threads_running=1000" --drop-old-table --charset=utf8 --nocheck-replication-filters --alter-foreign-keys-method=none --check-slave-lag=0 --print --statistics -u$2 --host=$3 -p${password} --execute "D=${db_name},t=${table_name}"
