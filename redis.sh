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
echo "Install Redis for LNMP  ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install Redis for lnmp "
echo ""
echo "For more information please visit http://www.lnmp.org "
echo "======================================================================="
cur_dir=$(pwd)

    ver="old"
    echo "Which version do you want to install:"
    echo "Install Redis 2.8.8   Stable Version please type: s"
    echo "Install Redis 3.0.0   Beta Version please type: b"
    echo "Install Redis 2.6.17  Old Version please type: o"
    read -p "Type s, b or o (Default Stable version):" ver
    if [ "$ver" = "" ]; then
        ver="s"
    fi

    if [ "$ver" = "s" ]; then
        echo "You will install Redis 2.8.8   Stable Version"
    elif  [ "$ver" = "b" ]; then
        echo "You will install Redis 3.0.0   Beta Version"
    elif [ "$ver" = "o" ]; then
        echo "You will install Redis 2.6.17  Old Version"
    else
        echo "Input error,please input s, b or o !"
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

echo "=========================== install Redis ======================"

#Install Redis Stable Version
function install_stable {
if [ -s redis-2.8.8 ]; then
    rm -rf redis-2.8.8/
fi

wget -c http://download.redis.io/releases/redis-2.8.8.tar.gz
tar zxf redis-2.8.8.tar.gz
cd redis-2.8.8/
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        make PREFIX=/usr/local/redis install
else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
fi
mkdir -p /usr/local/redis/etc/
cp redis.conf  /usr/local/redis/etc/
sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
cd ../
}

#Install Redis Beta Version
function install_beta {
if [ -s redis-3.0.0-beta2 ]; then
rm -rf redis-3.0.0-beta2/
fi


wget -c --no-check-certificate https://github.com/antirez/redis/archive/3.0.0-beta2.tar.gz -O redis-3.0.0-beta2.tar.gz
tar zxf redis-3.0.0-beta2.tar.gz
cd redis-3.0.0-beta2/
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        make PREFIX=/usr/local/redis install
else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
fi
mkdir -p /usr/local/redis/etc/
cp redis.conf  /usr/local/redis/etc/
sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
cd ../
}

#Install Redis old Version
function install_old {
if [ -s redis-2.6.17 ]; then
rm -rf redis-2.6.17/
fi

wget -c http://download.redis.io/releases/redis-2.6.17.tar.gz
tar zxf redis-2.6.17.tar.gz
cd redis-2.6.17/
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        make PREFIX=/usr/local/redis install
else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
fi
mkdir -p /usr/local/redis/etc/
cp redis.conf  /usr/local/redis/etc/
sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
cd ../
}

function phpredis {
<<<<<<< HEAD
	if [ -s redis-2.2.5 ]; then
	rm -rf redis-2.2.5/
	fi
	sed -i '/redis.so/d' /usr/local/php/etc/php.ini
=======
>>>>>>> 1b62bc6cfabbe74c33509128dd97d5863642005e
	wget -c http://pecl.php.net/get/redis-2.2.5.tgz
	tar zxf redis-2.2.5.tgz
	cd redis-2.2.5/
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install
	cd ../
<<<<<<< HEAD
sed -i '/the dl()/i\
extension = "redis.so"' /usr/local/php/etc/php.ini
}

function startall {
=======
	sed -i '/the dl()/i\
	extension = "redis.so"' /usr/local/php/etc/php.ini
}

function start {
>>>>>>> 1b62bc6cfabbe74c33509128dd97d5863642005e
    rm -f /etc/init.d/redis
    wget -c http://soft.vpser.net/lnmp/ext/init.d.redis -O /etc/init.d/redis
    chmod +x /etc/init.d/redis
    echo "Add to auto start..."
    if [ -s /etc/debian_version ]; then
    update-rc.d -f redis defaults
    elif [ -s /etc/redhat-release ]; then
    chkconfig --level 345 redis on
    fi
	if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
	echo "Restarting Apache......"
	/etc/init.d/httpd restart
	else
	echo "Restarting php-fpm......"
	/etc/init.d/php-fpm restart
	fi
    /etc/init.d/redis start
}

if [ "$ver" = "s" ]; then
    install_stable
elif [ "$ver" = "b" ]; then
    install_beta
else
    install_old
fi
phpredis
startall

echo "===================== install Redis completed ==================="
echo "Install Redis completed,enjoy it!"
echo "======================================================================="
echo "Install Redis for LNMP  ,  Written by Licess "
echo "======================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install Redis for lnmp "
echo ""
echo "For more information please visit http://www.lnmp.org "
echo "======================================================================="