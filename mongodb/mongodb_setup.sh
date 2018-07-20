#!/bin/bash

mkdir -p /var/data/mongodb/data
mkdir -p /var/data/mongodb/log

mkdir -p /usr/local/mongodb
#注意OS版本匹配，否则会启动失败
tar -zxvf ./mongodb-linux-x86_64-ubuntu1604-3.6.6.tgz -C /usr/local/mongodb

ln -s /usr/local/mongodb/mongodb-linux-x86_64-ubuntu1604-3.6.6 /usr/local/mongodb/mongodb

mkdir -p /etc/mongodb
cp mongod.conf /etc/mongodb/
#指定bind_ip_all，Compass才可以连接上mongod
mongod --config /etc/mongodb/mongod.conf --bind_ip_all