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

Get_Dist_Name
Check_Stack
Check_DB

echo "+--------------------------------------------------+"
echo "|  A tool to upgrade lnmp manager from 1.x to 1.4  |"
echo "+--------------------------------------------------+"
echo "|For more information please visit https://lnmp.org|"
echo "+--------------------------------------------------+"

if [ "${Get_Stack}" == "unknow" ]; then
    Echo_Red "Can't get stack info."
    exit
elif [ "${Get_Stack}" == "lnmp" ]; then
    if [ "$PM" = "yum" ]; then
        Echo_Blue "[+] Yum installing dependent packages..."
        for packages in patch wget crontabs unzip tar ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz expat-devel;
        do yum -y install $packages; done
    elif [ "$PM" = "apt" ]; then
        apt-get update -y
        for packages in debian-keyring debian-archive-keyring build-essential bison libkrb5-dev libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libcap-dev ca-certificates libc-client2007e-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt libxslt1-dev libc-client-dev xz-utils libexpat1-dev;
        do apt-get --no-install-recommends install -y $packages; done
    fi
    \cp ${cur_dir}/conf/lnmp /bin/lnmp
    chmod +x /bin/lnmp
    if [ ! -s /usr/local/nginx/conf/enable-php.conf ]; then
        \cp conf/enable-php.conf /usr/local/nginx/conf/enable-php.conf
    fi
    if [ ! -s /usr/local/nginx/conf/pathinfo.conf ]; then
        \cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf
    fi
    if [ ! -s /usr/local/nginx/conf/enable-php-pathinfo.conf ]; then
        \cp conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php-pathinfo.conf
    fi
    if [ ! -f /usr/local/nginx/conf/none.conf ]; then
        \cp conf/rewrite/none.conf /usr/local/nginx/conf/none.conf
    fi
elif [ "${Get_Stack}" == "lnmpa" ]; then
    \cp ${cur_dir}/conf/lnmpa /bin/lnmp
    chmod +x /bin/lnmp
    \cp conf/proxy.conf /usr/local/nginx/conf/proxy.conf
    if [ ! -s /usr/local/nginx/conf/proxy-pass-php.conf ]; then
        \cp conf/proxy-pass-php.conf /usr/local/nginx/conf/proxy-pass-php.conf
    fi
elif [ "${Get_Stack}" == "lamp" ]; then
    \cp ${cur_dir}/conf/lamp /bin/lnmp
    chmod +x /bin/lnmp
    if /usr/local/apache/bin/httpd -v|grep -Eqi "Apache/2.2."; then
        \cp ${cur_dir}/conf/httpd22-ssl.conf  /usr/local/apache/conf/extra/httpd-ssl.conf
    elif /usr/local/apache/bin/httpd -v|grep -Eqi "Apache/2.4."; then
        \cp ${cur_dir}/conf/httpd24-ssl.conf  /usr/local/apache/conf/extra/httpd-ssl.conf
        sed -i 's/^#LoadModule socache_shmcb_module/LoadModule socache_shmcb_module/g' /usr/local/apache/conf/httpd.conf
        sed -i 's/^LoadModule lbmethod_heartbeat_module/#LoadModule lbmethod_heartbeat_module/g' /usr/local/apache/conf/httpd.conf
    fi
fi

if [ "${DB_Name}" = "mariadb" ]; then
    sed -i 's#/etc/init.d/mysql#/etc/init.d/mariadb#' /bin/lnmp
elif [ "${DB_Name}" = "None" ]; then
    sed -i 's#/etc/init.d/mysql.*##' /bin/lnmp
fi

Echo_Green "upgrade lnmp manager complete."