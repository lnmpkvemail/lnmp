#!/usr/bin/env bash

Install_PHP_Sodium()
{
    cd ${cur_dir}/src
    echo "====== Installing PHP Sodium ======"
    Press_Start

    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}sodium.so"

    ${PHP_Path}/bin/php -m|grep sodium
    if [ $? -eq 0 ]; then
        Echo_Red "PHP Module 'sodium' already loaded!"
        exit 1
    fi

    if [ "$PM" = "yum" ]; then
        yum -y install libsodium-devel
    elif [ "$PM" = "apt" ]; then
        apt-get install -y libsodium-dev
    fi

    if echo "${Cur_PHP_Version}" | grep -Eqi '^7.[234].|8.[0-2].'; then
        Download_PHP_Src

        Tarj_Cd php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}/ext/sodium
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config
        make && make install
        cd -
        rm -rf php-${Cur_PHP_Version}
    else
        Download_Files ${Download_Mirror}/web/sodium/${PHPSodium_Ver}.tgz ${PHPSodium_Ver}.tgz
        Tar_Cd ${PHPSodium_Ver}.tgz ${PHPSodium_Ver}
        ${PHP_Path}/bin/phpize
        ./configure --with-php-config=${PHP_Path}/bin/php-config
        make && make install
        cd -
        rm -rf ${PHPSodium_Ver}
    fi

    cat >${PHP_Path}/conf.d/009-sodium.ini<<EOF
extension = "sodium.so"
EOF

    Restart_PHP
    if [ -s "${zend_ext}" ]; then
        Echo_Green "====== PHP Sodium install completed ======"
        Echo_Green "PHP Sodium installed successfully, enjoy it!"
        exit 0
    else
        rm -f ${PHP_Path}/conf.d/009-sodium.ini
        Echo_Red "PHP Sodium install failed!"
        exit 1
    fi
}

Uninstall_PHP_Sodium()
{
    echo "You will uninstall PHP Sodium..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/009-sodium.ini
    Restart_PHP
    Echo_Green "Uninstall PHP Sodium completed."
}
