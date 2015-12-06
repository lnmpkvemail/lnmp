#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

. lnmp.conf
. include/version.sh
. include/main.sh
. include/init.sh
. include/php.sh

clear
echo "+-----------------------------------------------------------------------+"
echo "|           Install PHP 5.2.17 for LNMP, Written by Licess              |"
echo "+-----------------------------------------------------------------------+"
echo "|                 A tool to install PHP 5.2.17 for LNMP                 |"
echo "+-----------------------------------------------------------------------+"
echo "|          For more information please visit http://www.lnmp.org        |"
echo "+-----------------------------------------------------------------------+"

cur_dir=$(pwd)
Get_OS_Bit
Get_Dist_Name
Check_DB
Get_PHP_Ext_Dir
if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.'; then
    echo "Do NOT need to install PHP 5.2.17!"
    exit 1
fi

echo "=================================================="
echo "You will install PHP 5.2.17"
echo "=================================================="

Press_Start

Install_PHP5217()
{

cd ${cur_dir}/src
Download_Files ${Download_Mirror}/web/php/php-5.2.17.tar.gz php-5.2.17.tar.gz
Download_Files ${Download_Mirror}/web/phpfpm/php-5.2.17-fpm-0.5.14.diff.gz php-5.2.17-fpm-0.5.14.diff.gz

lnmp stop

if [[ -s /usr/local/autoconf-2.13/bin/autoconf && -s /usr/local/autoconf-2.13/bin/autoheader ]]; then
    Echo_Green "Autconf 2.13...ok"
else
    Install_Autoconf
fi

if [[ -s /usr/local/curl/bin/curl ]]; then
    Echo_Green "Curl...ok"
else
    Install_Curl
fi

ln -s /usr/lib/libevent-1.4.so.2 /usr/local/lib/libevent-1.4.so.2
ln -s /usr/lib/libltdl.so /usr/lib/libltdl.so.3

cd ${cur_dir}/src
rm -rf php-5.2.17

echo "Start install php-5.2.17....."
Export_PHP_Autoconf
tar zxf php-5.2.17.tar.gz
gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d php-5.2.17 -p1
cd php-5.2.17/
patch -p1 < $cur_dir/src/patch/php-5.2.17-max-input-vars.patch
patch -p0 < $cur_dir/src/patch/php-5.2.17-xml.patch
patch -p1 < $cur_dir/src/patch/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
./buildconf --force
./configure --prefix=/usr/local/php52 --with-config-file-path=/usr/local/php52/etc --with-mysql=${MySQL_Dir} --with-mysqli=${MySQL_Config} --with-pdo-mysql=${MySQL_Dir} --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr/local/curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --with-mime-magic
make ZEND_EXTRA_LIBS='-liconv'
make install

cp php.ini-dist /usr/local/php52/etc/php.ini

# php extensions
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php52/lib/php/extensions/no-debug-non-zts-20060613/"\n#' /usr/local/php52/etc/php.ini
sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php52/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php52/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php52/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket/g' /usr/local/php/etc/php.ini

cd ${cur_dir}/src
if [ "${Is_64bit}" = "y" ] ; then
    Download_Files ${Download_Mirror}/web/zend/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
    tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
    mkdir -p /usr/local/zend52/
    \cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend52/
else
    Download_Files ${Download_Mirror}/web/zend/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
    tar zxf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
    mkdir -p /usr/local/zend52/
    \cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend52/
fi

cat >>/usr/local/php52/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer] 
zend_optimizer.optimization_level=1 
zend_extension="/usr/local/zend52/ZendOptimizer.so"

;xcache
;xcache end
EOF

rm -f /usr/local/php52/etc/php-fpm.conf
\cp ${cur_dir}/conf/php-fpm5.2.conf /usr/local/php52/etc/php-fpm.conf
\cp ${cur_dir}/init.d/init.d.php-fpm5.2 /etc/init.d/php-fpm52
chmod +x /etc/init.d/php-fpm52

sed -i 's#/usr/local/php/#/usr/local/php52/#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#php-cgi.sock#php-cgi52.sock#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#/usr/local/php/#/usr/local/php52/#g' /etc/init.d/php-fpm52
sed -i 's@# Provides:          php-fpm@# Provides:          php-fpm52@g' /etc/init.d/php-fpm52

StartUp php-fpm52

sleep 2

lnmp start
echo "Starting PHP 5.2.17 PHP-FPM..."
/etc/init.d/php-fpm52 start

rm -rf ${cur_dir}/src/php-5.2.17

if [ -s /usr/local/php52/sbin/php-fpm ] && [ -s /usr/local/php52/etc/php.ini ] && [ -s /usr/local/php52/bin/php ]; then
    echo "==========================================="
    Echo_Green "You have successfully install PHP 5.2.17 "
    echo "==========================================="
else
    Echo_Red "Failed to install PHP 5.2.17, you can download /root/installphp5.2.17.log from your server, and upload lnmp-install.log to LNMP Forum."
fi

}

Install_PHP5217 2>&1 | tee /root/installphp5.2.17.log