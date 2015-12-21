#!/bin/bash

Install_PHPMemcache()
{
    echo "Install memcache php extension..."
    cd ${cur_dir}/src
    if echo "${Cur_PHP_Version}" | grep -Eqi '^7.';then
        rm -rf pecl-memcache
        git clone https://github.com/websupport-sk/pecl-memcache.git
        cd pecl-memcache
    else
        Download_Files ${Download_Mirror}/web/memcache/${PHPMemcache_Ver}.tgz ${PHPMemcache_Ver}.tgz
        Tar_Cd ${PHPMemcache_Ver}.tgz ${PHPMemcache_Ver}
    fi
    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install
    cd ../
}

Install_PHPMemcached()
{
    echo "Install memcached php extension..."
    cd ${cur_dir}/src
    Get_Dist_Name
    if [ "$PM" = "yum" ]; then
        yum install cyrus-sasl-devel -y
        Get_Dist_Version
        if echo "${CentOS_Version}" | grep -Eqi '^5.'; then
            yum install gcc44 gcc44-c++ libstdc++44-devel -y
            export CC="gcc44"
            export CXX="g++44"
        fi
    elif [ "$PM" = "apt" ]; then
        apt-get install libsasl2-2 sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules -y
    fi
    Download_Files ${Download_Mirror}/web/libmemcached/${Libmemcached_Ver}.tar.gz
    Tar_Cd ${Libmemcached_Ver}.tar.gz ${Libmemcached_Ver}
    ./configure --prefix=/usr/local/libmemcached --with-memcached
    make && make install
    cd ../

    if echo "${Cur_PHP_Version}" | grep -Eqi '^7.';then
        cd ${cur_dir}/src
        rm -rf php-memcached
        git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git
        cd php-memcached
    else
        Download_Files ${Download_Mirror}/web/php-memcached/${PHPMemcached_Ver}.tgz ${PHPMemcached_Ver}.tgz
        Tar_Cd ${PHPMemcached_Ver}.tgz ${PHPMemcached_Ver}
    fi
    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config --enable-memcached --with-libmemcached-dir=/usr/local/libmemcached
    make && make install
    cd ../
}

Install_Memcached()
{
    ver="1"
    echo "Which memcached php extension do you choose:"
    echo "Install php-memcache,(Discuz x) please enter: 1"
    echo "Install php-memcached, please enter: 2"
    read -p "Enter 1 or 2 (Default 1): " ver

    if [ "${ver}" = "1" ]; then
        echo "You choose php-memcache"
        PHP_ZTS="memcache.so"
    elif [ "${ver}" = "2" ]; then
        echo "You choose php-memcached"
        PHP_ZTS="memcached.so"
    else
        ver="1"
        echo "You choose php-memcache"
        PHP_ZTS="memcache.so"
    fi

    echo "====== Installing memcached ======"
    Press_Install

    sed -i '/memcache.so/d' /usr/local/php/etc/php.ini
    sed -i '/memcached.so/d' /usr/local/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext=${zend_ext_dir}${PHP_ZTS}
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.';then
        sed -i "/extension_dir =/a\
extension = \"${PHP_ZTS}\"" /usr/local/php/etc/php.ini
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.[3456].' || echo "${Cur_PHP_Version}" | grep -Eqi '^7.';then
        sed -i "/the dl()/i\
extension = \"${PHP_ZTS}\"" /usr/local/php/etc/php.ini
    else
        echo "Error: can't get php version!"
        echo "Maybe php was didn't install or php configuration file has errors.Please check."
        sleep 3
        exit 1
    fi

    echo "Install memcached..."
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/memcached/${Memcached_Ver}.tar.gz ${Memcached_Ver}.tar.gz
    Tar_Cd ${Memcached_Ver}.tar.gz ${Memcached_Ver}
    ./configure --prefix=/usr/local/memcached
    make &&make install
    cd ../
    rm -rf ${cur_dir}/src/${Memcached_Ver}

    ln -sf /usr/local/memcached/bin/memcached /usr/bin/memcached

    \cp ${cur_dir}/init.d/init.d.memcached /etc/init.d/memcached
    chmod +x /etc/init.d/memcached
    useradd -s /sbin/nologin nobody

    if [ ! -d /var/lock/subsys ]; then
      mkdir -p /var/lock/subsys
    fi

    StartUp memcached

    if [ "${ver}" = "1" ]; then
        Install_PHPMemcache
    elif [ "${ver}" = "2" ]; then
        Install_PHPMemcached
    fi

    echo "Copy Memcached PHP Test file..."
    \cp ${cur_dir}/conf/memcached${ver}.php ${Default_Website_Dir}/memcached.php

    Restart_PHP

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -A INPUT -p tcp --dport 11211 -j DROP
        /sbin/iptables -A INPUT -p udp --dport 11211 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi

    echo "Starting Memcached..."
    /etc/init.d/memcached start

    if [ -s "${zend_ext}" ] && [ -s /usr/local/memcached/bin/memcached ]; then
        echo "====== Memcached install completed ======"
        echo "Memcached installed successfully, enjoy it!"
    else
        sed -i "/${PHP_ZTS}/d" /usr/local/php/etc/php.ini
        echo "Memcached install failed!"
    fi
}

Uninstall_Memcached()
{
    echo "You will uninstall Memcached..."
    Press_Start
    sed -i '/memcache.so/d' /usr/local/php/etc/php.ini
    sed -i '/memcached.so/d' /usr/local/php/etc/php.ini
    Restart_PHP
    Remove_StartUp memcached
    echo "Delete Memcached files..."
    rm -rf /usr/local/libmemcached
    rm -rf /usr/local/memcached
    rm -rf /etc/init.d/memcached
    rm -rf /usr/bin/memcached
    if [ -s /sbin/iptables ]; then
        /sbin/iptables -D INPUT -p tcp --dport 11211 -j DROP
        /sbin/iptables -D INPUT -p udp --dport 11211 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi
    echo "Uninstall Memcached completed."
}
