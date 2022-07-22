#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

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
. include/apcu.sh
. include/php_exif.sh
. include/php_fileinfo.sh
. include/php_ldap.sh
. include/php_bz2.sh
. include/php_sodium.sh
. include/php_imap.sh
. include/php_swoole.sh
. include/php_SourceGuardian.sh

Display_Addons_Menu()
{
    echo "##### cache / optimizer / accelerator #####"
    echo "  1: eAccelerator"
    echo "  2: XCache"
    echo "  3: Memcached"
    echo "  4: opcache"
    echo "  5: Redis"
    echo "  6: apcu"
    echo "##### Image Processing #####"
    echo "  7: imageMagick"
    echo "##### encryption/decryption utility for PHP #####"
    echo "  8: ionCube Loader"
    echo "  9: SourceGuardian Loader"
    echo "##### PHP Modules/Extensions #####"
    echo " 10: Exif"
    echo " 11: Fileinfo"
    echo " 12: Ldap"
    echo " 13: Bz2"
    echo " 14: Sodium"
    echo " 15: Imap"
    echo " 16: Swoole"
    echo "#################################################"
    echo " exit: Exit current script"
    echo "#################################################"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7, 8... or exit): " action2
}

Restart_PHP()
{
    if [ -s /usr/local/apache/bin/httpd ] && [ -s /usr/local/apache/conf/httpd.conf ] && [ -s /etc/init.d/httpd ]; then
        echo "Restarting Apache......"
        /etc/init.d/httpd restart
    else
        echo "Restarting php-fpm......"
        ${PHPFPM_Initd} restart
    fi
}

clear
echo "+-----------------------------------------------------------------------+"
echo "|            Addons script for LNMP V1.9, Written by Licess             |"
echo "+-----------------------------------------------------------------------+"
echo "|    A tool to Install cache,optimizer,accelerator...addons for LNMP    |"
echo "+-----------------------------------------------------------------------+"
echo "|           For more information please visit https://lnmp.org          |"
echo "+-----------------------------------------------------------------------+"

