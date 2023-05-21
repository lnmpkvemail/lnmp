#!/usr/bin/env bash

Install_PHP_Fileinfo()
{
    cd ${cur_dir}/src
    echo "====== Installing PHP Fileinfo ======"
    Echo_Yellow "If the memory is less than 1GB, fileinfo may fail to install."
    Press_Start

    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}fileinfo.so"

    ${PHP_Path}/bin/php -m|grep fileinfo
    if [ $? -eq 0 ]; then
        Echo_Red "PHP Module 'fileinfo' already loaded!"
        exit 1
    fi

    Download_PHP_Src

    Tar_Cd php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}/ext/fileinfo
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config
    make && make install
    cd -
    rm -rf php-${Cur_PHP_Version}

    cat >${PHP_Path}/conf.d/009-fileinfo.ini<<EOF
extension = "fileinfo.so"
EOF

    Restart_PHP
    if [ -s "${zend_ext}" ]; then
        Echo_Green "====== PHP Fileinfo install completed ======"
        Echo_Green "PHP Fileinfo installed successfully, enjoy it!"
        exit 0
    else
        rm -f ${PHP_Path}/conf.d/009-exif.ini
        Echo_Red "PHP Fileinfo install failed!"
        exit 1
    fi
}

Uninstall_PHP_Fileinfo()
{
    echo "You will uninstall PHP Fileinfo..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/009-fileinfo.ini
    Restart_PHP
    Echo_Green "Uninstall PHP Fileinfo completed."
}
