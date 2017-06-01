#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!"
    exit 1
fi

echo "+-------------------------------------------------------------------+"
echo "|   Reset MySQL/MariaDB root Password for LNMP, Written by Licess   |"
echo "+-------------------------------------------------------------------+"
echo "|       A tool to reset MySQL/MariaDB root password for LNMP        |"
echo "+-------------------------------------------------------------------+"
echo "|       For more information please visit https://lnmp.org          |"
echo "+-------------------------------------------------------------------+"
echo "|           Usage: ./reset_mysql_root_password.sh                   |"
echo "+-------------------------------------------------------------------+"

if [ -s /usr/local/mariadb/bin/mysql ]; then
    M_Name="mariadb"
else
    M_Name="mysql"
fi

cur_mysql_version=`/usr/local/mysql/bin/mysql -V | awk '{print $5}' | tr -d ","`

mysql_root_password=""
read -p "Enter New MySQL root password: " mysql_root_password
if [ "${mysql_root_password}" = "" ]; then
    echo "Error: Password can't be NULL!!"
    exit 1
fi

echo "Stoping MySQL..."
/etc/init.d/${M_Name} stop
echo "Starting MySQL with skip grant tables"
/usr/local/${M_Name}/bin/mysqld_safe --skip-grant-tables >/dev/null 2>&1 &
echo "using mysql to flush privileges and reset password"
sleep 5
echo "update user set password = Password('${mysql_root_password}') where User = 'root'"
if echo "${cur_mysql_version}" | grep -Eqi '^5.7.'; then
    /usr/local/${M_Name}/bin/mysql -u root mysql << EOF
update user set authentication_string = Password('${mysql_root_password}') where User = 'root';
EOF
else
    /usr/local/${M_Name}/bin/mysql -u root mysql << EOF
update user set password = Password('${mysql_root_password}') where User = 'root';
EOF
fi

if [ $? -eq 0 ]; then
    echo "Password reset succesfully. Now killing mysqld softly"
    killall mysqld
    sleep 5
    echo "Restarting the actual mysql service"
    /etc/init.d/${M_Name} start
    echo "Password successfully reset to '${mysql_root_password}'"
else
    echo "Reset MySQL root password failed!"
fi
