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
echo "Install ionCube for LNMP  ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install eAccelerator for lnmp "
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
	echo "Press any key to start install ionCube..."
	char=`get_char`

echo "=========================== install eaccelerator ======================"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    cd /usr/local/
	wget -c http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
	tar zxvf ioncube_loaders_lin_x86-64.tar.gz
else
    cd /usr/local/
	wget -c http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
	tar zxvf ioncube_loaders_lin_x86.tar.gz
fi

sed -i '/ionCube Loader/d' /usr/local/php/etc/php.ini
sed -i '/ioncube_loader_lin/d' /usr/local/php/etc/php.ini

cur_php_version=`/usr/local/php/bin/php -v`
if [[ "$cur_php_version" =~ "PHP 5.2." ]]; then
   zend_ext="/usr/local/ioncube/ioncube_loader_lin_5.2.so"
elif [[ "$cur_php_version" =~ "PHP 5.3." ]]; then
   zend_ext="/usr/local/ioncube/ioncube_loader_lin_5.3.so"
elif [[ "$cur_php_version" =~ "PHP 5.4." ]]; then
   zend_ext="/usr/local/ioncube/ioncube_loader_lin_5.4.so"
elif [[ "$cur_php_version" =~ "PHP 5.5." ]]; then
   zend_ext="/usr/local/ioncube/ioncube_loader_lin_5.5.so"
fi

cat >ionCube.ini<<EOF
[ionCube Loader]
zend_extension="$zend_ext"
EOF

sed -i '/;ionCube/ {
r ionCube.ini
}' /usr/local/php/etc/php.ini


if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

rm ionCube.ini
echo "===================== install ionCube completed ==================="

echo "Install ionCube completed,enjoy it!"
echo "======================================================================="
echo "Install ionCube for LNMP  ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install eAccelerator for lnmp "
echo ""
echo "For more information please visit http://www.lnmp.org "
echo "======================================================================="