#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Uninstall LNMP or LNMPA,  Written by Licess"
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http:/www.lnmp.org/"
echo ""
echo 'Please backup your mysql data and configure files first!!!!!'
echo ""
echo "========================================================================="
shopt -s extglob
if [ -s /usr/local/mariadb/bin/mysql ]; then
	ismysql="no"
else
	ismysql="yes"
fi

echo ""
	uninstall=""
	echo "INPUT 1 to uninstall LNMP"
	echo "INPUT 2 to uninstall LNMPA"
	read -p "(Please input 1 or 2):" uninstall

	case "$uninstall" in
	1)
	echo "You will uninstall LNMP"
	echo -e "\033[31mPlease backup your configure files and mysql data!!!!!!\033[0m"
	echo 'The following directory or files will be remove!'
	cat << EOF
/usr/local/php
/usr/local/nginx
/usr/local/mysql
/usr/local/zend
/etc/my.cnf
/root/vhost.sh
/root/lnmp
/root/run.sh
/etc/init.d/php-fpm
/etc/init.d/nginx
/etc/init.d/mysql
EOF
	;;
	2)
	echo "You will uninstall LNMPA"
	echo -e "\033[31mPlease backup your configure files and mysql data!!!!!!\033[0m"
	echo 'The following directory or files will be remove!'
	cat << EOF
/usr/local/php
/usr/local/nginx
/usr/local/mysql
/usr/local/zend
/usr/local/apache
/etc/my.cnf
/root/vhost.sh
/root/lnmp
/root/run.sh
/etc/init.d/php-fpm
/etc/init.d/nginx
/etc/init.d/mysql
/etc/init.d/httpd
EOF
	esac

	echo -e "\033[31mPlease backup your configure files and mysql data!!!!!!\033[0m"

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
	echo "Press any key to start uninstall or Press Ctrl+c to cancel"
	char=`get_char`

function uninstall_lnmp
{
	/etc/init.d/nginx stop
	if [ "$ismysql" = "no" ]; then
		/etc/init.d/mariadb stop
	else
		/etc/init.d/mysql stop
	fi
	/etc/init.d/php-fpm stop

	rm -rf /usr/local/php
	rm -rf /usr/local/nginx
	if [ "$ismysql" = "no" ]; then
		rm -rf /usr/local/mariadb/!(var|data)
	else
		rm -rf /usr/local/mysql/!(var|data)
	fi
	rm -rf /usr/local/zend

	rm -f /etc/my.cnf
	rm -f /root/vhost.sh
	rm -f /root/lnmp
	rm -f /root/run.sh
	rm -f /etc/init.d/php-fpm
	rm -f /etc/init.d/nginx
	if [ "$ismysql" = "no" ]; then
		rm -f /etc/init.d/mariadb
	else
		rm -f /etc/init.d/mysql
	fi
	echo "LNMP Uninstall completed."
}

function uninstall_lnmpa
{
	/etc/init.d/nginx stop
	if [ "$ismysql" = "no" ]; then
		/etc/init.d/mariadb stop
	else
		/etc/init.d/mysql stop
	fi
	/etc/init.d/php-fpm stop

	rm -rf /usr/local/php
	rm -rf /usr/local/nginx
	if [ "$ismysql" = "no" ]; then
		rm -rf /usr/local/mariadb/!(var|data)
	else
		rm -rf /usr/local/mysql/!(var|data)
	fi
	rm -rf /usr/local/zend
	rm -rf /usr/local/apache

	rm -f /etc/my.cnf
	rm -f /root/vhost.sh
	rm -f /root/lnmp
	rm -f /root/run.sh
	rm -f /etc/init.d/php-fpm
	rm -f /etc/init.d/nginx
	if [ "$ismysql" = "no" ]; then
		rm -f /etc/init.d/mariadb
	else
		rm -f /etc/init.d/mysql
	fi
	rm -f /etc/init.d/httpd
	echo "LNMPA Uninstall completed."
}

if [ "$uninstall" = "1" ]; then
	uninstall_lnmp
else
	uninstall_lnmpa
fi

echo "========================================================================="
echo "Uninstall LNMP or LNMPA,  Written by Licess"
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.lnmp.org/"
echo ""
echo "========================================================================="