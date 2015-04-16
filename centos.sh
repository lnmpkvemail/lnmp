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
echo "LNMP V1.1 for CentOS/RadHat Linux Server, Written by Licess"
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo "========================================================================="
cur_dir=$(pwd)

#set mysql root password
	echo "==========================="

	mysqlrootpwd="root"
	echo "Please input the root password of mysql:"
	read -p "(Default password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
	echo "==========================="
	echo "MySQL root password:$mysqlrootpwd"
	echo "==========================="

#do you want to install the InnoDB Storage Engine?
echo "==========================="

	installinnodb="n"
	echo "Do you want to install the InnoDB Storage Engine?"
	read -p "(Default no,if you want please input: y ,if not please press the enter button):" installinnodb

	case "$installinnodb" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install the InnoDB Storage Engine"
	installinnodb="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will NOT install the InnoDB Storage Engine!"
	installinnodb="n"
	;;
	*)
	echo "INPUT error,The InnoDB Storage Engine will NOT install!"
	installinnodb="n"
	esac

#which PHP Version do you want to install?
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

#which MySQL Version do you want to install?
echo "==========================="

	isinstallmysql55="n"
	echo "Install MySQL 5.5.37,Please input y"
	echo "Install MySQL 5.1.73,Please input n or press Enter"
	echo "Install MariaDB 5.5.37,Please input md"
	read -p "(Please input y , n or md):" isinstallmysql55

	case "$isinstallmysql55" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install MySQL 5.5.37"
	isinstallmysql55="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install MySQL 5.1.73"
	isinstallmysql55="n"
	;;
	md|MD|Md|mD)
	echo "You will install MariaDB 5.5.37"
	isinstallmysql55="md"
	;;
	*)
	echo "INPUT error,You will install MySQL 5.1.73"
	isinstallmysql55="n"
	esac

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

function InitInstall()
{
	cat /etc/issue
	uname -a
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
	echo -e "\n Memory is: ${MemTotal} MB "
	#Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	yum install -y ntp
	ntpdate -u pool.ntp.org
	date

	rpm -qa|grep httpd
	rpm -e httpd
	rpm -qa|grep mysql
	rpm -e mysql
	rpm -qa|grep php
	rpm -e php

	yum -y remove httpd*
	yum -y remove php*
	yum -y remove mysql-server mysql mysql-libs
	yum -y remove php-mysql

	yum -y install yum-fastestmirror
	yum -y remove httpd
	#yum -y update

	#Disable SeLinux
	if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi

	cp /etc/yum.conf /etc/yum.conf.lnmp
	sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

	for packages in patch make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils;
	do yum -y install $packages; done

	mv -f /etc/yum.conf.lnmp /etc/yum.conf
}

