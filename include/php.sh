#!/bin/bash

Export_PHP_Autoconf()
{
    export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
    export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
}

Ln_PHP_Bin()
{
    ln -sf /usr/local/php/bin/php /usr/bin/php
    ln -sf /usr/local/php/bin/phpize /usr/bin/phpize
    ln -sf /usr/local/php/bin/pear /usr/bin/pear
    ln -sf /usr/local/php/bin/pecl /usr/bin/pecl
    if [ "${Stack}" = "lnmp" ]; then
        ln -sf /usr/local/php/sbin/php-fpm /usr/bin/php-fpm
    fi
}

Pear_Pecl_Set()
{
    pear config-set php_ini /usr/local/php/etc/php.ini
    pecl config-set php_ini /usr/local/php/etc/php.ini
}

Install_PHP_52()
{
    Echo_Blue "[+] Installing ${Php_Ver}..."
    cd ${cur_dir}/src && rm -rf ${Php_Ver}
    tar zxf ${Php_Ver}.tar.gz
    if [ "${Stack}" = "lnmp" ]; then
        gzip -cd ${Php_Ver}-fpm-0.5.14.diff.gz | patch -d ${Php_Ver} -p1
    fi
    cd ${Php_Ver}/
    patch -p1 < ${cur_dir}/src/patch/php-5.2.17-max-input-vars.patch
    patch -p0 < ${cur_dir}/src/patch/php-5.2.17-xml.patch
    patch -p1 < ${cur_dir}/src/patch/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p1 < ${cur_dir}/src/patch/php-5.2-multipart-form-data.patch
    ./buildconf --force
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=${MySQL_Dir} --with-mysqli=${MySQL_Config} --with-pdo-mysql=${MySQL_Dir} --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --with-mime-magic
    else
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=${MySQL_Dir} --with-mysqli=${MySQL_Config} --with-pdo-mysql=${MySQL_Dir} --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --with-mime-magic
    fi
    make ZEND_EXTRA_LIBS='-liconv'
    make install

    mkdir -p /usr/local/php/etc
    \cp php.ini-dist /usr/local/php/etc/php.ini
    cd ../

    Ln_PHP_Bin

    # php extensions
    sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/"\n#' /usr/local/php/etc/php.ini
    sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php/etc/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set

    cd ${cur_dir}/src
    if [ "${Is_64bit}" = "y" ] ; then
        Download_Files ${Download_Mirror}/web/zend/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
        tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
        mkdir -p /usr/local/zend/
        \cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
    else
        Download_Files ${Download_Mirror}/web/zend/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
        tar zxf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
        mkdir -p /usr/local/zend/
        \cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
    fi

    cat >>/usr/local/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

[Zend Optimizer] 
zend_optimizer.optimization_level=1 
zend_extension="/usr/local/zend/ZendOptimizer.so"

;xcache
;xcache end
EOF

    if [ "${Stack}" = "lnmp" ]; then
        rm -f /usr/local/php/etc/php-fpm.conf
        \cp ${cur_dir}/conf/php-fpm5.2.conf /usr/local/php/etc/php-fpm.conf
        \cp ${cur_dir}/init.d/init.d.php-fpm5.2 /etc/init.d/php-fpm
        chmod +x /etc/init.d/php-fpm
    fi
}

Install_PHP_53()
{
    Echo_Blue "[+] Installing ${Php_Ver}..."
    Tar_Cd ${Php_Ver}.tar.gz ${Php_Ver}
    Check_PHP53_Curl
    patch -p1 < ${cur_dir}/src/patch/php-5.3-multipart-form-data.patch
    if [ "${PHP53_With_Curl}" = "y" ]; then
        if [ "${Stack}" = "lnmp" ]; then
            ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
        else
            ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
        fi
    else
        if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
        else
            ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
        fi
    fi

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/etc
    \cp php.ini-production /usr/local/php/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
    sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set

    echo "Install ZendGuardLoader for PHP 5.3..."
    cd ${cur_dir}/src
    if [ "${Is_64bit}" = "y" ] ; then
        Download_Files ${Download_Mirror}/web/zend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        mkdir -p /usr/local/zend/
        \cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
    else
        Download_Files ${Download_Mirror}/web/zend/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        mkdir -p /usr/local/zend/
        \cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
    fi

    echo "Write ZendGuardLoader to php.ini..."
cat >>/usr/local/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;xcache
;xcache end
EOF

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
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
\cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
fi
}

Install_PHP_54()
{
    Echo_Blue "[+] Installing ${Php_Ver}..."
    Tar_Cd ${Php_Ver}.tar.gz ${Php_Ver}
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
    else
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo
    fi

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/etc
    \cp php.ini-production /usr/local/php/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set

    echo "Install ZendGuardLoader for PHP 5.4..."
    cd ${cur_dir}/src
    if [ "${Is_64bit}" = "y" ] ; then
        Download_Files ${Download_Mirror}/web/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        mkdir -p /usr/local/zend/
        \cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/zend/
    else
        Download_Files ${Download_Mirror}/web/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
        mkdir -p /usr/local/zend/
        \cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/zend/
    fi

    echo "Write ZendGuardLoader to php.ini..."
cat >>/usr/local/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;xcache
;xcache end
EOF

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
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
\cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
fi
}

