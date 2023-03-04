#!/usr/bin/env bash

Install_PHP_Exif()
{
    cd ${cur_dir}/src
    echo "====== Installing PHP Exif ======"
    Press_Start

    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}exif.so"

    ${PHP_Path}/bin/php -m|grep exif
    if [ $? -eq 0 ]; then
        Echo_Red "PHP Module 'exif' already loaded!"
        exit 1
    fi

    Download_PHP_Src

    Tar_Cd php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}/ext/exif
    if echo "${Cur_PHP_Version}" | grep -Eqi '^8.' && gcc -dumpversion|grep -Eq "^[3-4].";then
        export CFLAGS="-std=c99"
    fi
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config
    make && make install
    cd -
    rm -rf php-${Cur_PHP_Version}

    cat >${PHP_Path}/conf.d/009-exif.ini<<EOF
extension = "exif.so"
EOF

    Restart_PHP
    if [ -s "${zend_ext}" ]; then
        Echo_Green "====== PHP Exif install completed ======"
        Echo_Green "PHP Exif installed successfully, enjoy it!"
        exit 0
    else
        rm -f ${PHP_Path}/conf.d/009-exif.ini
        Echo_Red "PHP Exif install failed!"
        exit 1
    fi
}

Uninstall_PHP_Exif()
{
    echo "You will uninstall PHP Exif..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/009-exif.ini
    Restart_PHP
    Echo_Green "Uninstall PHP Exif completed."
}
