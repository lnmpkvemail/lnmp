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
echo "Upgrade MySQL for LNMP,  Written by Licess"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo "========================================================================="
cur_dir=$(pwd)
upgrade_date=$(date +"%Y%m%d")
shopt -s extglob

old_mysql_version=`/usr/local/mysql/bin/mysql -V | awk '{print $5}' | tr -d ","`
#echo $old_mysql_version


	read -p "Please input your MySQL root password:" mysql_root_password
cat >testmysqlrootpassword.sql<<EOF
quit
EOF
	/usr/local/mysql/bin/mysql -uroot -p$mysql_root_password<testmysqlrootpassword.sql
	if [ $? -eq 0 ]; then
		echo "MySQL root password correct.";
	else
		echo "MySQL root password incorrect!Please check!"
		exit 1
	fi
	rm -rf testmysqlrootpassword.sql
#set mysql version

	mysql_version=""
	echo "Current MYSQL Version:$old_mysql_version"
	echo "You can get version number from http://dev.mysql.com/downloads/mysql/"
	echo "Please input MySQL Version you want."
	read -p "(example: 5.5.36 ):" mysql_version
	if [ "$mysql_version" = "" ]; then
		echo "Error: You must input MySQL Version!!"
		exit 1
	fi

	if [ "$mysql_version" == "$old_mysql_version" ]; then
		echo "Error: The upgrade MYSQL Version is the same as the old Version!!"
		exit 1
	fi

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

	mysql_short_version=`echo $mysql_version | cut -d. -f1-2`

	echo "=================================================="
	echo "You want to upgrade MySQL Version to $mysql_version"
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
if [ -s mysql-$mysql_version.tar.gz ]; then
  	echo "mysql-$mysql_version.tar.gz [found]"
  else
  	echo "Error: mysql-$mysql_version.tar.gz not found!!!download now......"
  	wget -c http://cdn.mysql.com/Downloads/MySQL-$mysql_short_version/mysql-$mysql_version.tar.gz
	if [ $? -eq 0 ]; then
		echo "Download mysql-$mysql_version.tar.gz successfully!"
	else
		echo "WARNING!May be the MySQL Version you input was wrong,please check!"
		echo "MySQL Version input was:"$mysql_version
		sleep 5
		exit 1
	fi
fi
echo "============================check files=================================="

function stopall {
	echo "Stoping Nginx..."
	/etc/init.d/nginx stop
	if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
	echo "Stoping Apache......"
	/etc/init.d/httpd -k stop
	else
	echo "Stoping php-fpm......"
	/etc/init.d/php-fpm stop
	fi
	if [ -s /etc/init.d/memceached ]; then
  		echo "Stoping Memcached..."
 		/etc/init.d/memcacehd stop
	fi	
}

function backup_mysql {
	echo "Starting backup all databases..."
	echo "If the database is large, the backup time will be longer."
	/usr/local/mysql/bin/mysqldump -uroot -p$mysql_root_password --all-databases > /root/mysql_all_backup$(date +"%Y%m%d").sql
	if [ $? -eq 0 ]; then
		echo "MySQL databases backup successfully.";
	else
		echo "MySQL databases backup failed,Please backup databases manually!"
		exit 1
	fi
	echo "Stoping MySQL..."
	/etc/init.d/mysql stop
	mv /etc/init.d/mysql /etc/init.d/mysql.bak.$upgrade_date
	mv /etc/my.cnf /etc/my.conf.bak.$upgrade_date
	rm -rf /usr/local/mysql/!(var|data)
}

function upgrade_mysql51 {
	cd $cur_dir
	rm -f /etc/my.cnf
	rm -rf mysql-$mysql_version/

	tar zxf mysql-$mysql_version.tar.gz
	cd mysql-$mysql_version/
	if [ $installinnodb = "y" ]; then
	./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=innobase
	else
	./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile
	fi
	cat Makefile | sed '/set -ex;/,/done/d' > Makefile.1
	rm Makefile
	mv Makefile.1 Makefile
	make && make install
	cd ../

	groupadd mysql
	useradd -s /sbin/nologin -g mysql mysql
	cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
	sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
	if [ $installinnodb = "y" ]; then
		sed -i 's:#innodb:innodb:g' /etc/my.cnf
		sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
	else
		sed '/skip-external-locking/i\nloose-skip-innodb' -i /etc/my.cnf
	fi
}