function CheckAndDownloadFiles()
{
echo "============================check files=================================="
if [ "$isinstallphp53" = "n" ]; then
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
else
	if [ -s php-5.3.28.tar.gz ]; then
	  echo "php-5.3.28.tar.gz [found]"
	else
	  echo "Error: php-5.3.28.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/web/php/php-5.3.28.tar.gz
	fi
fi

if [ -s memcache-3.0.6.tgz ]; then
  echo "memcache-3.0.6.tgz [found]"
  else
  echo "Error: memcache-3.0.6.tgz not found!!!download now......"
  wget -c http://soft.vpser.net/web/memcache/memcache-3.0.6.tgz
fi

if [ -s pcre-8.12.tar.gz ]; then
  echo "pcre-8.12.tar.gz [found]"
  else
  echo "Error: pcre-8.12.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/pcre/pcre-8.12.tar.gz
fi

if [ -s nginx-1.6.0.tar.gz ]; then
  echo "nginx-1.6.0.tar.gz [found]"
  else
  echo "Error: nginx-1.6.0.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/nginx/nginx-1.6.0.tar.gz
fi

if [ "$isinstallmysql55" = "n" ]; then
	if [ -s mysql-5.1.73.tar.gz ]; then
	  echo "mysql-5.1.73.tar.gz [found]"
	  else
	  echo "Error: mysql-5.1.73.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/datebase/mysql/mysql-5.1.73.tar.gz
	fi
elif [ "$isinstallmysql55" = "y" ]; then
	if [ -s mysql-5.5.37.tar.gz ]; then
	  echo "mysql-5.5.37.tar.gz [found]"
	  else
	  echo "Error: mysql-5.5.37.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/datebase/mysql/mysql-5.5.37.tar.gz
	fi
else 
	if [ -s mariadb-5.5.37.tar.gz ]; then
	  echo "mariadb-5.5.37.tar.gz [found]"
	  else
	  echo "Error: mariadb-5.5.37.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/datebase/mariadb/mariadb-5.5.37.tar.gz
	fi
fi

if [ -s libiconv-1.14.tar.gz ]; then
  echo "libiconv-1.14.tar.gz [found]"
  else
  echo "Error: libiconv-1.14.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/libiconv/libiconv-1.14.tar.gz
fi

if [ -s libmcrypt-2.5.8.tar.gz ]; then
  echo "libmcrypt-2.5.8.tar.gz [found]"
  else
  echo "Error: libmcrypt-2.5.8.tar.gz not found!!!download now......"
  wget -c  http://soft.vpser.net/web/libmcrypt/libmcrypt-2.5.8.tar.gz
fi

if [ -s mhash-0.9.9.9.tar.gz ]; then
  echo "mhash-0.9.9.9.tar.gz [found]"
  else
  echo "Error: mhash-0.9.9.9.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/mhash/mhash-0.9.9.9.tar.gz
fi

if [ -s mcrypt-2.6.8.tar.gz ]; then
  echo "mcrypt-2.6.8.tar.gz [found]"
  else
  echo "Error: mcrypt-2.6.8.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/web/mcrypt/mcrypt-2.6.8.tar.gz
fi

if [ "$isinstallphp53" = "n" ]; then
	if [ -s phpmyadmin-latest.tar.gz ]; then
	  echo "phpmyadmin-latest.tar.gz [found]"
	  else
	  echo "Error: phpmyadmin-latest.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/datebase/phpmyadmin/phpmyadmin-latest.tar.gz
	fi
else
	if [ -s phpMyAdmin-lasest.tar.gz ]; then
	  echo "phpMyAdmin-lasest.tar.gz [found]"
	  else
	  echo "Error: phpMyAdmin-lasest.tar.gz not found!!!download now......"
	  wget -c http://soft.vpser.net/datebase/phpmyadmin/phpMyAdmin-lasest.tar.gz
	fi
fi

if [ -s p.tar.gz ]; then
  echo "p.tar.gz [found]"
  else
  echo "Error: p.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/prober/p.tar.gz
fi

if [ -s autoconf-2.13.tar.gz ]; then
  echo "autoconf-2.13.tar.gz [found]"
  else
  echo "Error: autoconf-2.13.tar.gz not found!!!download now......"
  wget -c http://soft.vpser.net/lib/autoconf/autoconf-2.13.tar.gz
fi

if [ -s mysql-openssl.patch ]; then
  echo "mysql-openssl.patch [found]"
  else
  echo "Error: mysql-openssl.patch not found!!!download now......"
  wget -c http://soft.vpser.net/lnmp/ext/mysql-openssl.patch
fi
echo "============================check files=================================="
}

function InstallDependsAndOpt()
{
cd $cur_dir

tar zxf autoconf-2.13.tar.gz
cd autoconf-2.13/
./configure --prefix=/usr/local/autoconf-2.13
make && make install
cd ../

tar zxf libiconv-1.14.tar.gz
cd libiconv-1.14/
./configure
make && make install
cd ../

cd $cur_dir
tar zxf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

cd $cur_dir
tar zxf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
cd ../

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

cd $cur_dir
tar zxf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
fi

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi

ldconfig

cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

echo "fs.file-max=65535" >> /etc/sysctl.conf
}

function InstallMySQL51()
{
echo "============================Install MySQL 5.1.73=================================="
cd $cur_dir
rm -f /etc/my.cnf
tar zxf mysql-5.1.73.tar.gz
cd mysql-5.1.73/
if [ $installinnodb = "y" ]; then
./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=innobase
else
./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile
fi
make && make install
cd ../

groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
if [ $installinnodb = "y" ]; then
sed -i 's:#innodb:innodb:g' /etc/my.cnf
fi
/usr/local/mysql/bin/mysql_install_db --user=mysql
chown -R mysql /usr/local/mysql/var
chgrp -R mysql /usr/local/mysql/.
cp /usr/local/mysql/share/mysql/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib/mysql
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
/etc/init.d/mysql start

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

/etc/init.d/mysql restart
/etc/init.d/mysql stop
echo "============================MySQL 5.1.73 install completed========================="
}

