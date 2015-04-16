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
echo "Upgrade MariaDB for LNMP,  Written by Licess"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MariaDB+PHP on Linux "
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo "========================================================================="
cur_dir=$(pwd)
upgrade_date=$(date +"%Y%m%d")

old_mariadb_version=`/usr/local/mariadb/bin/mysql -V | awk '{print $5}' | tr -d "\-MariaDB,"`
#echo $old_mariadb_version


	read -p "Please input your MariaDB root password:" mariadb_root_password
cat >testmariadbrootpassword.sql<<EOF
quit
EOF
	/usr/local/mariadb/bin/mysql -uroot -p$mariadb_root_password<testmariadbrootpassword.sql
	if [ $? -eq 0 ]; then
		echo "MariaDB root password correct.";
	else
		echo "MariaDB root password incorrect!Please check!"
		exit 1
	fi
	rm -rf testmariadbrootpassword.sql
#set mysql version

	mariadb_version=""
	echo "Current MariaDB Version:$old_mariadb_version"
	echo "You can get version number from https://downloads.mariadb.org/"
	echo "Please input MariaDB Version you want."
	read -p "(example: 5.5.36 ):" mariadb_version
	if [ "$mariadb_version" = "" ]; then
		echo "Error: You must input MariaDB Version!!"
		exit 1
	fi

	if [ "$mariadb_version" == "$old_mariadb_version" ]; then
		echo "Error: The upgrade MariaDB Version is the same as the old Version!!"
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

	echo "=================================================="
	echo "You want to upgrade MariaDB Version to $mariadb_version"
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
if [ -s mariadb-$mariadb_version.tar.gz ]; then
  	echo "mariadb-$mariadb_version.tar.gz [found]"
  else
  	echo "Error: mariadb-$mariadb_version.tar.gz not found!!!download now......"
  	wget -c https://downloads.mariadb.org/interstitial/mariadb-$mariadb_version/kvm-tarbake-jaunty-x86/mariadb-$mariadb_version.tar.gz
	if [ $? -eq 0 ]; then
		echo "Download mariadb-$mariadb_version.tar.gz successfully!"
	else
		wget -c https://downloads.mariadb.org/interstitial/mariadb-$mariadb_version/source/mariadb-$mariadb_version.tar.gz
	  	if [ $? -eq 0 ]; then
			echo "Download mariadb-$mariadb_version.tar.gz successfully!"
	  	else
			echo "WARNING!May be the MariaDB Version you input was wrong,please check!"
			echo "MariaDB Version input was:"$mariadb_version
			sleep 5
			exit 1
		fi
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
	/usr/local/mariadb/bin/mysqldump -uroot -p$mariadb_root_password --all-databases > /root/mysql_all_backup$(date +"%Y%m%d").sql
	if [ $? -eq 0 ]; then
		echo "MariaDB databases backup successfully.";
	else
		echo "MariaDB databases backup failed,Please backup databases manually!"
		exit 1
	fi
	echo "Stoping MariaDB..."
	/etc/init.d/mariadb stop
	mv /etc/init.d/mariadb /etc/init.d/mariadb.bak.$upgrade_date
	mv /etc/my.cnf /etc/my.conf.mariadbbak.$upgrade_date
}

function upgrade_mariadb {
	echo "Starting upgrade MariaDB..."
	cd $cur_dir

	rm -rf mariadb-$mariadb_version
	rm -f /etc/my.cnf
	tar zxf mariadb-$mariadb_version.tar.gz
	cd mariadb-$mariadb_version/
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

cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
/usr/local/mariadb/lib
/usr/local/lib
EOF
}

function startall {
	cp $cur_dir/mariadb-$mariadb_version/support-files/mysql.server /etc/init.d/mariadb
	chmod 755 /etc/init.d/mariadb

	ldconfig

	if [ -d "/proc/vz" ];then
		ulimit -s unlimited
	fi
	/etc/init.d/mariadb start

	echo "Repair databases..."
	/usr/local/mariadb/bin/mysql_upgrade -u root -p$mariadb_root_password

	ln -s /usr/local/mariadb/bin/mysql /usr/bin/mysql
	ln -s /usr/local/mariadb/bin/mysqldump /usr/bin/mysqldump
	ln -s /usr/local/mariadb/bin/myisamchk /usr/bin/myisamchk
	ln -s /usr/local/mariadb/bin/mysqld_safe /usr/bin/mysqld_safe

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
	echo "Restart MariaDB..."
	/etc/init.d/mariadb restart

	cd $cur_dir
}


stopall  2>&1 | tee -a /root/mariadb_upgrade$upgrade_date.log

backup_mysql  2>&1 | tee -a /root/mariadb_upgrade$upgrade_date.log

upgrade_mariadb  2>&1 | tee -a /root/mariadb_upgrade$upgrade_date.log

startall  2>&1 | tee -a /root/mariadb_upgrade$upgrade_date.log

echo "========================================================================="
echo "You have successfully upgrade MariaDB from $old_mariadb_version to $mariadb_version"
echo "========================================================================="
echo "LNMP is tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo ""
echo "========================================================================="