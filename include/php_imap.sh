#!/usr/bin/env bash

Install_PHP_Imap()
{
    cd ${cur_dir}/src
    echo "====== Installing PHP Imap ======"
    Press_Start

    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}imap.so"

    ${PHP_Path}/bin/php -m|grep imap
    if [ $? -eq 0 ]; then
        Echo_Red "PHP Module 'imap' already loaded!"
        exit 1
    fi

    if [ "$PM" = "yum" ]; then
        if [ "${DISTRO}" = "Oracle" ]; then
            yum -y install oracle-epel-release
        else
            yum -y install epel-release
        fi
        yum -y install libc-client-devel krb5-devel uw-imap-devel
        if echo "${CentOS_Version}" | grep -Eqi "^9" || echo "${Alma_Version}" | grep -Eqi "^9" || echo "${Rocky_Version}" | grep -Eqi "^9"; then
            if ! rpm -qa | grep "libc-client-2007f" || ! rpm -qa | grep "uw-imap-devel"; then
                if [ "${CheckMirror}" = "n" ]; then
                    rpm -ivh ${cur_dir}/src/libc-client-2007f-24.el9.${ARCH}.rpm ${cur_dir}/src/uw-imap-devel-2007f-24.el9.${ARCH}.rpm
                else
                    rpm -ivh ${Download_Mirror}/lib/uw-imap/libc-client-2007f-24.el9.${ARCH}.rpm
                    rpm -ivh ${Download_Mirror}/lib/uw-imap/uw-imap-devel-2007f-24.el9.${ARCH}.rpm
                fi
            fi
        fi
        [[ -s /usr/lib64/libc-client.so ]] && ln -sf /usr/lib64/libc-client.so /usr/lib/libc-client.so
    elif [ "$PM" = "apt" ]; then
        apt-get install -y libc-client-dev libkrb5-dev
    fi

    Download_PHP_Src

    Tar_Cd php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}/ext/imap
    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config --with-imap --with-imap-ssl --with-kerberos
    make && make install
    cd -
    rm -rf php-${Cur_PHP_Version}

    cat >${PHP_Path}/conf.d/009-imap.ini<<EOF
extension = "imap.so"
EOF

    Restart_PHP
    if [ -s "${zend_ext}" ]; then
        Echo_Green "====== PHP Imap install completed ======"
        Echo_Green "PHP Imap installed successfully, enjoy it!"
        exit 0
    else
        rm -f ${PHP_Path}/conf.d/009-imap.ini
        Echo_Red "PHP Imap install failed!"
        exit 1
    fi
}

Uninstall_PHP_Imap()
{
    echo "You will uninstall PHP Imap..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/009-imap.ini
    Restart_PHP
    Echo_Green "Uninstall PHP Imap completed."
}