function InstallMySQL55()
{
echo "============================Install MySQL 5.5.26=================================="
cd $cur_dir

rm -f /etc/my.cnf
tar zxf mysql-5.5.37.tar.gz
cd mysql-5.5.37/
patch -p1 < $cur_dir/mysql-openssl.patch
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
make && make install

groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

cp support-files/my-medium.cnf /etc/my.cnf
sed '/skip-external-locking/i\datadir = /usr/local/mysql/var' -i /etc/my.cnf
if [ $installinnodb = "y" ]; then
sed -i 's:#innodb:innodb:g' /etc/my.cnf
sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
else
sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
fi

/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/var --user=mysql
chown -R mysql /usr/local/mysql/var
chgrp -R mysql /usr/local/mysql/.
cp support-files/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
if [ -d "/proc/vz" ];then
ulimit -s unlimited
fi
/etc/init.d/mysql start

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

/etc/init.d/mysql restart
/etc/init.d/mysql stop
echo "============================MySQL 5.5.26 install completed========================="
}

function InstallMariaDB()
{
echo "============================Install MariaDB 5.5.37=================================="
cd $cur_dir

rm -f /etc/my.cnf
tar zxf mariadb-5.5.37.tar.gz
cd mariadb-5.5.37/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
make && make install

groupadd mariadb
useradd -s /sbin/nologin -M -g mariadb mariadb

cp support-files/my-medium.cnf /etc/my.cnf
sed '/skip-external-locking/i\pid-file = /usr/local/mariadb/var/mariadb.pid' -i /etc/my.cnf
sed '/skip-external-locking/i\log_error = /usr/local/mariadb/var/mariadb.err' -i /etc/my.cnf
sed '/skip-external-locking/i\basedir = /usr/local/mariadb' -i /etc/my.cnf
sed '/skip-external-locking/i\datadir = /usr/local/mariadb/var' -i /etc/my.cnf
sed '/skip-external-locking/i\user = mariadb' -i /etc/my.cnf
if [ $installinnodb = "y" ]; then
sed -i 's:#innodb:innodb:g' /etc/my.cnf
sed -i 's:/usr/local/mariadb/data:/usr/local/mariadb/var:g' /etc/my.cnf
else
sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
fi

/usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=/usr/local/mariadb/var --user=mariadb
chown -R mariadb /usr/local/mariadb/var
chgrp -R mariadb /usr/local/mariadb/.
cp support-files/mysql.server /etc/init.d/mariadb
chmod 755 /etc/init.d/mariadb

cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
/usr/local/mariadb/lib
/usr/local/lib
EOF
ldconfig

if [ -d "/proc/vz" ];then
ulimit -s unlimited
fi
/etc/init.d/mariadb start

ln -s /usr/local/mariadb/bin/mysql /usr/bin/mysql
ln -s /usr/local/mariadb/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mariadb/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mariadb/bin/mysqld_safe /usr/bin/mysqld_safe

/usr/local/mariadb/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mariadb_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mariadb/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mariadb_sec_script

rm -f /tmp/mariadb_sec_script

/etc/init.d/mariadb restart
/etc/init.d/mariadb stop
echo "============================MariaDB 5.5.37 install completed========================="
}

function InstallPHP52()
{
echo "============================Install PHP 5.2.17========================="
cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxf php-5.2.17.tar.gz
gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d php-5.2.17 -p1
cd php-5.2.17/
wget -c http://soft.vpser.net/web/php/bug/php-5.2.17-max-input-vars.patch
patch -p1 < php-5.2.17-max-input-vars.patch
./buildconf --force
if [ "$isinstallmysql55" = "md" ]; then
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mariadb --with-mysqli=/usr/local/mariadb/bin/mysql_config --with-pdo-mysql=/usr/local/mariadb --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
else
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
fi
make ZEND_EXTRA_LIBS='-liconv'
make install

mkdir -p /usr/local/php/etc
cp php.ini-dist /usr/local/php/etc/php.ini
cd ../

rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

cd $cur_dir/

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
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket/g' /usr/local/php/etc/php.ini

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	wget -c http://soft.vpser.net/web/zend/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
else
	wget -c http://soft.vpser.net/web/zend/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	tar zxf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
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


rm -f /usr/local/php/etc/php-fpm.conf
cp conf/php-fpm.conf /usr/local/php/etc/php-fpm.conf

wget -c http://soft.vpser.net/lnmp/ext/init.d.php-fpm5.2
cp init.d.php-fpm5.2 /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
cp $cur_dir/lnmp /root/lnmp
chmod +x /root/lnmp
echo "============================PHP 5.2.17 install completed======================"
}

