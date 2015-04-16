#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
printf "=======================================================================\n"
printf "Install Apache for LNMP,  Written by Licess \n"
printf "=======================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install Apache for lnmp \n"
printf "\n"
printf "For more information please visit http://www.lnmp.org \n"
printf "=======================================================================\n"
cur_dir=$(pwd)
ipv4=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

if [ -s /usr/local/mariadb/bin/mysql ]; then
	ismysql="no"
else
	ismysql="yes"
fi

echo "==========================="

	isinstallphp53="n"
	echo "Install PHP 5.3.28,Please input y"
	echo "Install PHP 5.2.17,Please input n or press Enter"
	read -p "(Please input y or n):" isinstallphp53

	case "$isinstallphp53" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install PHP 5.3.28"
	isinstallphp53="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install PHP 5.2.17"
	isinstallphp53="n"
	;;
	*)
	echo "INPUT error,You will install PHP 5.2.17"
	isinstallphp53="n"
	esac

#set Server Administrator Email Address

	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi

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
	echo "Press any key to start install Apache for LNMP or Press Ctrl+C to cancel..."
	char=`get_char`

printf "===================== Check And Download Files =================\n"

if [ -s httpd-2.2.27.tar.gz ]; then
  echo "httpd-2.2.27.tar.gz [found]"
  else
  echo "Error: httpd-2.2.27.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/apache/httpd-2.2.27.tar.gz
fi

if [ -s mod_rpaf-0.6.tar.gz ]; then
  echo "mod_rpaf-0.6.tar.gz [found]"
  else
  echo "Error: mod_rpaf-0.6.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/apache/rpaf/mod_rpaf-0.6.tar.gz
fi

if [ "$isinstallphp53" = "n" ]; then
	if [ -s php-5.2.17.tar.gz ]; then
	  echo "php-5.2.17.tar.gz [found]"
	else
	  echo "Error: php-5.2.17.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/web/php/php-5.2.17.tar.gz
	fi
else
	if [ -s php-5.3.28.tar.gz ]; then
	  echo "php-5.3.28.tar.gz [found]"
	else
	  echo "Error: php-5.3.28.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/web/php/php-5.3.28.tar.gz
	fi
fi
printf "=========================== install Apache ======================\n"

echo "Stoping Nginx..."
/etc/init.d/nginx stop
if [ "$ismysql" = "no" ]; then
	echo "Stoping MariaDB..."
	/etc/init.d/mariadb stop
else
	echo "Stoping MySQL..."
	/etc/init.d/mysql stop
fi
echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm stop
if [ -s /etc/init.d/memceached ]; then
  echo "Stoping Memcached..."
  /etc/init.d/memcacehd stop
fi

echo "Backup old php configure files....."
mkdir /root/lnmpbackup/
cp /root/lnmp /root/lnmpbackup/
cp /usr/local/php/etc/php.ini /root/lnmpbackup/
cp /usr/local/php/etc/php-fpm.conf /root/lnmpbackup/

cd $cur_dir
rm -rf httpd-2.2.27/
tar zxvf httpd-2.2.27.tar.gz
cd httpd-2.2.27/
./configure --prefix=/usr/local/apache --enable-mods-shared=most --enable-headers --enable-mime-magic --enable-proxy --enable-so --enable-rewrite --enable-ssl --enable-deflate --enable-suexec --with-included-apr --with-mpm=prefork --with-ssl --with-expat=builtin
make && make install
cd ..

mv /usr/local/apache/conf/httpd.conf /usr/local/apache/conf/httpd.conf.bak
\cp $cur_dir/conf/httpd.conf /usr/local/apache/conf/httpd.conf
\cp $cur_dir/conf/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf
\cp $cur_dir/conf/httpd-vhosts.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
\cp $cur_dir/conf/httpd-mpm.conf /usr/local/apache/conf/extra/httpd-mpm.conf
\cp $cur_dir/conf/rpaf.conf /usr/local/apache/conf/extra/rpaf.conf

cat >module.ini<<EOF
LoadModule actions_module modules/mod_actions.so
LoadModule alias_module modules/mod_alias.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule autoindex_module modules/mod_autoindex.so
LoadModule cgi_module modules/mod_cgi.so
LoadModule deflate_module modules/mod_deflate.so
LoadModule dir_module modules/mod_dir.so
LoadModule expires_module modules/mod_expires.so
LoadModule headers_module modules/mod_headers.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule logio_module modules/mod_logio.so
LoadModule mime_module modules/mod_mime.so
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule status_module modules/mod_status.so
LoadModule vhost_alias_module modules/mod_vhost_alias.so

EOF

sed -i '/# LoadModule foo_module/ {
r module.ini
}' /usr/local/apache/conf/httpd.conf

rm -f module.ini

