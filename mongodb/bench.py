#!/usr/bin/python
# _*_ coding:utf8 _*_

import time
from pymongo import MongoClient
import threading

time1 = time.time()
ip = "x.x.x.x"
port = 27017

conn = MongoClient(ip, port, minPoolSize=1500, maxPoolSize=1600)
db = conn.test
db.authenticate("xxx", "xxx")

def run(num):
    data = db.testCollection.find({})
    print data

if __name__ == "__main__":
    threads = []
    for num in range(30000):
        t1 = threading.Thread(target = run, args = (num,))
        t1.start()
        threads.append(t1)
    
    for t in threads:
        t.join()

    conn.close()
    time2 = time.time()
    print time2 - time1