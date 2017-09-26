#!/bin/sh

db_user="root"
db_passwd=""
db_host="localhost"
backup_dir=""
time="$(date +"%d-%m-%Y")"

# check the directory for store backup is writeable
test ! -w $backup_dir && echo "Error: $backup_dir is un-writeable." && exit 0

# the directory for store the newest backup
test ! -d "$backup_dir/backup.0/" && mkdir "$backup_dir/backup.0/"

# get all databases
all_db="$(mysql -u $db_user -h $db_host -p$db_passwd -Bse 'show databases')"
for db in $all_db
do
    #参数可以添加到my.cnf
    mysqldump -u $db_user -p$db_passwd --skip-lock-tables --opt --add-drop-database --add-drop-table --events --triggers --routines --default-character-set=utf8 --master-data=1  --single-transaction --complete-insert --quote-names --log-error=$backup_dir/mysqldump_db_$time.log $db | gzip -9 > "$backup_dir/backup.0/$time.$db.gz"
done

mysqldump -uroot -p$db_passwd --all-databases --opt --add-drop-database --add-drop-table --events --triggers --routines --default-character-set=utf8 --master-data=1 --single-transaction --complete-insert --quote-names --log-error=$backup_dir/mysqldump$time.log | gzip -9 > "$backup_dir/backup.0/$time.all_mysql"

# delete the oldest backup
test -d "$backup_dir/backup.7/" && rm -rf "$backup_dir/backup.7"

# rotate backup directory
for int in 6 5 4 3 2 1 0
do
    if (test -d "$backup_dir"/backup."$int")
    then
        next_int=`expr $int + 1`
        mv "$backup_dir"/backup."$int" "$backup_dir"/backup."$next_int"
    fi
done
exit 0;

