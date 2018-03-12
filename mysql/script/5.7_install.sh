#!/bin/bash

#此脚本需要切换到root下执行

#判断脚本执行时所带的参数是否符合规范
function usage {
    echo "usage: ./5.7_install.sh mysql-5.x.x.tar.gz single/multi data_start data_end"
    exit
}

function usage_multi {
    echo "usage: ./5.7_install.sh mysql-5.x.x.tar.gz multi data_start data_end"
    exit
}

function usage_single {
    echo "usage: ./5.7_install.sh mysql-5.x.x.tar.gz single datax"
    exit
}

[ $# = 0 ] || [ $# = 1 ] || [ $# -gt 4 ] && usage

if [ $# = 2 ]
then
    [ $2 = "multi" ] && usage_multi

    [ $2 = "single" ] && usage_single
fi

function check_param {
    #通过expr将变量与一个整数相加，如果能正常执行则为整数，否则$?将是非0值
    #输入0判断会有误
    expr $1 + 0 &>/dev/null
    if [ $? -ne 0 ]
    then
        echo "$1 should be integer"
        exit
    fi

    if [ $1 -lt 0 ]
    then
        echo "$1 should be positive"
        exit
    fi
}

if [ $# = 3 ]
then
    [ $2 != "single" ] && usage_single

    check_param $3
fi

if [ $# = 4 ]
then
    [ $2 != "multi" ] && usage_multi

    check_param $3
    check_param $4

    if [ $3 -gt $4 ]
    then
        echo "data_end $4 < data_start $3"
        exit
    fi
fi

#检查参数完毕，开始进行安装并初始化

#dirname /mnt/hgfs/soft/dev/mysql/mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz 获得/mnt/hgfs/soft/dev/mysql
#basename /mnt/hgfs/soft/dev/mysql/mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz 获得mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz
mysql_dir=$(echo `basename $1` | sed "s/.tar.gz//g")
#得到MySQL版本
version=$(echo $mysql_dir | cut -d '-' -f 2 | cut -d '.' -f 1,2)

if [ $version != "5.7" ]
then
    echo "sorry, mysql verson is not 5.7"
    exit
fi

mysql_install_dir=/usr/local/mysql

#创建用户组和用户
echo -e "mysql group and user check"

grpchk=$(cat /etc/group | grep mysql)

#[]中必须有空格，否则报错
if [ $? -eq 0 ]
then
    echo -e "group mysql exists!"
else
    echo -e "add group mysql!"
    groupadd mysql
fi

userchk=$(cat /etc/passwd | grep mysql)

if [ $? -eq 0 ]
then
    echo -e "user mysql exists!"
else
    echo -e "add user mysql!"
    #-g表示mysql用户属于mysql用户组
    useradd -r -g mysql mysql
fi

#拷贝配置文件
echo -e "copy config file to /etc/mysql/my.cnf!"
cd `dirname $0`
conf_dir=/etc/mysql

if test -d $conf_dir
then
   rm -rf $conf_dir
fi

mkdir $conf_dir
cp $(pwd)/my.cnf $conf_dir/my.cnf

mysql_link=mysql_57
bin_dir=$mysql_install_dir/$mysql_link/bin

#/usr/local/mysql-5.x.x-linux-glibc2.5-x86_64目录存在则不解压
if test -d $mysql_install_dir/$mysql_dir
then
    echo -e "dir exists!"
else
    #解压二进制压缩包
    echo -e "decompress binary package..."
    mkdir $mysql_install_dir
    tar zxf $1 -C$mysql_install_dir

    #切换到/usr/local
    if [ $(pwd) != $mysql_install_dir ]
    then
        cd $mysql_install_dir
    fi

    #创建mysql软链接
    echo -e "create link..."
    ln -s $mysql_dir $mysql_link
fi

#创建data_dir
data_dir=/var/data/mysql
echo -e "check data dir!"
if test -d $data_dir
then
    echo -e "data dir exists"
else
    echo -e "create data dir"
    mkdir -p $data_dir
fi

cd $data_dir

if [ $2 = "multi" ]
then
    mkdir data{$3..$4}
else
    mkdir data$3
fi

#data_dir的用户权限为mysql:mysql
chown -R mysql:mysql $data_dir

#对每个实例进行初始化
cd $mysql_install_dir/$mysql_link
chown -R mysql:mysql .

function create_mysql_files_dir {
    mkdir mysql-files
    chmod 770 mysql-files
    chown -R mysql:mysql mysql-files
}

if test -d mysql-files
then
    echo -e "mysql-files exists!"
else
    create_mysql_files_dir
fi

function multi_init_mysql {
    echo -e "multi init 5.7..."

    #$1代表传递给此函数的第1个参数
    for dir_name in data{$1..$2}
    do
        dir=$data_dir/$dir_name
        $bin_dir/mysqld --initialize --user=mysql --datadir=$dir >$data_dir/init_$dir_name.log 2>&1
        sleep 2
        $bin_dir/mysql_ssl_rsa_setup --datadir=$dir
        sleep 2
    done
}

function single_init_mysql {
    echo -e "single init 5.7..."

    dir=$data_dir/data$1
    #注意init_data$1.log不能存放在$dir数据目录下，否则会报初始化错误
    #错误信息输出到init_data$1.log
    #先把标准输出重定向到文件，再把标准错误重定向到标准输出
    $bin_dir/mysqld --initialize --user=mysql --datadir=$dir >$data_dir/init_data$1.log 2>&1
    sleep 2
    $bin_dir/mysql_ssl_rsa_setup
}

#初始化
if [ $2 = "multi" ]
then
    #将数据目录编号作为参数传递
    multi_init_mysql $3 $4
else
    single_init_mysql $3
fi

chown -R root .
chown -R mysql:mysql mysql-files

if [ $2 = "multi" ]
then
    #在初始化后创建mysql-files，否则会报错，datadir下存在文件，初始化失败
    cd $data_dir
    for dir_name in data{$3..$4}
    do
        cd $dir_name
        #create_mysql_files_dir
        cd ..
    done
fi

#修改/etc/init.d/mysql*.server，设置basedir=/usr/local/mysql/mysql_5.7，datadir=/var/data/mysql/datax
#通过mysqladmin shutdown可以关闭MySQL实例
#
#如果报错Unit mysql.server.service not found
#执行systemctl start mysql.server.service
#
#如果/etc/init.d/mysql.server start启动失败，error.log也没有ERROR
#执行systemctl restart mysql.server.service
cp $mysql_install_dir/$mysql_link/support-files/mysql*.server /etc/init.d/$ctrl_script

#启动实例
echo -e "start mysql..."
if [ $2 = "multi" ]
then
    $bin_dir/mysqld_multi start
else
    #见mysqld_safe --help
    $bin_dir/mysqld_safe --user=mysql --ledir=$mysql_install_dir/$mysql_link/bin &
fi

#睡眠2s，等待mysqld启动完毕，否则会报告mysql无法通过/tmp/mysql.sock连接到mysqld
sleep 2

#5.7使用临时密码登录，重新设置密码
echo -n "enter your new password: "
read password

if [ $2 = "multi" ]
then
    for num in {$3..$4}
    do
        tmp_password=$(cat $data_dir/data$num/error.log | grep "A temporary password is generated for" | awk -F' ' '{print $NF}')
        echo $tmp_password

        $bin_dir/mysql --connect-expired-password -uroot -p$tmp_password -S/tmp/mysql.sock$num -e"set password='$password';
                                                                                                create user 'multi_admin'@'localhost' identified by '$password';
                                                                                                grant shutdown on *.* to 'multi_admin'@'localhost';
                                                                                                grant all privileges on *.* to 'root'@'%' identified by '$password';"
    done
else
    tmp_password=$(cat $data_dir/data$3/error.log | grep "A temporary password is generated for" | awk -F' ' '{print $NF}')
    echo $tmp_password

    #修改用户密码
    #set password for 'multi_admin'@'localhost' = password('Pyl123456');
    #注意-e中要使用单引号
    $bin_dir/mysql --connect-expired-password -uroot -p$tmp_password -e"set password='$password';
                                                                        create user 'multi_admin'@'localhost' identified by '$password';
                                                                        grant shutdown on *.* to 'multi_admin'@'localhost';
                                                                        grant all privileges on *.* to 'root'@'%' identified by '$password';"
fi

exit
