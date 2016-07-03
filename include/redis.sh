#!/bin/bash

Install_Redis()
{
    echo "====== Installing Redis ======"
    echo "Install ${Redis_Stable_Ver} Stable Version..."
    Press_Install

    sed -i '/redis.so/d' /usr/local/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}redis.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cd ${cur_dir}/src
    Download_Files http://download.redis.io/releases/${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}.tar.gz
    Tar_Cd ${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}

    if [ "${Is_64bit}" = "y" ] ; then
        make PREFIX=/usr/local/redis install
    else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
    fi
    mkdir -p /usr/local/redis/etc/
    \cp redis.conf  /usr/local/redis/etc/
    sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
    sed -i 's/^# bind 127.0.0.1/bind 127.0.0.1/g' /usr/local/redis/etc/redis.conf
    cd ../
    rm -rf ${cur_dir}/src/${Redis_Stable_Ver}

    if [ -s /sbin/iptables ]; then
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

    if echo "${Cur_PHP_Version}" | grep -Eqi '^7.';then
        cd ${cur_dir}/src
        rm -rf phpredis
        git clone -b php7 https://github.com/phpredis/phpredis.git
        cd phpredis
    else
        Download_Files http://pecl.php.net/get/${PHPRedis_Ver}.tgz ${PHPRedis_Ver}.tgz
        Tar_Cd ${PHPRedis_Ver}.tgz ${PHPRedis_Ver}
    fi
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

    if [ -s "${zend_ext}" ] && [ -s /usr/local/redis/bin/redis-server ]; then
        echo "====== Redis install completed ======"
        echo "Redis installed successfully, enjoy it!"
    else
        sed -i '/redis.so/d' /usr/local/php/etc/php.ini
        echo "Redis install failed!"
    fi
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
        /sbin/iptables -D INPUT -p tcp --dport 6379 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi
    echo "Uninstall Redis completed."
}
