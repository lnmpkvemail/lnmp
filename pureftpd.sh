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

. lnmp.conf
. include/main.sh
. include/init.sh

Get_OS_Bit
Get_Dist_Name

Install_Pureftpd()
{
    Press_Install

    echo "Download files..."
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/ftp/pure-ftpd/${Pureftpd_Ver}.tar.gz ${Pureftpd_Ver}.tar.gz

    echo "Installing pure-ftpd..."
    Tar_Cd ${Pureftpd_Ver}.tar.gz ${Pureftpd_Ver}
    ./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg --with-throttling --with-uploadscript --with-language=english --with-rfc2640 --with-ftpwho --with-tls

    make && make install

    echo "Copy configure files..."
    \cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin/
    chmod 755 /usr/local/pureftpd/sbin/pure-config.pl
    mkdir /usr/local/pureftpd/etc
    \cp ${cur_dir}/conf/pure-ftpd.conf /usr/local/pureftpd/etc/pure-ftpd.conf
    \cp ${cur_dir}/init.d/init.d.pureftpd /etc/init.d/pureftpd
    chmod +x /etc/init.d/pureftpd
    touch /usr/local/pureftpd/etc/pureftpd.passwd
    touch /usr/local/pureftpd/etc/pureftpd.pdb

    StartUp pureftpd

    cd ..
    rm -rf ${cur_dir}/src/${Pureftpd_Ver}

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT 7 -p tcp --dport 20 -j ACCEPT
        /sbin/iptables -I INPUT 8 -p tcp --dport 21 -j ACCEPT
        /sbin/iptables -I INPUT 9 -p tcp --dport 20000:30000 -j ACCEPT
        if [ "${PM}" = "yum" ]; then
            service iptables save
        elif [ "${PM}" = "apt" ]; then
            /sbin/iptables-save > /etc/iptables.rules
        fi
    fi

    if [[ -s /usr/local/pureftpd/sbin/pure-config.pl && -s /usr/local/pureftpd/etc/pure-ftpd.conf && -s /etc/init.d/pureftpd ]]; then
        echo "Starting pureftpd..."
        /etc/init.d/pureftpd start
        echo "+----------------------------------------------------------------------+"
        echo "| Install Pure-FTPd completed,enjoy it!"
        echo "| =>use command: lnmp ftp {add|list|del} to manage FTP users."
        echo "+----------------------------------------------------------------------+"
        echo "| For more information please visit http://www.lnmp.org"
        echo "+----------------------------------------------------------------------+"
    else
        Echo_Red "Pureftpd install failed!"
    fi
}

Uninstall_Pureftpd()
{
    if [ ! -f /usr/local/pureftpd/sbin/pure-config.pl ]; then
        echo "Pureftpd was not installed!"
        exit 1
    fi
    echo "Stop pureftpd..."
    /etc/init.d/pureftpd stop
    echo "Remove service..."
    Remove_StartUp pureftpd
    echo "Delete files..."
    rm -f /etc/init.d/pureftpd
    rm -rf /usr/local/pureftpd
    echo "Pureftpd uninstall completed."
}

if [ "${action}" = "uninstall" ]; then
    Uninstall_Pureftpd
else
    Install_Pureftpd 2>&1 | tee /root/pureftpd-install.log
fi
