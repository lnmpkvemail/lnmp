#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!"
    exit 1
fi
clear
echo "+----------------------------------------------------------+"
echo "|          Pureftpd for LNMP,  Written by Licess           |"
echo "+----------------------------------------------------------+"
echo "|This script is a tool to install pureftpd for LNMP        |"
echo "+----------------------------------------------------------+"
echo "|For more information please visit http://www.lnmp.org     |"
echo "+----------------------------------------------------------+"
echo "|Usage: ./pureftpd.sh                                      |"
echo "+----------------------------------------------------------+"
cur_dir=$(pwd)
action=$1
. include/main.sh
. include/init.sh

Get_OS_Bit
Get_Dist_Name
Check_DB

Check_Pureftpd()
{
    if [ ! -f /usr/local/pureftpd/sbin/pure-config.pl ]; then
        echo "Pureftpd was not installed!"
        exit 1
    fi
}

Install_Pureftpd()
{
    Verify_DB_Password

#set password of User manager

    Ftp_Manager_Pwd=""
    read -p "Please enter password of User manager: " Ftp_Manager_Pwd
    if [ "${Ftp_Manager_Pwd}" = "" ]; then
        echo "password of User manager can't be NULL!"
        exit 1
    else
    echo "=================================================="
    echo "Your password of User manager:${Ftp_Manager_Pwd}"
    echo "=================================================="
    fi

#set password of mysql ftp user

    Ftp_DB_Pwd=""
    read -p "Please enter password of mysql ftp user: " Ftp_DB_Pwd
    if [ "${Ftp_DB_Pwd}" = "" ]; then
        echo "password of User manager can't be NULL."
        echo "script will randomly generated a password."
        Ftp_DB_Pwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
    echo "================================================"
    echo "Your password of mysql ftp user:${Ftp_DB_Pwd}"
    echo "================================================"
    fi

    Press_Install

    echo "Download files..."
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/ftp/pure-ftpd/${Pureftpd_Ver}.tar.gz ${Pureftpd_Ver}.tar.gz
    Download_Files ${Download_Mirror}/ftp/pure-ftpd/${Pureftpd_Manager_Ver}.zip ${Pureftpd_Manager_Ver}.zip

    if [ -s /var/lib/mysql/mysql.sock ]; then
    ln -sf /tmp/mysql.sock /var/lib/mysql/mysql.sock
    fi

    echo "Installing pure-ftpd..."
    Tar_Cd ${Pureftpd_Ver}.tar.gz ${Pureftpd_Ver}
    ./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=${MySQL_Dir} --with-quotas --with-cookie --with-virtualhosts --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg --with-throttling --with-uploadscript --with-language=english --with-rfc2640

    make && make install

    echo "Copy configure files..."
    \cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin/
    chmod 755 /usr/local/pureftpd/sbin/pure-config.pl
    \cp $cur_dir/conf/pureftpd-mysql.conf /usr/local/pureftpd/
    \cp $cur_dir/conf/pure-ftpd.conf /usr/local/pureftpd/

    echo "Modify parameters of pureftpd configures..."
    sed -i 's/127.0.0.1/localhost/g' /usr/local/pureftpd/pureftpd-mysql.conf
    sed -i 's/Ftp_DB_Pwd/'${Ftp_DB_Pwd}'/g' /usr/local/pureftpd/pureftpd-mysql.conf
    \cp $cur_dir/conf/pureftpd-script.sql /tmp/pureftpd-script.sql
    sed -i 's/Ftp_DB_Pwd/'${Ftp_DB_Pwd}'/g' /tmp/pureftpd-script.sql
    sed -i 's/Ftp_Manager_Pwd/'${Ftp_Manager_Pwd}'/g' /tmp/pureftpd-script.sql

    echo "Import pureftpd database..."
    ${MySQL_Bin} -u root -p${DB_Root_Password} -h localhost < /tmp/pureftpd-script.sql
    Is_SQL_Import=$?

    echo "Installing GUI User manager for PureFTPd..."
    cd ${cur_dir}/src
    unzip -q ${Pureftpd_Manager_Ver}.zip
    mv ftp /home/wwwroot/default/
    chmod 777 -R /home/wwwroot/default/ftp/
    chown www -R /home/wwwroot/default/ftp/

    echo "Modify parameters of GUI User manager for PureFTPd..."
    www_uid=`id -u www`
    www_gid=`id -g www`
    sed -i 's/\$DEFUserID.*/\$DEFUserID = "'${www_uid}'";/g' /home/wwwroot/default/ftp/config.php
    sed -i 's/\$DEFGroupID.*/\$DEFGroupID = "'${www_gid}'";/g' /home/wwwroot/default/ftp/config.php
    sed -i 's/English/Chinese/g' /home/wwwroot/default/ftp/config.php
    sed -i 's/tmppasswd/'${Ftp_DB_Pwd}'/g' /home/wwwroot/default/ftp/config.php
    sed -i 's/127.0.0.1/localhost/g' /home/wwwroot/default/ftp/config.php
    sed -i 's/myipaddress.com/localhost/g' /home/wwwroot/default/ftp/config.php
    mv /home/wwwroot/default/ftp/install.php /home/wwwroot/default/ftp/install.php.bak
    rm -f /tmp/pureftpd-script.sql

    \cp $cur_dir/init.d/init.d.pureftpd /etc/init.d/pureftpd
    chmod +x /etc/init.d/pureftpd

    StartUp pureftpd

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
        /sbin/iptables -I INPUT -p tcp --dport 20 -j ACCEPT
        /sbin/iptables -I INPUT -p tcp --dport 20000:30000 -j ACCEPT
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi

    if [[ -s /usr/local/pureftpd/sbin/pure-config.pl && -s /usr/local/pureftpd/pure-ftpd.conf && -s /etc/init.d/pureftpd && ${Is_SQL_Import} -eq 0 ]]; then
        echo "Starting pureftpd..."
        /etc/init.d/pureftpd start
        echo "+----------------------------------------------------------------------+"
        echo "| Install Pure-FTPd completed,enjoy it!"
        echo "| =>Now you enter http://IP/ftp/ in you Web Browser to manage FTP users."
        echo "| =>Or use command: lnmp ftp {add|list|del} to manage FTP users."
        echo "| =>password of User manager was:${Ftp_Manager_Pwd}"
        echo "| =>password of mysql ftp user was:${Ftp_DB_Pwd}"
        echo "+----------------------------------------------------------------------+"
        echo "| For more information please visit http://www.lnmp.org"
        echo "+----------------------------------------------------------------------+"
    else
        Echo_Red "Pureftpd install failed!"
    fi
}

Uninstall_Pureftpd()
{
    Check_Pureftpd
    echo "Stop pureftpd..."
    /etc/init.d/pureftpd stop
    echo "Remove service..."
    Remove_StartUp pureftpd
    echo "Delete files..."
    rm -f /etc/init.d/pureftpd
    rm -rf /usr/local/pureftpd
    rm -rf /home/wwwroot/default/ftp
    echo "Pureftpd uninstall completed."
}

if [ "${action}" == "uninstall" ]; then
    Uninstall_Pureftpd
else
    Install_Pureftpd 2>&1 | tee /root/pureftpd-install.log
fi