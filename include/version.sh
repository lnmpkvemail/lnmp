#!/bin/bash

Autoconf_Ver='autoconf-2.13'
Libiconv_Ver='libiconv-1.14'
LibMcrypt_Ver='libmcrypt-2.5.8'
Mcypt_Ver='mcrypt-2.6.8'
Mash_Ver='mhash-0.9.9.9'
Freetype_Ver='freetype-2.4.12'
Curl_Ver='curl-7.42.1'
Pcre_Ver='pcre-8.36'
Jemalloc_Ver='jemalloc-4.0.3'
TCMalloc_Ver='gperftools-2.4'
Libunwind_Ver='libunwind-1.1'
Libicu4c_Ver='icu4c-55_1'
Nginx_Ver='nginx-1.8.0'
Mysql_Ver='mysql-5.5.45'
Mariadb_Ver='mariadb-5.5.45'
if [ "${DBSelect}" = "1" ]; then
    Mysql_Ver='mysql-5.1.73'
elif [ "${DBSelect}" = "2" ]; then
    Mysql_Ver='mysql-5.5.45'
elif [ "${DBSelect}" = "3" ]; then
    Mysql_Ver='mysql-5.6.26'
elif [ "${DBSelect}" = "4" ]; then
    Mariadb_Ver='mariadb-5.5.45'
elif [ "${DBSelect}" = "5" ]; then
    Mariadb_Ver='mariadb-10.0.21'
fi
Php_Ver='php-5.4.45'
if [ "${PHPSelect}" = "1" ]; then
    Php_Ver='php-5.2.17'
elif [ "${PHPSelect}" = "2" ]; then
    Php_Ver='php-5.3.29'
elif [ "${PHPSelect}" = "3" ]; then
    Php_Ver='php-5.4.45'
elif [ "${PHPSelect}" = "4" ]; then
    Php_Ver='php-5.5.30'
elif [ "${PHPSelect}" = "5" ]; then
    Php_Ver='php-5.6.14'
elif [ "${PHPSelect}" = "6" ]; then
    Php_Ver='php-7.0.0RC5'
fi
PhpMyAdmin_Ver='phpMyAdmin-4.4.14-all-languages'
if [ "${PHPSelect}" = "1" ]; then
    PhpMyAdmin_Ver='phpMyAdmin-4.0.10.10-all-languages'
else
    PhpMyAdmin_Ver='phpMyAdmin-4.4.14-all-languages'
    if [ "${DBSelect}" = "1" ]; then
        PhpMyAdmin_Ver='phpMyAdmin-4.0.10.10-all-languages'
    fi
fi
APR_Ver='apr-1.5.2'
APR_Util_Ver='apr-util-1.5.4'
Mod_RPAF_Ver='mod_rpaf-0.8.4-rc3'
Apache_Ver='httpd-2.2.31'
if [ "${ApacheSelect}" = "1" ]; then
    Apache_Ver='httpd-2.2.31'
elif [ "${ApacheSelect}" = "2" ]; then
    Apache_Ver='httpd-2.4.16'
fi

Pureftpd_Ver='pure-ftpd-1.0.42'

XCache_Ver='xcache-3.2.0'
ImageMagick_Ver='ImageMagick-6.9.2-3'
Imagick_Ver='imagick-3.3.0RC2'
ZendOpcache_Ver='zendopcache-7.0.5'
Redis_Stable_Ver='redis-3.0.4'
Redis_Old_Ver='redis-2.8.22'
PHPRedis_Ver='redis-2.2.7'
Memcached_Ver='memcached-1.4.24'
Libmemcached_Ver='libmemcached-1.0.18'
PHPMemcached_Ver='memcached-2.2.0'
PHPMemcache_Ver='memcache-3.0.8'

if [ "${Stack}" != "" ]; then
    echo "You will install ${Stack} stack."
    if [ "${Stack}" != "lamp" ]; then
        echo ${Nginx_Ver}
    fi

    if [[ "${DBSelect}" = "1" || "${DBSelect}" = "2" || "${DBSelect}" = "3" ]]; then
        echo "${Mysql_Ver}"
    elif [[ "${DBSelect}" = "4" || "${DBSelect}" = "5" ]]; then
        echo "${Mariadb_Ver}"
    fi

    echo "${Php_Ver}"

    if [ "${Stack}" != "lnmp" ]; then
        echo "${Apache_Ver}"
    fi

    if [ "${SelectMalloc}" = "2" ]; then
        echo "${Jemalloc_Ver}"
    elif [ "${SelectMalloc}" = "3" ]; then
        echo "${TCMalloc_Ver}"
    fi
    echo "Enable InnoDB: ${InstallInnodb}"
fi
