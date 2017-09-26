#!/bin/zsh

#nohup mysqlslap.sh 300 8 &

# 此脚本执行时间(自定义测试时间)
time="$1"
# 并发数
thread="$2"
# 定义输出文件名夹
output_dir=`date +%Y_%m_%d_%H_%M_%S`

echo "test total requests: " $time
echo "output dir: " $output_dir

mkdir "$output_dir"

# 输出配置参数，方便追踪和排查
mysql -e "show variables" > my_cnf
# 打开磁盘监控
iostat -xm 3 > "$output_dir"/io_"$thread".txt &
# 输出MySQL状态到文件，查看QPS、TPS
mysqladmin extended-status -r -i 1 > "$output_dir"/mysql_"$thread".txt &
cd "$output_dir"
# 保存系统状态，5秒刷新一次，然后刷新9999999次
# 也可以使用sar -P ALL 1
nmon -f -s 5 -c 9999999
cd ..
echo "start testing..."
# 执行压力测试
# --query 自定义sql和核心业务逻辑相关，和最终业务中的SQL相似
# --delimiter 指定分隔符
# --concurrency 指定并发数
# --number-of-queries sql总共执行多少次(不是执行多少条SQL语句)
mysqlslap --query=test.sql --delimiter="//" --concurrency="$thread" --number-of-queries=99999999999 &
# 等待自定义的测试时间
sleep $time
#保存pid用于kill -9
#pid = ps aux | grep mysqladmin | grep -v "grep --color=auto mysqladmin" | awk '{print $2}'
killall iostat mysqladmin nmon mysqlslap
echo "test finish."

