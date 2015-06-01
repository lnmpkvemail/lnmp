#!/bin/bash

Install_Opcache()
{

    Echo_Red "Install Opcache will auto uninstall eAccelerator if exists..."
    echo "====== Installing zend opcache ======"
    Press_Install

    echo "Uninstall eAccelerator..."
    sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini

    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}opcache.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.'; then
        echo "Zend Opcache do NOT SUPPORT PHP 5.2.* and lower version of php 5.3"
        sleep 1
        exit 1
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.3.'; then
        if echo ${Cur_PHP_Version} | grep -vEqi '^5.3.2[0-9]';then
            echo "If PHP under version 5.3.20, we do not recommend install opcache, it maybe cause 502 Bad Gateway error!"
            sleep 3
            exit 1
        fi
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.[456].'; then
        echo "${Cur_PHP_Version}"
    else
        echo "Error: can't get php version!"
        echo "Maybe php was didn't install or php configuration file has errors.Please check."
        sleep 3
        exit 1
    fi

    cd ${cur_dir}/src

    if [ -s "${ZendOpcache_Ver}" ]; then
        rm -rf "${ZendOpcache_Ver}"
    fi

    Download_Files ${Download_Mirror}/web/opcache/${ZendOpcache_Ver}.tgz ${ZendOpcache_Ver}.tgz
    Tar_Cd ${ZendOpcache_Ver}.tgz ${ZendOpcache_Ver}
    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make
    make install
    cd ../

    sed -i '/;opcache/,/;opcache end/d' /usr/local/php/etc/php.ini
    cat >>/usr/local/php/etc/php.ini<<EOF
;opcache
[Zend Opcache]
zend_extension="${zend_ext}"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache end

EOF

    echo "Copy Opcache Control Panel..."
    \cp $cur_dir/conf/ocp.php /home/wwwroot/default/ocp.php

    Restart_PHP

    if [ -s ${zend_ext} ]; then
        echo "====== Opcache install completed ======"
        echo "Opcache installed successfully, enjoy it!"
    else
        sed -i '/;opcache/,/;opcache end/d' /usr/local/php/etc/php.ini
        echo "OPcache install failed!"
    fi
}

Uninstall_Opcache()
{
    echo "You will uninstall opcache..."
    Press_Start
    sed -i '/;opcache/,/;opcache end/d' /usr/local/php/etc/php.ini
    Restart_PHP
    echo "Uninstall Opcache completed."
}