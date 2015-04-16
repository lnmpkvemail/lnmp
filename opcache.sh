#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
echo "======================================================================="
echo "Install Zend Opcache for LNMP  ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install Zend Opcache for lnmp "
echo ""
echo "For more information please visit http://www.lnmp.org "
echo "======================================================================="
cur_dir=$(pwd)

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

echo "=========================== install zend opcache ======================"

if [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/opcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/opcache.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/opcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/opcache.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/opcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/opcache.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so
fi

cur_php_version=`/usr/local/php/bin/php -v`
if [[ "$cur_php_version" =~ "PHP 5.2." ]]; then
	echo "Zend Opcache do NOT SUPPORT PHP 5.2.* and lower version of php 5.3"
	sleep 1
	exit 1
elif [[ "$cur_php_version" =~ "PHP 5.3." ]]; then
	if echo $cur_php_version | grep -Eqi 'PHP 5.3.[234].';then
		zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/opcache.so"
    else
        echo "If PHP under version 5.3.20, we do not recommend install opcache, it maybe cause 502 Bad Gateway error!"
		sleep 3
		exit 1
	fi
elif [[ "$cur_php_version" =~ "PHP 5.4." ]]; then
	zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/opcache.so"
elif [[ "$cur_php_version" =~ "PHP 5.5." ]]; then
	zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so"
else
	echo "Error: can't get php version!"
	echo "Maybe your php was didn't install or php configuration file has errors.Please check."
	sleep 3
	exit 1
fi

if [ -s zendopcache-7.0.3 ]; then
	rm -rf zendopcache-7.0.3/
fi

wget -c http://soft.vpser.net/web/opcache/zendopcache-7.0.3.tgz
tar zxf zendopcache-7.0.3.tgz
cd zendopcache-7.0.3/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make
make install
cd ../

sed -i '/;opcache/,/;opcache end/d' /usr/local/php/etc/php.ini
cat >>/usr/local/php/etc/php.ini<<EOF
;opcache
[Zend Opcache]
zend_extension="$zend_ext"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache end
EOF

echo "Download Opcache Control Panel..."
wget -c http://soft.vpser.net/web/opcache/ocp.php -O /home/wwwroot/default/ocp.php

if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

echo "===================== install Zend Opcache completed ==================="
echo "Install Zend Opcache completed,enjoy it!"
echo "======================================================================="
echo "Install Zend Opcache for LNMP ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install Zend Opcache for lnmp "
echo ""
echo "For more information please visit http://www.lnmp.org "
echo "======================================================================="