Select_PHP()
{
    if [ "${action2}" == "exit" ]; then
        exit 1
    fi
    if [[ ! -s /usr/local/php5.2/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.2.conf ]] && [[ ! -s /usr/local/php5.3/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.3.conf ]] && [[ ! -s /usr/local/php5.4/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.4.conf ]] && [[ ! -s /usr/local/php5.5/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.5.conf ]] && [[ ! -s /usr/local/php5.6/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php5.6.conf ]] && [[ ! -s /usr/local/php7.0/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.0.conf ]] && [[ ! -s /usr/local/php7.1/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.1.conf ]] && [[ ! -s /usr/local/php7.2/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.2.conf ]] && [[ ! -s /usr/local/php7.3/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.3.conf ]] && [[ ! -s /usr/local/php7.4/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php7.4.conf ]] && [[ ! -s /usr/local/php8.0/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.0.conf ]] && [[ ! -s /usr/local/php8.1/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.1.conf ]]; then
        PHP_Path='/usr/local/php'
        PHPFPM_Initd='/etc/init.d/php-fpm'
    else
        echo "Multiple PHP version found, Please select the PHP version."
        Cur_PHP_Version="`/usr/local/php/bin/php-config --version`"
        Echo_Green "1: Default Main PHP ${Cur_PHP_Version}"
        if [[ -s /usr/local/php5.2/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.2.conf && -s /etc/init.d/php-fpm5.2 ]]; then
            Echo_Green "2: PHP 5.2 [found]"
        fi
        if [[ -s /usr/local/php5.3/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.3.conf && -s /etc/init.d/php-fpm5.3 ]]; then
            Echo_Green "3: PHP 5.3 [found]"
        fi
        if [[ -s /usr/local/php5.4/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.4.conf && -s /etc/init.d/php-fpm5.4 ]]; then
            Echo_Green "4: PHP 5.4 [found]"
        fi
        if [[ -s /usr/local/php5.5/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.5.conf && -s /etc/init.d/php-fpm5.5 ]]; then
            Echo_Green "5: PHP 5.5 [found]"
        fi
        if [[ -s /usr/local/php5.6/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php5.6.conf && -s /etc/init.d/php-fpm5.6 ]]; then
            Echo_Green "6: PHP 5.6 [found]"
        fi
        if [[ -s /usr/local/php7.0/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.0.conf && -s /etc/init.d/php-fpm7.0 ]]; then
            Echo_Green "7: PHP 7.0 [found]"
        fi
        if [[ -s /usr/local/php7.1/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.1.conf && -s /etc/init.d/php-fpm7.1 ]]; then
            Echo_Green "8: PHP 7.1 [found]"
        fi
        if [[ -s /usr/local/php7.2/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.2.conf && -s /etc/init.d/php-fpm7.2 ]]; then
            Echo_Green "9: PHP 7.2 [found]"
        fi
        if [[ -s /usr/local/php7.3/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.3.conf && -s /etc/init.d/php-fpm7.3 ]]; then
            Echo_Green "10: PHP 7.3 [found]"
        fi
        if [[ -s /usr/local/php7.4/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php7.4.conf && -s /etc/init.d/php-fpm7.4 ]]; then
            Echo_Green "11: PHP 7.4 [found]"
        fi
        if [[ -s /usr/local/php8.0/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.0.conf && -s /etc/init.d/php-fpm8.0 ]]; then
            Echo_Green "12: PHP 8.0 [found]"
        fi
        if [[ -s /usr/local/php8.1/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.1.conf && -s /etc/init.d/php-fpm8.1 ]]; then
            Echo_Green "13: PHP 8.1 [found]"
        fi
        Echo_Yellow "Enter your choice (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 or 13): "
        read php_select
        case "${php_select}" in
            1)
                echo "Current selection: PHP ${Cur_PHP_Version}"
                PHP_Path='/usr/local/php'
                PHPFPM_Initd='/etc/init.d/php-fpm'
                ;;
            2)
                echo "Current selection: PHP `/usr/local/php5.2/bin/php-config --version`"
                PHP_Path='/usr/local/php5.2'
                PHPFPM_Initd='/etc/init.d/php-fpm5.2'
                ;;
            3)
                echo "Current selection: PHP `/usr/local/php5.3/bin/php-config --version`"
                PHP_Path='/usr/local/php5.3'
                PHPFPM_Initd='/etc/init.d/php-fpm5.3'
                ;;
            4)
                echo "Current selection: PHP `/usr/local/php5.4/bin/php-config --version`"
                PHP_Path='/usr/local/php5.4'
                PHPFPM_Initd='/etc/init.d/php-fpm5.4'
                ;;
            5)
                echo "Current selection: PHP `/usr/local/php5.5/bin/php-config --version`"
                PHP_Path='/usr/local/php5.5'
                PHPFPM_Initd='/etc/init.d/php-fpm5.5'
                ;;
            6)
                echo "Current selection: PHP `/usr/local/php5.6/bin/php-config --version`"
                PHP_Path='/usr/local/php5.6'
                PHPFPM_Initd='/etc/init.d/php-fpm5.6'
                ;;
            7)
                echo "Current selection: PHP `/usr/local/php7.0/bin/php-config --version`"
                PHP_Path='/usr/local/php7.0'
                PHPFPM_Initd='/etc/init.d/php-fpm7.0'
                ;;
            8)
                echo "Current selection: PHP `/usr/local/php7.1/bin/php-config --version`"
                PHP_Path='/usr/local/php7.1'
                PHPFPM_Initd='/etc/init.d/php-fpm7.1'
                ;;
            9)
                echo "Current selection: PHP `/usr/local/php7.2/bin/php-config --version`"
                PHP_Path='/usr/local/php7.2'
                PHPFPM_Initd='/etc/init.d/php-fpm7.2'
                ;;
            10)
                echo "Current selection: PHP `/usr/local/php7.3/bin/php-config --version`"
                PHP_Path='/usr/local/php7.3'
                PHPFPM_Initd='/etc/init.d/php-fpm7.3'
                ;;
            11)
                echo "Current selection: PHP `/usr/local/php7.4/bin/php-config --version`"
                PHP_Path='/usr/local/php7.4'
                PHPFPM_Initd='/etc/init.d/php-fpm7.4'
                ;;
            12)
                echo "Current selection: PHP `/usr/local/php8.0/bin/php-config --version`"
                PHP_Path='/usr/local/php8.0'
                PHPFPM_Initd='/etc/init.d/php-fpm8.0'
                ;;
            13)
                echo "Current selection: PHP `/usr/local/php8.1/bin/php-config --version`"
                PHP_Path='/usr/local/php8.1'
                PHPFPM_Initd='/etc/init.d/php-fpm8.1'
                ;;
            *)
                echo "Default,Current selection: PHP ${Cur_PHP_Version}"
                php_select="1"
                PHP_Path='/usr/local/php'
                PHPFPM_Initd='/etc/init.d/php-fpm'
                ;;
        esac
    fi
}

