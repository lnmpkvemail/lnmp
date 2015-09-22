#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script"
    exit 1
fi

cur_dir=$(pwd)
action=$1
action2=$2

. lnmp.conf
. include/main.sh
. include/init.sh
. include/version.sh
. include/eaccelerator.sh
. include/xcache.sh
. include/memcached.sh
. include/opcache.sh
. include/redis.sh
. include/imageMagick.sh
. include/ionCube.sh

Display_Upgrade_Menu()
{
    echo "##### cache / optimizer / accelerator #####"
    echo "1: eAccelerator"
    echo "2: XCache"
    echo "3: Memcached"
    echo "4: opcache"
    echo "5: Redis"
    echo "##### Image Processing #####"
    echo "6: imageMagick"
    echo "##### encryption/decryption utility for PHP #####"
    echo "7: ionCube Loader"
    echo "exit: Exit current script"
    echo "#####################################################"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7 or exit): " action2
}

Restart_PHP()
{
    if [ -s /usr/local/apache/bin/httpd ] && [ -s /usr/local/apache/conf/httpd.conf ] && [ -s /etc/init.d/httpd ]; then
        echo "Restarting Apache......"
        /etc/init.d/httpd restart
    else
        echo "Restarting php-fpm......"
        /etc/init.d/php-fpm restart
    fi
}

clear
echo "+-----------------------------------------------------------------------+"
echo "|            Addons script for LNMP V1.2, Written by Licess             |"
echo "+-----------------------------------------------------------------------+"
echo "|    A tool to Install cache,optimizer,accelerator...addons for LNMP    |"
echo "+-----------------------------------------------------------------------+"
echo "|          For more information please visit http://www.lnmp.org        |"
echo "+-----------------------------------------------------------------------+"

if [[ "${action}" == "" || "${action2}" == "" ]]; then
    action='install'
    Display_Upgrade_Menu
fi
Get_OS_Bit
Get_Dist_Name

    case "${action}" in
    install)
        case "${action2}" in
            1|e[aA]ccelerator)
                Install_eAccelerator
                ;;
            2|[xX]cache)
                Install_XCache
                ;;
            3|[mM]emcached)
                Install_Memcached
                ;;
            4|opcache)
                Install_Opcache
                ;;
            5|[rR]edis)
                Install_Redis
                ;;
            6|image[mM]agick)
                Install_ImageMagic
                ;;
            7|ion[cC]ube)
                Install_ionCube
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                echo "Usage: ./addons.sh {install|uninstall} {eaccelerator|xcache|memcached|opcache|redis|imagemagick|ioncube}"
                ;;
        esac
        ;;
    uninstall)
        case "${action2}" in
            e[aA]ccelerator)
                Uninstall_eAccelerator
                ;;
            [xX]cache)
                Uninstall_XCache
                ;;
            [mM]emcached)
                Uninstall_Memcached
                ;;
            opcache)
                Uninstall_Opcache
                ;;
            [rR]edis)
                Uninstall_Redis
                ;;
            image[mM]agick)
                Uninstall_ImageMagick
                ;;
            ion[cC]ube)
                Uninstall_ionCube
                ;;
            *)
                echo "Usage: ./addons.sh {install|uninstall} {eaccelerator|xcache|memcached|opcache|redis|imagemagick|ioncube}"
                ;;
        esac
        ;;
    [eE][xX][iI][tT])
        exit 1
        ;;
    *)
        echo "Usage: ./addons.sh {install|uninstall} {eaccelerator|xcache|memcached|opcache|redis|imagemagick|ioncube}"
        exit 1
        ;;
    esac
