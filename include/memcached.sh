#!/usr/bin/env bash

Install_PHPMemcache()
{
    echo "Install memcache php extension..."
    cd ${cur_dir}/src
    if echo "${Cur_PHP_Version}" | grep -Eqi '^8.';then
        Download_Files ${Download_Mirror}/web/memcache/${PHP8Memcache_Ver}.tgz ${PHP8Memcache_Ver}.tgz
        Tar_Cd ${PHP8Memcache_Ver}.tgz ${PHP8Memcache_Ver}
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.';then
        Download_Files ${Download_Mirror}/web/memcache/${PHP7Memcache_Ver}.tgz ${PHP7Memcache_Ver}.tgz
        Tar_Cd ${PHP7Memcache_Ver}.tgz ${PHP7Memcache_Ver}
    else
        if ! gcc -dumpversion|grep -q "^[34]."; then
            export CFLAGS=" -fgnu89-inline"
        fi
        Download_Files ${Download_Mirror}/web/memcache/${PHPMemcache_Ver}.tgz ${PHPMemcache_Ver}.tgz
        Tar_Cd ${PHPMemcache_Ver}.tgz ${PHPMemcache_Ver}
    fi
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config
    Make_Install
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
        if echo "${CentOS_Version}" | grep -Eqi '^5'; then
            yum install gcc44 gcc44-c++ libstdc++44-devel -y
            export CC="gcc44"
            export CXX="g++44"
        fi
    elif [ "$PM" = "apt" ]; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get install libsasl2-2 sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules -y
    fi
    Download_Files ${Download_Mirror}/web/libmemcached/${Libmemcached_Ver}.tar.gz
    Tar_Cd ${Libmemcached_Ver}.tar.gz ${Libmemcached_Ver}
    if gcc -dumpversion|grep -Eq "^[7-9]|1[01]"; then
        patch -p1 < ${cur_dir}/src/patch/libmemcached-1.0.18-gcc7.patch
    fi
    ./configure --prefix=/usr/local/libmemcached --with-memcached
    Make_Install
    cd ../

    cd ${cur_dir}/src
    if echo "${Cur_PHP_Version}" | grep -Eqi '^8.';then
        [[ -d "${PHP8Memcached_Ver}" ]] && rm -rf "${PHP8Memcached_Ver}"
        Download_Files ${Download_Mirror}/web/php-memcached/${PHP8Memcached_Ver}.tgz ${PHP8Memcached_Ver}.tgz
        Tar_Cd ${PHP8Memcached_Ver}.tgz ${PHP8Memcached_Ver}
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.';then
        [[ -d "${PHP7Memcached_Ver}" ]] && rm -rf "${PHP7Memcached_Ver}"
        Download_Files ${Download_Mirror}/web/php-memcached/${PHP7Memcached_Ver}.tgz ${PHP7Memcached_Ver}.tgz
        Tar_Cd ${PHP7Memcached_Ver}.tgz ${PHP7Memcached_Ver}
    else
        [[ -d "${PHPMemcached_Ver}" ]] && rm -rf "${PHPMemcached_Ver}"
        Download_Files ${Download_Mirror}/web/php-memcached/${PHPMemcached_Ver}.tgz ${PHPMemcached_Ver}.tgz
        Tar_Cd ${PHPMemcached_Ver}.tgz ${PHPMemcached_Ver}
    fi
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config --enable-memcached --with-libmemcached-dir=/usr/local/libmemcached
    Make_Install
    cd ../
}

Install_Memcached()
{
    ver="1"
    echo "Which memcached php extension do you choose:"
    echo "Install php-memcache, please enter: 1"
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
    Press_Start

    rm -f ${PHP_Path}/conf.d/005-memcached.ini
    Addons_Get_PHP_Ext_Dir
    zend_ext=${zend_ext_dir}${PHP_ZTS}
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cat >${PHP_Path}/conf.d/005-memcached.ini<<EOF
extension = ${PHP_ZTS}
EOF

    echo "Install memcached..."
    cd ${cur_dir}/src
    if [ -s /usr/local/memcached/bin/memcached ]; then
        echo "Memcached already exists."
    else
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
    fi

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

    if command -v iptables >/dev/null 2>&1; then
        if iptables -C INPUT -i lo -j ACCEPT; then
            iptables -A INPUT -p tcp --dport 11211 -j DROP
            iptables -A INPUT -p udp --dport 11211 -j DROP
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

    echo "Starting Memcached..."
    /etc/init.d/memcached start

    if [ -s "${zend_ext}" ] && [ -s /usr/local/memcached/bin/memcached ]; then
        Echo_Green "====== Memcached install completed ======"
        Echo_Green "Memcached installed successfully, enjoy it!"
    else
        rm -f ${PHP_Path}/conf.d/005-memcached.ini
        Echo_Red "Memcached install failed!"
    fi
}

Uninstall_Memcached()
{
    echo "You will uninstall Memcached..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/005-memcached.ini
    Restart_PHP
    Remove_StartUp memcached
    echo "Delete Memcached files..."
    rm -rf /usr/local/libmemcached
    rm -rf /usr/local/memcached
    rm -rf /etc/init.d/memcached
    rm -rf /usr/bin/memcached
    if command -v iptables >/dev/null 2>&1; then
        iptables -D INPUT -p tcp --dport 11211 -j DROP
        iptables -D INPUT -p udp --dport 11211 -j DROP
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
    Echo_Green "Uninstall Memcached completed."
}
