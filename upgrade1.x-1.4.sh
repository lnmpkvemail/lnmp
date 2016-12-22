#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script"
    exit 1
fi

cur_dir=$(pwd)

. lnmp.conf
. include/main.sh

Check_Stack
Check_DB

echo "+--------------------------------------------------+"
echo "|  A tool to upgrade lnmp manager from 1.x to 1.4  |"
echo "+--------------------------------------------------+"
echo "|For more information please visit https://lnmp.org|"
echo "+--------------------------------------------------+"

if [ "${Get_Stack}" == "unknow" ];then
    Echo_Red "Can't get stack info."
    exit
elif [ "${Get_Stack}" == "lnmp" ];then
    \cp ${cur_dir}/conf/lnmp /bin/lnmp
    chmod +x /bin/lnmp
elif [ "${Get_Stack}" == "lnmpa" ];then
    \cp ${cur_dir}/conf/lnmpa /bin/lnmp
    chmod +x /bin/lnmp
elif [ "${Get_Stack}" == "lamp" ];then
    \cp ${cur_dir}/conf/lamp /bin/lnmp
    chmod +x /bin/lnmp
fi

if [ "${DB_Name}" = "mariadb" ]; then
    sed -i 's#/etc/init.d/mysql#/etc/init.d/mariadb#' /bin/lnmp
elif [ "${DB_Name}" = "None" ]; then
    sed -i 's#/etc/init.d/mysql.*##' /bin/lnmp
fi

Echo_Green "upgrade lnmp manager complete."