function upgrade_mysql55 {
	echo "Starting upgrade MySQL..."
	cat /etc/issue | grep -Eqi '(Debian|Ubuntu)' && apt-get update;apt-get install cmake -y || yum -y install cmake
	rm -rf mysql-$mysql_version/
	wget -c http://soft.vpser.net/lnmp/ext/mysql-openssl.patch

	tar zxf mysql-$mysql_version.tar.gz
	cd mysql-$mysql_version/
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

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig
}

function upgrade_mysql56 {
	echo "Starting upgrade MySQL..."
	cat /etc/issue | grep -Eqi '(Debian|Ubuntu)' && apt-get update;apt-get install cmake -y || yum -y install cmake
	rm -rf mysql-$mysql_version/

	tar zxf mysql-$mysql_version.tar.gz
	cd mysql-$mysql_version/
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
	make && make install

	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql
cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

# The MySQL server
[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

#skip-networking

# Replication Master Server (default)
# binary logging is required for replication
log-bin=mysql-bin

# binary logging format - mixed recommended
binlog_format=mixed

# required unique id between 1 and 2^32 - 1
# defaults to 1 if master-host is not set
# but will not function as a master if omitted
server-id	= 1

# Uncomment the following if you are using InnoDB tables
#innodb_data_home_dir = /usr/local/mysql/data
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = /usr/local/mysql/data
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
#innodb_buffer_pool_size = 16M
#innodb_additional_mem_pool_size = 2M
# Set .._log_file_size to 25 % of buffer pool size
#innodb_log_file_size = 5M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF
	sed '/skip-external-locking/i\datadir = /usr/local/mysql/var' -i /etc/my.cnf
	if [ $installinnodb = "y" ]; then
		sed -i 's:#innodb:innodb:g' /etc/my.cnf
		sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
	else
		sed '/skip-external-locking/i\default-storage-engine=MyISAM\ndefault-tmp-storage-engine=MYISAM\nloose-skip-innodb' -i /etc/my.cnf
	fi

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig
}

function startall {
	cp $cur_dir/mysql-$mysql_version/support-files/mysql.server /etc/init.d/mysql
	chmod 755 /etc/init.d/mysql

	ldconfig

	if [ -d "/proc/vz" ];then
		ulimit -s unlimited
	fi
	/etc/init.d/mysql start

	echo "Repair databases..."
	/usr/local/mysql/bin/mysql_upgrade -u root -p$mysql_root_password

	ln -sf /usr/local/mysql/bin/mysql /usr/bin/mysql
	ln -sf /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
	ln -sf /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
	ln -sf /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

	echo "Start Nginx..."
	/etc/init.d/nginx start
	if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
	echo "Start Apache......"
	/etc/init.d/httpd -k start
	else
	echo "Start php-fpm......"
	/etc/init.d/php-fpm start
	fi
	if [ -s /etc/init.d/memceached ]; then
		echo "Start Memcached..."
		/etc/init.d/memcacehd start
	fi
	echo "Restart MySQL..."
	/etc/init.d/mysql restart

	cd $cur_dir
}


stopall  2>&1 | tee -a /root/mysql_upgrade$upgrade_date.log

backup_mysql  2>&1 | tee -a /root/mysql_upgrade$upgrade_date.log

if [ $mysql_short_version = "5.1" ]; then
	upgrade_mysql51  2>&1 | tee -a /root/mysql_upgrade$upgrade_date.log
elif [ $mysql_short_version = "5.5" ]; then
	upgrade_mysql55  2>&1 | tee -a /root/mysql_upgrade$upgrade_date.log
elif [ $mysql_short_version = "5.6" ]; then
	upgrade_mysql56  2>&1 | tee -a /root/mysql_upgrade$upgrade_date.log
fi

startall  2>&1 | tee -a /root/mysql_upgrade$upgrade_date.log

echo "========================================================================="
echo "You have successfully upgrade from $old_mysql_version to $mysql_version"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo ""
echo "========================================================================="