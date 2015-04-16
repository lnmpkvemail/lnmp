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
echo "Install eAcesselerator for LNMP  ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install eAccelerator for lnmp "
echo ""
echo "For more information please visit http://www.lnmp.org "
echo "======================================================================="
cur_dir=$(pwd)

	ver="old"
	echo "Which version do you want to install:"
	echo "Install eaccelerator 0.9.5.3 please type: old"
	echo "Install eaccelerator 0.9.6.1 please type: new"
	echo "Install eaccelerator 1.0-dev please type: dev"
	read -p "Type old, new or dev (Default version old):" ver
	if [ "$ver" = "" ]; then
		ver="old"
	fi

	if [ "$ver" = "old" ]; then
		echo "You will install eaccelerator 0.9.5.3"
	elif  [ "$ver" = "new" ]; then
		echo "You will install eaccelerator 0.9.6.1"
	elif [ "$ver" = "dev" ]; then
		echo "You will install eaccelerator 1.0-dev"
	else
		echo "Input error,please input old, new or dev !"
		echo "Please Rerun $0"
		exit 1
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
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

echo "=========================== install eaccelerator ======================"

if [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/eaccelerator.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/eaccelerator.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/eaccelerator.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/eaccelerator.so
elif [ -s /usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/eaccelerator.so ]; then
	rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/eaccelerator.so
fi

cur_php_version=`/usr/local/php/bin/php -v`
if [[ "$cur_php_version" =~ "PHP 5.2." ]]; then
   zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/eaccelerator.so"
elif [[ "$cur_php_version" =~ "PHP 5.3." ]]; then
   zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so"
elif [[ "$cur_php_version" =~ "PHP 5.4." ]]; then
   zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/eaccelerator.so"
elif [[ "$cur_php_version" =~ "PHP 5.5." ]]; then
   zend_ext="/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/eaccelerator.so"
else
	echo "Error: can't get php version!"
	echo "Maybe your php was didn't install or php configuration file has errors.Please check."
	sleep 3
	exit 1
fi

#Install eaccelerator 0.9.5.3
function install_old_ea {
if [ -s eaccelerator-0.9.5.3 ]; then
	rm -rf eaccelerator-0.9.5.3/
fi

if [[ "$cur_php_version" =~ "PHP 5.3." ]] || [[ "$cur_php_version" =~ "PHP 5.4." ]] || [[ "$cur_php_version" =~ "PHP 5.5." ]]; then
	echo "PHP 5.3.* , PHP 5.4.* , PHP 5.5.* Can't install eaccelerator 0.9.5.3!"
	echo "PHP 5.3.* please input new or dev !"
	echo "PHP 5.4.* and 5.5.* please input dev !"
	exit 1 
fi

wget -c http://soft.vpser.net/web/eaccelerator/eaccelerator-0.9.5.3.tar.bz2
tar jxvf eaccelerator-0.9.5.3.tar.bz2
cd eaccelerator-0.9.5.3/
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config --with-eaccelerator-shared-memory
make
make install
cd ../
}

#Install eaccelerator 0.9.6.1
function install_new_ea {
if [ -s eaccelerator-0.9.6.1 ]; then
rm -rf eaccelerator-0.9.6.1/
fi

if [[ "$cur_php_version" =~ "PHP 5.4." ]] || [[ "$cur_php_version" =~ "PHP 5.5." ]]; then
	echo "PHP 5.4.* Can't install eaccelerator 0.9.6.1!"
	echo "PHP 5.4.* and 5.5.* please input dev !"
	exit 1 
fi

wget -c http://soft.vpser.net/web/eaccelerator/eaccelerator-0.9.6.1.tar.bz2
tar jxvf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1/
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
make
make install
cd ../
}

#Install eaccelerator git master branch 42067ac
function install_dev_ea {
if [ -s eaccelerator-eaccelerator-42067ac ]; then
rm -rf eaccelerator-eaccelerator-42067ac/
fi

wget -c http://soft.vpser.net/web/eaccelerator/eaccelerator-eaccelerator-42067ac.tar.gz
tar zxvf eaccelerator-eaccelerator-42067ac.tar.gz
cd eaccelerator-eaccelerator-42067ac/
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
make
make install
cd ../
}

if [ "$ver" = "old" ]; then
	install_old_ea
elif [ "$ver" = "new" ]; then
	install_new_ea
else
	install_dev_ea
fi

mkdir -p /usr/local/eaccelerator_cache
rm -rf /usr/local/eaccelerator_cache/*
sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini

cat >ea.ini<<EOF
[eaccelerator]
zend_extension="$zend_ext"
eaccelerator.shm_size="1"
eaccelerator.cache_dir="/usr/local/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="3600"
eaccelerator.shm_prune_period="3600"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "disk_only"

EOF

sed -i '/;eaccelerator/ {
r ea.ini
}' /usr/local/php/etc/php.ini

if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

rm ea.ini

echo "===================== install eaccelerator completed ==================="
echo "Install eAccelerator completed,enjoy it!"
echo "======================================================================="
echo "Install eAcesselerator for LNMP  ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install eAccelerator for lnmp "
echo ""
echo "For more information please visit http://www.lnmp.org "
echo "======================================================================="