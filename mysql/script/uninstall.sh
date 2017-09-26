#!/bin/zsh

[ -L /usr/local/mysql/mysql_5* ] && unlink /usr/local/mysql/mysql_5*

rm -rf /usr/local/mysql
rm -rf /var/data/mysql
rm -rf /etc/mysql/my.cnf /etc/init.d/mysql.server /etc/init.d/mysqld_multi.server
