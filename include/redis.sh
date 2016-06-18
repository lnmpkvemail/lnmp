#!/bin/bash

Install_Redis()
{
    ver="1"
    echo "Which version do you want to install:"
    echo "Install Redis 3.0.1   Stable Version please type: 1"
    echo "Install Redis 2.8.20  Old Version please type: 2"
    read -p "Enter 1 or 2 (Default Stable version): " ver
    if [ "${ver}" = "" ]; then
        ver="1"
    fi

    if [ "${ver}" = "1" ]; then
        echo "You will install Redis 3.0.1   Stable Version"
    elif [ "${ver}" = "2" ]; then
        echo "You will install Redis 2.8.20  Old Version"
    else
        echo "Input error,please input 1 or 2 !"
        echo "Please Rerun $0"
        exit 1
    fi

    echo "====== Installing Redis ======"
    Press_Install
    
    sed -i '/redis.so/d' /usr/local/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}redis.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cd ${cur_dir}/src
    if [ "${ver}" = "1" ]; then
        Download_Files http://download.redis.io/releases/${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}.tar.gz
        Tar_Cd ${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}
    else
        Download_Files http://download.redis.io/releases/${Redis_Old_Ver}.tar.gz ${Redis_Old_Ver}.tar.gz
        Tar_Cd ${Redis_Old_Ver}.tar.gz ${Redis_Old_Ver}
    fi

    if [ "${Is_64bit}" = "y" ] ; then
        make PREFIX=/usr/local/redis install
    else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
    fi
    mkdir -p /usr/local/redis/etc/
    \cp redis.conf  /usr/local/redis/etc/
    sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
    sed -i 's/# bind 127.0.0.1/bind 127.0.0.1/g' /usr/local/redis/etc/redis.conf
    cd ../

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp -s 127.0.0.1 --dport 6379 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp --dport 6379 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi

    if [ -s ${PHPRedis_Ver} ]; then
        rm -rf ${PHPRedis_Ver}
    fi

    Download_Files http://pecl.php.net/get/${PHPRedis_Ver}.tgz ${PHPRedis_Ver}.tgz
    Tar_Cd ${PHPRedis_Ver}.tgz ${PHPRedis_Ver}
    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install
    cd ../

sed -i '/the dl()/i\
extension = "redis.so"' /usr/local/php/etc/php.ini

    \cp ${cur_dir}/init.d/init.d.redis /etc/init.d/redis
    chmod +x /etc/init.d/redis
    echo "Add to auto start..."
    StartUp redis
    Restart_PHP
    /etc/init.d/redis start

    echo "====== Redis install completed ======"
    echo "Redis installed successfully, enjoy it!"
}

Uninstall_Redis()
{
    echo "You will uninstall Redis..."
    Press_Start
    sed -i '/redis.so/d' /usr/local/php/etc/php.ini
    Restart_PHP
    Remove_StartUp redis
    echo "Delete Redis files..."
    rm -rf /usr/local/redis
    rm -rf /etc/init.d/redis
    if [ -s /sbin/iptables ]; then
        /sbin/iptables -D INPUT -p tcp -s 127.0.0.1 --dport 6379 -j ACCEPT
        /sbin/iptables -D INPUT -p tcp --dport 6379 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi
    echo "Uninstall Redis completed."
}