sed -i 's/#ServerName www.example.com:80/ServerName www.lnmp.org:88/g' /usr/local/apache/conf/httpd.conf
sed -i 's/ServerAdmin you@example.com/ServerAdmin '$ServerAdmin'/g' /usr/local/apache/conf/httpd.conf
#sed -i 's/www.lnmp.org/'$domain'/g' /usr/local/apache/conf/extra/httpd-vhosts.conf
sed -i 's/webmaster@example.com/'$ServerAdmin'/g' /usr/local/apache/conf/extra/httpd-vhosts.conf
sed -i '/httpd-multilang-errordoc.conf/s/^/#/' /usr/local/apache/conf/httpd.conf
sed -i '/httpd-languages.conf/s/^/#/' /usr/local/apache/conf/httpd.conf
sed -i '/httpd-info.conf/s/^/#/' /usr/local/apache/conf/httpd.conf
sed -i '/httpd-default.conf/s/^/#/' /usr/local/apache/conf/httpd.conf
mkdir -p /usr/local/apache/conf/vhost
cat >>/usr/local/apache/conf/httpd.conf<<EOF
Include conf/vhost/*.conf
EOF

tar -zxvf mod_rpaf-0.6.tar.gz
cd mod_rpaf-0.6/
/usr/local/apache/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
cd ..

ln -s /usr/local/lib/libltdl.so.3 /usr/lib/libltdl.so.3

#sed -i 's#your_ips#'$ipv4'#g' /usr/local/apache/conf/extra/rpaf.conf
echo "Stop php-fpm....."

rm -rf /usr/local/php/
cd $cur_dir
if [ -s php-5.2.17 ]; then
rm -rf php-5.2.17
fi

if [ -s php-5.3.28 ]; then
rm -rf php-5.3.28
fi

if [ "$isinstallphp53" = "n" ]; then
	tar zxf php-5.2.17.tar.gz
	cd php-5.2.17/
	wget -c http://soft.vpser.net/web/php/bug/php-5.2.17-max-input-vars.patch
	patch -p1 < php-5.2.17-max-input-vars.patch
	if [ "$ismysql" = "no" ]; then
		./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=/usr/local/mariadb --with-mysqli=/usr/local/mariadb/bin/mysql_config --with-pdo-mysql=/usr/local/mariadb --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
	else
		./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
	fi
	if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    cd ext/openssl/
    wget -c http://soft.vpser.net/lnmp/ext/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p3 <debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    cd ../../
	fi
else
	tar zxf php-5.3.28.tar.gz
	cd php-5.3.28/
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
fi

rm -rf libtool
cp /usr/local/apache/build/libtool .

make ZEND_EXTRA_LIBS='-liconv'
make install

mkdir -p /usr/local/php/etc
if [ "$isinstallphp53" = "n" ]; then
	cp php.ini-dist /usr/local/php/etc/php.ini
else
	cp php.ini-production /usr/local/php/etc/php.ini
fi
cd ../

cd $cur_dir/
# php extensions
sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket/g' /usr/local/php/etc/php.ini

if [ "$isinstallphp53" = "n" ]; then
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
cat >>/usr/local/php/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer] 
zend_optimizer.optimization_level=1 
zend_extension="/usr/local/zend/ZendOptimizer.so" 
EOF
else
	if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
		wget -c http://soft.vpser.net/web/zend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/ 
	else
		wget -c http://soft.vpser.net/web/zend/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/ 
	fi
cat >>/usr/local/php/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer] 
zend_extension=/usr/local/zend/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=
EOF
fi

cd $cur_dir
cp conf/proxy.conf /usr/local/nginx/conf/proxy.conf
mv /usr/local/nginx/conf/nginx.conf /root/lnmpbackup/
cp conf/nginx_a.conf /usr/local/nginx/conf/nginx.conf

echo "Download new Apache init.d file......"
wget -c http://soft.vpser.net/lnmp/ext/init.d.httpd
cp init.d.httpd /etc/init.d/httpd
chmod +x /etc/init.d/httpd

echo "Test Nginx configure files..."
/usr/local/nginx/sbin/nginx -t
echo "ReStarting Nginx......"
/etc/init.d/nginx restart
echo "Starting Apache....."
if [ "$ismysql" = "no" ]; then
	echo "Starting MariaDB..."
	/etc/init.d/mariadb start
else
	echo "Starting MySQL..."
	/etc/init.d/mysql start
fi
/etc/init.d/httpd restart

echo "Remove old startup files and Add new startup file....."
if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    update-rc.d -f httpd defaults
    update-rc.d -f php-fpm remove
else
	sed -i '/php-fpm/'d /etc/rc.local
	chkconfig --level 345 php-fpm off
	chkconfig --level 345 httpd on
fi

cd $cur_dir
rm -f /etc/init.d/php-fpm
mv /root/vhost.sh /root/lnmp.vhost.sh
cp vhost_lnmpa.sh /root/vhost.sh
chmod +x /root/vhost.sh
cp lnmpa /root/
chmod +x /root/lnmpa

printf "====================== Upgrade to LNMPA completed =====================\n"
printf "You have successfully upgrade from lnmp to lnmpa,enjoy it!\n"
printf "=======================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to upgrade from lnmp to lnmpa \n"
printf "\n"
printf "For more information please visit http://www.lnmp.org \n"
printf "=======================================================================\n"