function InstallPHP53()
{
echo "============================Install PHP 5.3.28================================"
cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxf php-5.3.28.tar.gz
cd php-5.3.28/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

echo "Copy new php configure file."
mkdir -p /usr/local/php/etc
cp php.ini-production /usr/local/php/etc/php.ini

cd $cur_dir
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
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini

echo "Install ZendGuardLoader for PHP 5.3"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	wget -c http://soft.vpser.net/web/zend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	tar zxf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
else
	wget -c http://soft.vpser.net/web/zend/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	tar zxf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
fi

echo "Write ZendGuardLoader to php.ini......"
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

echo "Creating new php-fpm configure file......"
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

echo "Copy php-fpm init.d file......"
cp $cur_dir/php-5.3.28/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

cp $cur_dir/lnmp /root/lnmp
chmod +x /root/lnmp
sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/lnmp
echo "============================PHP 5.3.28 install completed======================"
}

function InstallNginx()
{
echo "============================Install Nginx================================="
groupadd www
useradd -s /sbin/nologin -g www www
cd $cur_dir
tar zxf pcre-8.12.tar.gz
cd pcre-8.12/
./configure
make && make install
cd ../

ldconfig

tar zxf nginx-1.6.0.tar.gz
cd nginx-1.6.0/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
make && make install
cd ../

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

rm -f /usr/local/nginx/conf/nginx.conf
cd $cur_dir
cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
cp conf/dabr.conf /usr/local/nginx/conf/dabr.conf
cp conf/discuz.conf /usr/local/nginx/conf/discuz.conf
cp conf/sablog.conf /usr/local/nginx/conf/sablog.conf
cp conf/typecho.conf /usr/local/nginx/conf/typecho.conf
cp conf/wordpress.conf /usr/local/nginx/conf/wordpress.conf
cp conf/discuzx.conf /usr/local/nginx/conf/discuzx.conf
cp conf/none.conf /usr/local/nginx/conf/none.conf
cp conf/wp2.conf /usr/local/nginx/conf/wp2.conf
cp conf/phpwind.conf /usr/local/nginx/conf/phpwind.conf
cp conf/shopex.conf /usr/local/nginx/conf/shopex.conf
cp conf/dedecms.conf /usr/local/nginx/conf/dedecms.conf
cp conf/drupal.conf /usr/local/nginx/conf/drupal.conf
cp conf/ecshop.conf /usr/local/nginx/conf/ecshop.conf
cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf

cd $cur_dir
cp vhost.sh /root/vhost.sh
chmod +x /root/vhost.sh

mkdir -p /home/wwwroot/default
chmod +w /home/wwwroot/default
mkdir -p /home/wwwlogs
chmod 777 /home/wwwlogs

chown -R www:www /home/wwwroot/default
}

function CreatPHPTools()
{
	echo "Create PHP Info Tool..."
cat >/home/wwwroot/default/phpinfo.php<<eof
<?
phpinfo();
?>
eof

echo "Copy PHP Prober..."
cd $cur_dir
tar zxvf p.tar.gz
cp p.php /home/wwwroot/default/p.php

cp conf/index.html /home/wwwroot/default/index.html
echo "============================Install PHPMyAdmin================================="
if [ "$isinstallphp53" = "n" ]; then
	tar zxf phpmyadmin-latest.tar.gz
	mv phpMyAdmin-3.4.8-all-languages /home/wwwroot/default/phpmyadmin
else
	tar zxf phpMyAdmin-lasest.tar.gz
	mv phpMyAdmin-*-all-languages /home/wwwroot/default/phpmyadmin
fi
cp conf/config.inc.php /home/wwwroot/default/phpmyadmin/config.inc.php
sed -i 's/LNMPORG/LNMP.org'$RANDOM'VPSer.net/g' /home/wwwroot/default/phpmyadmin/config.inc.php
mkdir /home/wwwroot/default/phpmyadmin/upload/
mkdir /home/wwwroot/default/phpmyadmin/save/
chmod 755 -R /home/wwwroot/default/phpmyadmin/
chown www:www -R /home/wwwroot/default/phpmyadmin/
echo "============================phpMyAdmin install completed================================="
}