Install_PHP_55()
{
    Echo_Blue "[+] Installing ${Php_Ver}..."
    Tar_Cd ${Php_Ver}.tar.gz ${Php_Ver}
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
    else
       ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache 
    fi

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/etc
    \cp php.ini-production /usr/local/php/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini..."
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set

    echo "Install ZendGuardLoader for PHP 5.5..."
    cd ${cur_dir}/src
    if [ "${Is_64bit}" = "y" ] ; then
        Download_Files ${Download_Mirror}/web/zend/zend-loader-php5.5-linux-x86_64.tar.gz
        tar zxf zend-loader-php5.5-linux-x86_64.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so /usr/local/zend/
    else
        Download_Files ${Download_Mirror}/web/zend/zend-loader-php5.5-linux-i386.tar.gz
        tar zxf zend-loader-php5.5-linux-i386.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.5-linux-i386/ZendGuardLoader.so /usr/local/zend/
    fi

    echo "Write ZendGuardLoader to php.ini..."
cat >>/usr/local/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;opcache
[Zend Opcache]
zend_extension=opcache.so
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache end

;xcache
;xcache end
EOF

echo "Download Opcache Control Panel..."
\cp ${cur_dir}/conf/ocp.php /home/wwwroot/default/ocp.php

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
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
\cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
fi
}

Install_PHP_56()
{
    Echo_Blue "[+] Installing ${Php_Ver}"
    Tar_Cd ${Php_Ver}.tar.gz ${Php_Ver}
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
    else
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache
    fi

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/etc
    \cp php.ini-production /usr/local/php/etc/php.ini

    cd ${cur_dir}
    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set

    echo "Install ZendGuardLoader for PHP 5.6..."
    cd ${cur_dir}/src
    if [ "${Is_64bit}" = "y" ] ; then
        Download_Files ${Download_Mirror}/web/zend/zend-loader-php5.6-linux-x86_64.tar.gz
        tar zxf zend-loader-php5.6-linux-x86_64.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so /usr/local/zend/
    else
        Download_Files ${Download_Mirror}/web/zend/zend-loader-php5.6-linux-i386.tar.gz
        tar zxf zend-loader-php5.6-linux-i386.tar.gz
        mkdir -p /usr/local/zend/
        \cp zend-loader-php5.6-linux-i386/ZendGuardLoader.so /usr/local/zend/
    fi

    echo "Write ZendGuardLoader to php.ini..."
cat >>/usr/local/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;opcache
[Zend Opcache]
zend_extension=opcache.so
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache end

;xcache
;xcache end
EOF

echo "Copy Opcache Control Panel..."
\cp ${cur_dir}/conf/ocp.php /home/wwwroot/default/ocp.php

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
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
    \cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    chmod +x /etc/init.d/php-fpm
fi
}

Creat_PHP_Tools()
{
    echo "Create PHP Info Tool..."
    cat >/home/wwwroot/default/phpinfo.php<<eof
<?
phpinfo();
?>
eof

    echo "Copy PHP Prober..."
    cd ${cur_dir}/src
    tar zxf p.tar.gz
    \cp p.php /home/wwwroot/default/p.php

    \cp ${cur_dir}/conf/index.html /home/wwwroot/default/index.html
    \cp ${cur_dir}/conf/lnmp.gif /home/wwwroot/default/lnmp.gif
    echo "============================Install PHPMyAdmin================================="
    [[ -d /home/wwwroot/default/phpmyadmin ]] && rm -rf /home/wwwroot/default/phpmyadmin
    tar zxf ${PhpMyAdmin_Ver}.tar.gz
    mv ${PhpMyAdmin_Ver} /home/wwwroot/default/phpmyadmin
    \cp ${cur_dir}/conf/config.inc.php /home/wwwroot/default/phpmyadmin/config.inc.php
    sed -i 's/LNMPORG/LNMP.org'$RANDOM'VPSer.net/g' /home/wwwroot/default/phpmyadmin/config.inc.php
    mkdir /home/wwwroot/default/phpmyadmin/{upload,save}
    chmod 755 -R /home/wwwroot/default/phpmyadmin/
    chown www:www -R /home/wwwroot/default/phpmyadmin/
    echo "============================phpMyAdmin install completed======================="

    #add iptables firewall rules
    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT 1 -i lo -j ACCEPT
        /sbin/iptables -I INPUT 2 -m state --state ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -I INPUT 3 -p tcp --dport 80 -j ACCEPT
        /sbin/iptables -I INPUT 4 -p tcp -s 127.0.0.1 --dport 3306 -j ACCEPT
        /sbin/iptables -I INPUT 5 -p tcp --dport 3306 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
            cat >/etc/network/if-post-down.d/iptables<<EOF
#!/bin/bash
iptables-save > /etc/iptables.rules
EOF
            chmod +x /etc/network/if-post-down.d/iptables
            cat >/etc/network/if-pre-up.d/iptables<<EOF
#!/bin/bash
iptables-restore < /etc/iptables.rules
EOF
            chmod +x /etc/network/if-pre-up.d/iptables
        fi
    fi
}

Check_PHP53_Curl()
{
    if [ "${DISTRO}" = "Fedora" ];then
        PHP53_With_Curl='y'
    elif echo "${Ubuntu_Version}" | grep -Eqi '^14.1';then
        PHP53_With_Curl='y'
    elif echo "${Ubuntu_Version}" | grep -Eqi '^15.';then 
        PHP53_With_Curl='y'
    elif echo "${Debian_Version}" | grep -Eqi '^8.';then
        PHP53_With_Curl='y'
    fi
}