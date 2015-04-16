#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
echo "========================================================================="
echo "Install PHP 2.17 for LNMP with PHP 5.3.*,  Written by Licess"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo "========================================================================="
cur_dir=$(pwd)
if [ -s /usr/local/mariadb/bin/mysql ]; then
	ismysql="no"
else
	ismysql="yes"
fi

cur_php_version=`/usr/local/php/bin/php -r 'echo PHP_VERSION;'`
echo "Current PHP Version:$cur_php_version"
	if [[ "$cur_php_version" =~ "5.2." ]]; then
	   echo "Do NOT need to install PHP 5.2.17!"
	   exit 1
	fi

	echo "=================================================="
	echo "You will install PHP 5.2.17"
	echo "=================================================="

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

echo "============================check files=================================="
if [ -s php-5.2.17.tar.gz ]; then
  echo "php-5.2.17.tar.gz [found]"
  else
  echo "Error: php-5.2.17.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/php/php-5.2.17.tar.gz
fi

if [ -s php-5.2.17-fpm-0.5.14.diff.gz ]; then
  echo "php-5.2.17-fpm-0.5.14.diff.gz [found]"
  else
  echo "Error: php-5.2.17-fpm-0.5.14.diff.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/phpfpm/php-5.2.17-fpm-0.5.14.diff.gz
fi

if [ -s autoconf-2.13.tar.gz ]; then
  echo "autoconf-2.13.tar.gz [found]"
  else
  echo "Error: autoconf-2.13.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/lib/autoconf/autoconf-2.13.tar.gz
fi
echo "============================check files=================================="

echo "Stoping Nginx..."
/etc/init.d/nginx stop
echo "Stoping MySQL..."
/etc/init.d/mysql stop
echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm stop
if [ -s /etc/init.d/memceached ]; then
  echo "Stoping Memcached..."
  /etc/init.d/memcacehd stop
fi

rm -rf php-5.2.17/

tar zxvf autoconf-2.13.tar.gz
cd autoconf-2.13/
./configure --prefix=/usr/local/autoconf-2.13
make && make install
cd ../

ln -s /usr/lib/libevent-1.4.so.2 /usr/local/lib/libevent-1.4.so.2
ln -s /usr/lib/libltdl.so /usr/lib/libltdl.so.3

cd $cur_dir

echo "Start install php-5.2.17....."
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxvf php-5.2.17.tar.gz
gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d php-5.2.17 -p1
cd php-5.2.17/
wget -c http://soft.vpser.net/web/php/bug/php-5.2.17-max-input-vars.patch
patch -p1 < php-5.2.17-max-input-vars.patch
./buildconf --force
if [ "$ismysql" = "no" ]; then
	./configure --prefix=/usr/local/php52 --with-config-file-path=/usr/local/php52/etc --with-mysql=/usr/local/mariadb --with-mysqli=/usr/local/mariadb/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
else
	./configure --prefix=/usr/local/php52 --with-config-file-path=/usr/local/php52/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
fi
if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    cd ext/openssl/
    wget -c http://soft.vpser.net/lnmp/ext/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p3 <debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    cd ../../
fi
make ZEND_EXTRA_LIBS='-liconv'
make install

cp php.ini-dist /usr/local/php52/etc/php.ini

cd $cur_dir/php-5.2.17/ext/pdo_mysql/
/usr/local/php52/bin/phpize
./configure --with-php-config=/usr/local/php52/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install
cd $cur_dir/

# php extensions
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php52/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "pdo_mysql.so"\n#' /usr/local/php52/etc/php.ini
sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php52/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php52/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php52/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php52/etc/php.ini

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    wget -c http://soft.vpser.net/web/zend/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
    tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
else
    wget -c http://soft.vpser.net/web/zend/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	tar zxvf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
fi

cat >>/usr/local/php52/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer] 
zend_optimizer.optimization_level=1 
zend_extension="/usr/local/zend/ZendOptimizer.so" 
EOF

rm -f /usr/local/php52/etc/php-fpm.conf
wget -c http://soft.vpser.net/lnmp/lnmp0.9/conf/php-fpm.conf
cp php-fpm.conf /usr/local/php52/etc/php-fpm.conf

/usr/local/php52/sbin/php-fpm start
wget -c http://soft.vpser.net/lnmp/ext/init.d.php-fpm5.2
cp init.d.php-fpm5.2 /etc/init.d/php-fpm52
chmod +x /etc/init.d/php-fpm52

sed -i 's#/usr/local/php/#/usr/local/php52/#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#php-cgi.sock#php-cgi52.sock#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#/usr/local/php/#/usr/local/php52/#g' /etc/init.d/php-fpm52

sleep 2

echo "Starting Nginx..."
/etc/init.d/nginx start
echo "Starting MySQL..."
/etc/init.d/mysql start
echo "Starting PHP-FPM..."
/etc/init.d/php-fpm start
if [ -s /etc/init.d/memceached ]; then
  echo "Starting Memcached..."
  /etc/init.d/memcacehd start
fi
echo "Starting PHP 5.2.17 PHP-FPM..."
/etc/init.d/php-fpm52 start

cd $cur_dir

if [ -s /usr/local/php52/sbin/php-fpm ] && [ -s /usr/local/php52/etc/php.ini ] && [ -s /usr/local/php52/bin/php ]; then
echo "========================================================================="
echo "You have successfully install PHP 5.2.17 "
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo ""
echo "========================================================================="
else
echo "Failed to install PHP 5.2.17!,you need try to run ./php5.2.17.sh 2>&1 | tee installphp5.2.17.log to record install logs."
fi