function AddAndStartup()
{
echo "============================add nginx and php-fpm on startup============================"
echo "Download new nginx init.d file......"
wget -c http://soft.vpser.net/lnmp/ext/init.d.nginx
cp init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

chkconfig --level 345 php-fpm on
chkconfig --level 345 nginx on
if [ "$isinstallmysql55" = "md" ]; then
	chkconfig --level 345 mariadb on
else
	chkconfig --level 345 mysql on
fi

if [ "$isinstallmysql55" = "md" ]; then
	sed -i 's:/etc/init.d/mysql:/etc/init.d/mariadb:g' /root/lnmp
fi
echo "===========================add nginx and php-fpm on startup completed===================="
echo "Starting LNMP..."
if [ "$isinstallmysql55" = "md" ]; then
	/etc/init.d/mariadb start
else
	/etc/init.d/mysql start
fi
/etc/init.d/php-fpm start
/etc/init.d/nginx start

#add iptables firewall rules
if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 3306 -j DROP
/sbin/iptables-save
fi
}

function CheckInstall()
{
echo "===================================== Check install ==================================="
clear
isnginx=""
ismysql=""
isphp=""
echo "Checking..."
if [ -s /usr/local/nginx/conf/nginx.conf ] && [ -s /usr/local/nginx/sbin/nginx ]; then
  echo "Nginx: OK"
  isnginx="ok"
  else
  echo "Error: /usr/local/nginx not found!!!Nginx install failed."
fi

if [ "$isinstallmysql55" = "md" ]; then
	if [ -s /usr/local/mariadb/bin/mysql ] && [ -s /usr/local/mariadb/bin/mysqld_safe ] && [ -s /etc/my.cnf ]; then
	  echo "MariaDB: OK"
	  ismysql="ok"
	  else
	  echo "Error: /usr/local/mariadb not found!!!MySQL install failed."
	fi
else
	if [ -s /usr/local/mysql/bin/mysql ] && [ -s /usr/local/mysql/bin/mysqld_safe ] && [ -s /etc/my.cnf ]; then
	  echo "MySQL: OK"
	  ismysql="ok"
	  else
	  echo "Error: /usr/local/mysql not found!!!MySQL install failed."
	fi
fi

if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ]; then
  echo "PHP: OK"
  echo "PHP-FPM: OK"
  isphp="ok"
  else
  echo "Error: /usr/local/php not found!!!PHP install failed."
fi
if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
echo "Install lnmp 1.1 completed! enjoy it."
echo "========================================================================="
echo "LNMP V1.1 for CentOS/RadHat Linux Server, Written by Licess "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo ""
echo "lnmp status manage: /root/lnmp {start|stop|reload|restart|kill|status}"
echo "default mysql root password:$mysqlrootpwd"
echo "phpinfo : http://yourIP/phpinfo.php"
echo "phpMyAdmin : http://yourIP/phpmyadmin/"
echo "Prober : http://yourIP/p.php"
echo "Add VirtualHost : /root/vhost.sh"
echo ""
echo "The path of some dirs:"
echo "mysql dir:   /usr/local/mysql"
echo "php dir:     /usr/local/php"
echo "nginx dir:   /usr/local/nginx"
echo "web dir :     /home/wwwroot/default"
echo ""
echo "========================================================================="
/root/lnmp status
netstat -ntl
else
echo "Sorry,Failed to install LNMP!"
echo "Please visit http://bbs.vpser.net/forum-25-1.html feedback errors and logs."
echo "You can download /root/lnmp-install.log from your server,and upload lnmp-install.log to LNMP Forum."
fi
}

InitInstall 2>&1 | tee /root/lnmp-install.log
CheckAndDownloadFiles 2>&1 | tee -a /root/lnmp-install.log
InstallDependsAndOpt 2>&1 | tee -a /root/lnmp-install.log
if [ "$isinstallmysql55" = "n" ]; then
	InstallMySQL51 2>&1 | tee -a /root/lnmp-install.log
elif [ "$isinstallmysql55" = "y" ]; then
	InstallMySQL55 2>&1 | tee -a /root/lnmp-install.log
else
	InstallMariaDB 2>&1 | tee -a /root/lnmp-install.log
fi
if [ "$isinstallphp53" = "n" ]; then
	InstallPHP52 2>&1 | tee -a /root/lnmp-install.log
else
	InstallPHP53 2>&1 | tee -a /root/lnmp-install.log
fi
InstallNginx 2>&1 | tee -a /root/lnmp-install.log
CreatPHPTools 2>&1 | tee -a /root/lnmp-install.log
AddAndStartup 2>&1 | tee -a /root/lnmp-install.log
CheckInstall 2>&1 | tee -a /root/lnmp-install.log