#!/usr/bin/env bash

Install_PHP_Swoole()
{
    cd ${cur_dir}/src
    echo "====== Installing PHP Swoole ======"
    Press_Start

    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}swoole.so"

    ${PHP_Path}/bin/php -m|grep swoole
    if [ $? -eq 0 ]; then
        Echo_Red "PHP Module 'swoole' already loaded!"
        exit 1
    fi

    if echo "${Cur_PHP_Version}" | grep -Eqi '^7.[234].|8.[0-2].'; then
        Download_Files ${Download_Mirror}/web/swoole/${PHPSwoole_Ver}.tgz ${PHPSwoole_Ver}.tgz
        Tar_Cd ${PHPSwoole_Ver}.tgz ${PHPSwoole_Ver}
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config --enable-openssl --enable-http2 --enable-swoole-json
        make && make install
        cd -
        rm -rf ${PHPSwoole_Ver}
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.1.'; then
        Download_Files ${Download_Mirror}/web/swoole/swoole-4.5.11.tgz swoole-4.5.11.tgz
        Tar_Cd swoole-4.5.11.tgz swoole-4.5.11
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config --enable-openssl --enable-http2 --enable-swoole-json
        make && make install
        cd -
        rm -rf swoole-4.5.11
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.0.'; then
        Download_Files ${Download_Mirror}/web/swoole/swoole-4.3.6.tgz swoole-4.3.6.tgz
        Tar_Cd swoole-4.3.6.tgz swoole-4.3.6
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config --enable-openssl --enable-http2
        make && make install
        cd -
        rm -rf swoole-4.3.6
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.[3-6].'; then
        Download_Files ${Download_Mirror}/web/swoole/swoole-1.10.5.tgz swoole-1.10.5.tgz
        Tar_Cd swoole-1.10.5.tgz swoole-1.10.5
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config --enable-openssl
        make && make install
        cd -
        rm -rf swoole-1.10.5
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.'; then
        Download_Files ${Download_Mirror}/web/swoole/swoole-1.6.10.tgz swoole-1.6.10.tgz
        Tar_Cd swoole-1.6.10.tgz swoole-1.6.10
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config --enable-openssl
        make && make install
        cd -
        rm -rf swoole-1.6.10
    fi

    cat >${PHP_Path}/conf.d/009-swoole.ini<<EOF
extension = "swoole.so"
EOF

    Restart_PHP
    if [ -s "${zend_ext}" ]; then
        Echo_Green "====== PHP Swoole install completed ======"
        Echo_Green "PHP Swoole installed successfully, enjoy it!"
        exit 0
    else
        rm -f ${PHP_Path}/conf.d/009-swoole.ini
        Echo_Red "PHP Swoole install failed!"
        exit 1
    fi
}

Uninstall_PHP_Swoole()
{
    echo "You will uninstall PHP Swoole..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/009-swoole.ini
    Restart_PHP
    Echo_Green "Uninstall PHP Swoole completed."
}
