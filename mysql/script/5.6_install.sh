#!/bin/zsh

#此脚本需要切换到root下执行

#判断脚本执行时所带的参数是否符合规范
function usage() {
    echo "usage: ./5.6_install.sh mysql-5.x.x.tar.gz single/multi data_start data_end"
    exit
}

function usage_multi() {
    echo "usage: ./5.6_install.sh mysql-5.x.x.tar.gz multi data_start data_end"
    exit
}

function usage_single() {
    echo "usage: ./5.6_install.sh mysql-5.x.x.tar.gz single"
    exit
}

[ $# = 0 ] || [ $# = 1 ] || [ $# = 3 ] || [ $# -gt 4 ] && usage

if [ $# = 2 ] && [ $2 != "single" ]
then
    [ $2 = "multi" ] && usage_multi

    usage_single
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

mysql_dir=$(echo `basename $1` | sed "s/.tar.gz//g")
#判断MySQL版本
version=$(echo $mysql_dir | cut -d '-' -f 2 | cut -d '.' -f 1,2)

if [ $version != "5.6" ]
then
    echo "sorry, mysql verson is not 5.6"
    exit
fi

#安装依赖软件包
apt-get -y install libaio1

mysql_install_dir=/usr/local

#创建用户组和用户
echo "\nmysql group and user check\n"

grpchk=$(cat /etc/group | grep mysql)

#[]中必须有空格，否则报错
if [ $? -eq 0 ]
then
    echo "group mysql exists!\n"
else
    echo "add group mysql!\n"
    groupadd mysql
fi

userchk=$(cat /etc/passwd | grep mysql)

if [ $? -eq 0 ]
then
    echo "user mysql exists!\n"
else
    echo "add user mysql!\n"
    #-g表示mysql用户属于mysql用户组
    useradd -r -g mysql mysql
fi

#拷贝配置文件
echo "copy config file to /etc/mysql/my.cnf!\n"
cd `dirname $0`
conf_dir=/etc/mysql

if test -d $conf_dir
then
    rm -rf $conf_dir
fi

mkdir $conf_dir
cp $(pwd)/my.cnf $conf_dir/my.cnf

mysql_link=mysql_5.6_dir
bin_dir=$mysql_install_dir/$mysql_link/bin

#/usr/local/mysql-5.x.x-linux-glibc2.5-x86_64目录存在则不解压
if test -d $mysql_install_dir/$mysql_dir
then
    echo "dir exists!\n"
else
    #解压二进制压缩包
    echo "decompress binary package...\n"
    tar zxf $1 -C$mysql_install_dir

    #切换到/usr/local
    if [ $(pwd) != $mysql_install_dir ]
    then
        cd $mysql_install_dir
    fi

    #创建mysql软链接
    echo "create link...\n"
    ln -s $mysql_dir $mysql_link
fi

#创建data_dir
data_dir=/var/data/mysql
echo "check data dir!\n"
if test -d $data_dir
then
    echo "data dir exists\n"
else
    echo "create data dir\n"
    mkdir -p $data_dir
fi

cd $data_dir

if [ $2 = "multi" ]
then
    mkdir data{$3..$4}
else
    mkdir data_56
fi

#data_dir的用户权限为mysql:mysql
chown -R mysql:mysql $data_dir

#对每个实例进行初始化
cd $mysql_install_dir/$mysql_link
chown -R mysql:mysql .

function multi_init_mysql() {
    echo "multi init 5.6...\n"

    for dir_name in data{$1..$2}
    do
        $bin_dir/../scripts/mysql_install_db --user=mysql --datadir=$data_dir/$dir_name >init_mysql.log 2>&1
        sleep 2
    done
}

function single_init_mysql() {
    echo "single init 5.6...\n"

    $bin_dir/../scripts/mysql_install_db --user=mysql --datadir=$data_dir/data_56 >init_mysql.log 2>&1
}

if [ $2 = "multi" ]
then
    multi_init_mysql $3 $4
else
    single_init_mysql
fi

chown -R root .

#5.6中需要将basedir添加到my.cnf，否则会报错找不到my_print_defaults
cp $mysql_install_dir/$mysql_link/support-files/mysql*.server /etc/init.d/$ctrl_script

#启动实例
echo "start mysql..."
if [ $2 = "multi" ]
then
    $bin_dir/mysqld_multi start
else
    #见mysqld_safe --help
    $bin_dir/mysqld_safe --user=mysql --ledir=$mysql_install_dir/$mysql_link/bin &
fi

#睡眠2s，等待mysqld启动完毕，否则会报告mysql无法通过/tmp/mysql.sock连接到mysqld
sleep 2

echo -n "enter your new password: "
read password

if [ $2 = "multi" ]
then
    for num in {$3..$4}
    do
        $bin_dir/mysql -uroot -S/tmp/mysql.sock$num -e"grant all privileges on *.* to root@'127.0.0.1' identified by '$password' with grant option;
                                                    grant all privileges on *.* to root@'localhost' identified by '$password' with grant option;
                                                    create user 'multi_admin'@'localhost' identified by '$password';
                                                    grant shutdown on *.* to 'multi_admin'@'localhost';";
    done
else
    $bin_dir/mysql -uroot -e "grant all privileges on *.* to root@'127.0.0.1' identified by '$password' with grant option;
                            grant all privileges on *.* to root@'localhost' identified by '$password' with grant option;";
fi

exit