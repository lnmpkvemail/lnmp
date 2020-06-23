#!/usr/bin/env bash

Upgrade_Multiplephp()
{
    Get_Dist_Name
    Check_DB
    Check_Stack
    . include/upgrade_php.sh

    if [ "${Get_Stack}" != "lnmp" ]; then
        echo "Multiple PHP Versions ONLY for LNMP Stack!"
        exit 1
    fi

    if [[ ! -s /usr/local/php5.6/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.6.conf ]] && [[ ! -s /usr/local/php7.0/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.0.conf ]] && [[ ! -s /usr/local/php7.1/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.1.conf ]] && [[ ! -s /usr/local/php7.2/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.2.conf ]] && [[ ! -s /usr/local/php7.3/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.3.conf ]] && [[ ! -s /usr/local/php7.4/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.4.conf ]]; then
        echo "Multiple php version not found!"
    else
        echo "List all mutiple php, Please select the PHP version."
        if [[ -s /usr/local/php5.6/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.6.conf && -s /etc/init.d/php-fpm5.6 ]]; then
            Echo_Green "1: PHP 5.6 [found]"
        fi
        if [[ -s /usr/local/php7.0/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.0.conf && -s /etc/init.d/php-fpm7.0 ]]; then
            Echo_Green "2: PHP 7.0 [found]"
        fi
        if [[ -s /usr/local/php7.1/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.1.conf && -s /etc/init.d/php-fpm7.1 ]]; then
            Echo_Green "3: PHP 7.1 [found]"
        fi
        if [[ -s /usr/local/php7.2/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.2.conf && -s /etc/init.d/php-fpm7.2 ]]; then
            Echo_Green "4: PHP 7.2 [found]"
        fi
        if [[ -s /usr/local/php7.3/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.3.conf && -s /etc/init.d/php-fpm7.3 ]]; then
            Echo_Green "5: PHP 7.3 [found]"
        fi
        if [[ -s /usr/local/php7.4/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.4.conf && -s /etc/init.d/php-fpm7.4 ]]; then
            Echo_Green "6: PHP 7.4 [found]"
        fi
    fi

    while :;do
        MPHP_Select=""
        read -p "Please select which multiple php version to upgrade: " MPHP_Select
        if [ "${MPHP_Select}" = "" ]; then
            Echo_Red "Error: Please input number!"
        else
            break
        fi
    done

    if [ "${MPHP_Select}" = "1" ]; then
        Cur_MPHP_Big_Ver="5.6"
        Cur_MPHP_Path='/usr/local/php5.6'
    elif [ "${MPHP_Select}" = "2" ]; then
        Cur_MPHP_Big_Ver="7.0"
        Cur_MPHP_Path='/usr/local/php7.0'
    elif [ "${MPHP_Select}" = "3" ]; then
        Cur_MPHP_Big_Ver="7.1"
        Cur_MPHP_Path='/usr/local/php7.1'
    elif [ "${MPHP_Select}" = "4" ]; then
        Cur_MPHP_Big_Ver="7.2"
        Cur_MPHP_Path='/usr/local/php7.2'
    elif [ "${MPHP_Select}" = "5" ]; then
        Cur_MPHP_Big_Ver="7.3"
        Cur_MPHP_Path='/usr/local/php7.3'
    elif [ "${MPHP_Select}" = "6" ]; then
        Cur_MPHP_Big_Ver="7.4"
        Cur_MPHP_Path='/usr/local/php7.4'
    fi

    Echo_Yellow "Please choose whic multiple php version to upgrade."
    Echo_Yellow "Note: you can't upgrade php cross-version!"

    php_version=""
    Cur_MPHP_Version=$("${Cur_MPHP_Path}/bin/php-config" --version)
    echo "Current PHP Version: ${Cur_MPHP_Version}"
    echo "You can get version number from http://www.php.net"
    read -p "Please enter a PHP Version you want: " php_version
    if [ "${php_version}" = "" ]; then
        Echo_Red "Error: You must enter a corrent php version!!"
        exit 1
    fi
    if echo "${php_version}" | grep -Eqi "${Cur_MPHP_Big_Ver}"; then
        Echo_Blue "You will upgrade php ${Cur_MPHP_Version} from to ${php_version}."
    else
        Echo_Red "Error: You can't upgrade php cross-version!"
        exit 1
    fi
    Press_Start
    cd ${cur_dir}/src
    if [ -s php-${php_version}.tar.bz2 ]; then
        echo "php-${php_version}.tar.bz2 [found]"
    else
        echo "Notice: php-${php_version}.tar.bz2 not found!!!download now..."
        country=`curl -sSk --connect-timeout 10 -m 60 https://ip.vpser.net/country`
        if [ "${country}" = "CN" ]; then
            wget -c --progress=bar:force http://php.vpser.net/php-${php_version}.tar.bz2
            if [ $? -ne 0 ]; then
                wget -c --progress=bar:force https://www.php.net/distributions/php-${php_version}.tar.bz2
            fi
        else
            wget -c --progress=bar:force https://www.php.net/distributions/php-${php_version}.tar.bz2
        fi
        if [ $? -eq 0 ]; then
            echo "Download php-${Php_Ver}.tar.bz2 successfully!"
        else
            wget -c --progress=bar:force http://museum.php.net/php5/php-${php_version}.tar.bz2
            if [ $? -eq 0 ]; then
                echo "Download php-${php_version}.tar.bz2 successfully!"
            else
                echo "You enter PHP Version was:"${php_version}
                Echo_Red "Error! You entered a wrong version number, please check!"
                exit 1
            fi
        fi
    fi

    lnmp stop

    Echo_Blue "Backup old multiple php version..."
    mv ${Cur_MPHP_Path} /usr/local/mphp-${Cur_MPHP_Big_Ver}-backup${Upgrade_Date}
    mv /etc/init.d/php-fpm${Cur_MPHP_Big_Ver} /usr/local/mphp-${Cur_MPHP_Big_Ver}-backup${Upgrade_Date}/init.d.php-fpm.bak.${Upgrade_Date}

    Check_PHP_Option
    cat /etc/issue
    cat /etc/*-release
    Install_PHP_Dependent

    if [ "${MPHP_Select}" = "1" ]; then
        Upgrade_MPHP5.6
    elif [ "${MPHP_Select}" = "2" ]; then
        Upgrade_MPHP7.0
    elif [ "${MPHP_Select}" = "3" ]; then
        Upgrade_MPHP7.1
    elif [ "${MPHP_Select}" = "4" ]; then
        Upgrade_MPHP7.2
    elif [ "${MPHP_Select}" = "5" ]; then
        Upgrade_MPHP7.3
    elif [ "${MPHP_Select}" = "6" ]; then
        Upgrade_MPHP7.4
    fi
}

Upgrade_MPHP5.6()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tarj_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization ${with_curl} --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --enable-intl --with-xsl ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    echo "Install ZendGuardLoader for PHP 5.6..."
    cd ${cur_dir}/src
    if [ "${Is_64bit}" = "y" ] ; then
        Download_Files ${Download_Mirror}/web/zend/zend-loader-php5.6-linux-x86_64.tar.gz
        tar zxf zend-loader-php5.6-linux-x86_64.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so /usr/local/zend/ZendGuardLoader5.6.so
    else
        Download_Files ${Download_Mirror}/web/zend/zend-loader-php5.6-linux-i386.tar.gz
        tar zxf zend-loader-php5.6-linux-i386.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.6-linux-i386/ZendGuardLoader.so /usr/local/zend/ZendGuardLoader5.6.so
    fi

    echo "Write ZendGuardLoader to php.ini..."
    cat >${Cur_MPHP_Path}/conf.d/002-zendguardloader.ini<<EOF
[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/ZendGuardLoader5.6.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=
EOF

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi5.6.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm5.6
    chmod +x /etc/init.d/php-fpm5.6

    StartUp php-fpm5.6

    \cp ${cur_dir}/conf/enable-php5.6.conf /usr/local/nginx/conf/enable-php5.6.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP7.0()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tarj_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    echo "Install ZendGuardLoader for PHP 7..."
    echo "unavailable now."

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi7.0.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm7.0
    chmod +x /etc/init.d/php-fpm7.0

    StartUp php-fpm7.0

    \cp ${cur_dir}/conf/enable-php7.0.conf /usr/local/nginx/conf/enable-php7.0.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP7.1()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tarj_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    echo "Install ZendGuardLoader for PHP 7.1..."
    echo "unavailable now."

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi7.1.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm7.1
    chmod +x /etc/init.d/php-fpm7.1

    StartUp php-fpm7.1

    \cp ${cur_dir}/conf/enable-php7.1.conf /usr/local/nginx/conf/enable-php7.1.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP7.2()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tarj_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --with-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    echo "Install ZendGuardLoader for PHP 7.2..."
    echo "unavailable now."

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi7.2.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm7.2
    chmod +x /etc/init.d/php-fpm7.2

    StartUp php-fpm7.2

    \cp ${cur_dir}/conf/enable-php7.2.conf /usr/local/nginx/conf/enable-php7.2.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP7.3()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tarj_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --with-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --without-libzip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    echo "Install ZendGuardLoader for PHP 7.3..."
    echo "unavailable now."

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi7.3.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm7.3
    chmod +x /etc/init.d/php-fpm7.3

    StartUp php-fpm7.3

    \cp ${cur_dir}/conf/enable-php7.3.conf /usr/local/nginx/conf/enable-php7.3.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP7.4()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Install_Libzip
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tarj_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype=/usr/local/freetype --with-jpeg --with-png --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --without-libzip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    echo "Install ZendGuardLoader for PHP 7.4..."
    echo "unavailable now."

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi7.4.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm7.4
    chmod +x /etc/init.d/php-fpm7.4

    StartUp php-fpm7.4

    \cp ${cur_dir}/conf/enable-php7.4.conf /usr/local/nginx/conf/enable-php7.4.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}
