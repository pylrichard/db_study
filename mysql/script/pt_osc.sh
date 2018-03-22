#!/bin/bash
<<COMMENT
要求被修改的表上不能有触发器和外键，必须有主键
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
        #sql_statement="add index i_product_id(product_id)"
        sql_statement="drop index i_product_id"
	db_name=mc_orderdb
	table_name=order_cart
        ;;
    * )
	echo "1st parram error"
	;;
esac

#双引号中可以引用变量和转义字符，单引号则不行
time pt-online-schema-change --alter="${sql_statement}" --chunk-size=2000 --max-load="Threads_running=15" --critical-load="Threads_running=1000" --drop-old-table --charset=utf8 --nocheck-replication-filters --alter-foreign-keys-method=none --check-slave-lag=0 --print --statistics -u$2 -p$3 --host=$4 --execute "D=${db_name},t=${table_name}"