Addons_Get_PHP_Ext_Dir()
{
    Cur_PHP_Version="`${PHP_Path}/bin/php-config --version`"
    zend_ext_dir="`${PHP_Path}/bin/php-config --extension-dir`/"
}

Download_PHP_Src()
{
     if [ -s php-${Cur_PHP_Version}.tar.bz2 ]; then
        echo "php-${Cur_PHP_Version}.tar.bz2 [found]"
    else
        echo "Notice: php-${Cur_PHP_Version}.tar.bz2 not found!!!download now..."
        Get_Country
        if [ "${country}" = "CN" ]; then
            Download_Files http://php.vpszt.com/php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}.tar.bz2
            if [ $? -ne 0 ]; then
                Download_Files https://www.php.net/distributions/php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}.tar.bz2
            fi
        else
            Download_Files https://www.php.net/distributions/php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}.tar.bz2
            if [ $? -ne 0 ]; then
                Download_Files http://php.vpszt.com/php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}.tar.bz2
            fi
        fi
        if [ $? -eq 0 ]; then
            echo "Download php-${Cur_PHP_Version}.tar.bz2 successfully!"
        else
            Download_Files http://museum.php.net/php5/php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}.tar.bz2
            if [ $? -eq 0 ]; then
                echo "Download php-${Cur_PHP_Version}.tar.bz2 successfully!"
            else
                Echo_Red "Error! Can't download PHP ${Cur_PHP_Version}, please check!"
                exit 1
            fi
        fi
    fi
}

if [[ "${action}" == "" || "${action2}" == "" ]]; then
    action='install'
    Display_Addons_Menu
fi
Get_Dist_Name
Select_PHP

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
            6|apcu)
                Install_Apcu
                ;;
            7|image[mM]agick)
                Install_ImageMagic
                ;;
            8|ion[cC]ube)
                Install_ionCube
                ;;
            9|[sS][gG])
                Install_SourceGuardian
                ;;
            10|[eE]xif)
                Install_PHP_Exif
                ;;
            11|[fF]ileinfo)
                Install_PHP_Fileinfo
                ;;
            12|[lL]dap)
                Install_PHP_Ldap
                ;;
            13|[bB]z2)
                Install_PHP_Bz2
                ;;
            14|[sS]odium)
                Install_PHP_Sodium
                ;;
            15|[iI]map)
                Install_PHP_Imap
                ;;
            16|[sS]woole)
                Install_PHP_Swoole
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                echo "Usage: ./addons.sh install {eaccelerator|xcache|memcached|opcache|redis|imagemagick|ioncube|sg|exif|fileinfo|ldap|bz2|sodium|imap|swoole}"
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
            apcu)
                Uninstall_Apcu
                ;;
            image[mM]agick)
                Uninstall_ImageMagick
                ;;
            ion[cC]ube)
                Uninstall_ionCube
                ;;
            [sS][gG])
                Uninstall_SourceGuardian
                ;;
            [eE]xif)
                Uninstall_PHP_Exif
                ;;
            [fF]ileinfo)
                Uninstall_PHP_Fileinfo
                ;;
            [lL]dap)
                Uninstall_PHP_Ldap
                ;;
            [bB]z2)
                Uninstall_PHP_Bz2
                ;;
            [sS]odium)
                Uninstall_PHP_Sodium
                ;;
            [iI]map)
                Uninstall_PHP_Imap
                ;;
            [sS]woole)
                Uninstall_PHP_Swoole
                ;;
            *)
                echo "Usage: ./addons.sh uninstall {eaccelerator|xcache|memcached|opcache|redis|apcu|imagemagick|ioncube|sg|exif|fileinfo|ldap|bz2|sodium|imap|swoole}"
                ;;
        esac
        ;;
    [eE][xX][iI][tT])
        exit 1
        ;;
    *)
        echo "Usage: ./addons.sh {install|uninstall} {eaccelerator|xcache|memcached|opcache|redis|apcu|imagemagick|ioncube|sg|exif|fileinfo|ldap|bz2|sodium|imap|swoole}"
        exit 1
        ;;
    esac
