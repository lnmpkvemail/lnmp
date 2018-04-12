#!/bin/bash

Autoconf_Ver='autoconf-2.13'
Libiconv_Ver='libiconv-1.14'
LibMcrypt_Ver='libmcrypt-2.5.8'
Mcypt_Ver='mcrypt-2.6.8'
Mhash_Ver='mhash-0.9.9.9'
Freetype_Ver='freetype-2.7'
Curl_Ver='curl-7.57.0'
Pcre_Ver='pcre-8.39'
Jemalloc_Ver='jemalloc-5.0.1'
TCMalloc_Ver='gperftools-2.6.3'
Libunwind_Ver='libunwind-1.1'
Libicu4c_Ver='icu4c-58_1'
Boost_Ver='boost_1_59_0'
Openssl_Ver='openssl-1.0.2o'
Nghttp2_Ver='nghttp2-1.31.0'
Luajit_Ver='LuaJIT-2.0.5'
LuaNginxModule='lua-nginx-module-0.10.11'
NgxDevelKit='ngx_devel_kit-0.3.0'
Nginx_Ver='nginx-1.12.2'
if [ "${DBSelect}" = "1" ]; then
    Mysql_Ver='mysql-5.1.73'
elif [ "${DBSelect}" = "2" ]; then
    Mysql_Ver='mysql-5.5.59'
elif [ "${DBSelect}" = "3" ]; then
    Mysql_Ver='mysql-5.6.39'
elif [ "${DBSelect}" = "4" ]; then
    Mysql_Ver='mysql-5.7.21'
elif [ "${DBSelect}" = "5" ]; then
    Mariadb_Ver='mariadb-5.5.59'
elif [ "${DBSelect}" = "6" ]; then
    Mariadb_Ver='mariadb-10.0.34'
elif [ "${DBSelect}" = "7" ]; then
    Mariadb_Ver='mariadb-10.1.32'
elif [ "${DBSelect}" = "8" ]; then
    Mariadb_Ver='mariadb-10.2.14'
fi
if [ "${PHPSelect}" = "1" ]; then
    Php_Ver='php-5.2.17'
elif [ "${PHPSelect}" = "2" ]; then
    Php_Ver='php-5.3.29'
elif [ "${PHPSelect}" = "3" ]; then
    Php_Ver='php-5.4.45'
elif [ "${PHPSelect}" = "4" ]; then
    Php_Ver='php-5.5.38'
elif [ "${PHPSelect}" = "5" ]; then
    Php_Ver='php-5.6.35'
elif [ "${PHPSelect}" = "6" ]; then
    Php_Ver='php-7.0.29'
elif [ "${PHPSelect}" = "7" ]; then
    Php_Ver='php-7.1.16'
elif [ "${PHPSelect}" = "8" ]; then
    Php_Ver='php-7.2.4'
fi
if [[ "${PHPSelect}" =~ ^[123]$ ]]; then
    PhpMyAdmin_Ver='phpMyAdmin-4.0.10.20-all-languages'
else
    PhpMyAdmin_Ver='phpMyAdmin-4.8.0-all-languages'
fi
APR_Ver='apr-1.6.3'
APR_Util_Ver='apr-util-1.6.1'
if [ "${ApacheSelect}" = "1" ]; then
    Apache_Ver='httpd-2.2.34'
elif [ "${ApacheSelect}" = "2" ]; then
    Apache_Ver='httpd-2.4.33'
fi

Pureftpd_Ver='pure-ftpd-1.0.47'

XCache_Ver='xcache-3.2.0'
ImageMagick_Ver='ImageMagick-7.0.7-25'
Imagick_Ver='imagick-3.4.3'
ZendOpcache_Ver='zendopcache-7.0.5'
Redis_Stable_Ver='redis-4.0.9'
PHPRedis_Ver='redis-4.0.0'
Memcached_Ver='memcached-1.5.7'
Libmemcached_Ver='libmemcached-1.0.18'
PHPMemcached_Ver='memcached-2.2.0'
PHP7Memcached_Ver='memcached-3.0.4'
PHPMemcache_Ver='memcache-3.0.8'
PHPOldApcu_Ver='apcu-4.0.11'
PHPNewApcu_Ver='apcu-5.1.11'
PHPApcu_Bc_Ver='apcu_bc-1.0.4'
