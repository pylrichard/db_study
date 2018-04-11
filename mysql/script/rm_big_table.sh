#!/bin/bash

<<COMMENT
在线删除大表会占用系统IO，进而导致MySQL进程阻塞和主从延时
1 建立硬链接
ln _order_detail_old.ibd _order_detail_old.ibd.bak
2 删除表
drop table _order_detail_old
3 truncate循环删除磁盘文件，通过sleep控制IO负载
COMMENT

TRUNCATE=/usr/bin/truncate
#seq 首数 增量 尾数
#假设_order_detail_old大小有11G(11000M)
#每次删除100M数据
for i in `seq 11000 -100 10`;
do
    sleep 1
    echo "$TRUNCATE -s ${i}M /var/data/mysql/data1/mc_orderdb/_order_detail_old.ibd.bak"
    $TRUNCATE -s ${i}M /var/data/mysql/data1/mc_orderdb/_order_detail_old.ibd.bak
done
