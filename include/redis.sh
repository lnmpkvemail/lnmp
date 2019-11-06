#!/bin/bash

Install_Redis()
{
    echo "====== Installing Redis ======"
    echo "Install ${Redis_Stable_Ver} Stable Version..."
    Press_Start

    rm -f ${PHP_Path}/conf.d/007-redis.ini
    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}redis.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cd ${cur_dir}/src
    if [ -s /usr/local/redis/bin/redis-server ]; then
        echo "Redis server already exists."
    else
        Download_Files http://download.redis.io/releases/${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}.tar.gz
        Tar_Cd ${Redis_Stable_Ver}.tar.gz ${Redis_Stable_Ver}

        Get_OS_Bit
        Get_ARM
        if [ "${Is_ARM}" = "y" ]; then
            sed -i 's/FINAL_LIBS=-lm/FINAL_LIBS=-lm -latomic/' src/Makefile
        fi
        if [[ "${Is_64bit}" = "y" || "${Is_ARM}" = "y" ]]; then
            make PREFIX=/usr/local/redis install
        else
            make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
        fi
        mkdir -p /usr/local/redis/etc/
        \cp redis.conf  /usr/local/redis/etc/
        sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
        if ! grep -Eqi '^bind[[:space:]]*127.0.0.1' /usr/local/redis/etc/redis.conf; then
            sed -i 's/^# bind 127.0.0.1/bind 127.0.0.1/g' /usr/local/redis/etc/redis.conf
        fi
        sed -i 's#^pidfile /var/run/redis_6379.pid#pidfile /var/run/redis.pid#g' /usr/local/redis/etc/redis.conf
        cd ../
        rm -rf ${cur_dir}/src/${Redis_Stable_Ver}

        if command -v iptables >/dev/null 2>&1; then
            if iptables -C INPUT -i lo -j ACCEPT; then
                iptables -A INPUT -p tcp --dport 6379 -j DROP
                if [ "$PM" = "yum" ]; then
                    service iptables save
                    service iptables reload
                elif [ "$PM" = "apt" ]; then
                    if [ -s /etc/init.d/netfilter-persistent ]; then
                        /etc/init.d/netfilter-persistent save
                        /etc/init.d/netfilter-persistent reload
                    else
                        /etc/init.d/iptables-persistent save
                        /etc/init.d/iptables-persistent reload
                    fi
                fi
            fi
        fi
    fi

    if [ -s ${PHPRedis_Ver} ]; then
        rm -rf ${PHPRedis_Ver}
    fi

    if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.';then
        Download_Files http://pecl.php.net/get/redis-2.2.7.tgz redis-2.2.7.tgz
        Tar_Cd redis-2.2.7.tgz redis-2.2.7
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.[3456].';then
        Download_Files http://pecl.php.net/get/redis-4.3.0.tgz redis-4.3.0.tgz
        Tar_Cd redis-4.3.0.tgz redis-4.3.0
    else
        Download_Files http://pecl.php.net/get/${PHPRedis_Ver}.tgz ${PHPRedis_Ver}.tgz
        Tar_Cd ${PHPRedis_Ver}.tgz ${PHPRedis_Ver}
    fi
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config
    Make_Install
    cd ../

    cat >${PHP_Path}/conf.d/007-redis.ini<<EOF
extension = "redis.so"
EOF

    \cp ${cur_dir}/init.d/init.d.redis /etc/init.d/redis
    chmod +x /etc/init.d/redis
    echo "Add to auto startup..."
    StartUp redis
    Restart_PHP
    /etc/init.d/redis start

    if [ -s "${zend_ext}" ] && [ -s /usr/local/redis/bin/redis-server ]; then
        Echo_Green "====== Redis install completed ======"
        Echo_Green "Redis installed successfully, enjoy it!"
    else
        rm -f ${PHP_Path}/conf.d/007-redis.ini
        Echo_Red "Redis install failed!"
    fi
}

Uninstall_Redis()
{
    echo "You will uninstall Redis..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/007-redis.ini
    Restart_PHP
    Remove_StartUp redis
    echo "Delete Redis files..."
    rm -rf /usr/local/redis
    rm -rf /etc/init.d/redis
    if command -v iptables >/dev/null 2>&1; then
        iptables -D INPUT -p tcp --dport 6379 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
            service iptables reload
        elif [ "$PM" = "apt" ]; then
            if [ -s /etc/init.d/netfilter-persistent ]; then
                /etc/init.d/netfilter-persistent save
                /etc/init.d/netfilter-persistent reload
            else
                /etc/init.d/iptables-persistent save
                /etc/init.d/iptables-persistent reload
            fi
        fi
    fi
    Echo_Green "Uninstall Redis completed."
}
