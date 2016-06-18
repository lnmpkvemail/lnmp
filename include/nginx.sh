#!/bin/bash

Install_Nginx()
{
    Echo_Blue "[+] Installing ${Nginx_Ver}... "
    groupadd www
    useradd -s /sbin/nologin -g www www

    Tar_Cd ${Nginx_Ver}.tar.gz ${Nginx_Ver}
    ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module ${NginxMAOpt}
    make && make install
    cd ../

    ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx

    rm -f /usr/local/nginx/conf/nginx.conf
    cd ${cur_dir}
    if [ "${Stack}" = "lnmpa" ]; then
        \cp conf/nginx_a.conf /usr/local/nginx/conf/nginx.conf
        \cp conf/proxy.conf /usr/local/nginx/conf/proxy.conf
    else
        \cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
    fi
    \cp conf/rewrite/dabr.conf /usr/local/nginx/conf/dabr.conf
    \cp conf/rewrite/discuz.conf /usr/local/nginx/conf/discuz.conf
    \cp conf/rewrite/sablog.conf /usr/local/nginx/conf/sablog.conf
    \cp conf/rewrite/typecho.conf /usr/local/nginx/conf/typecho.conf
    \cp conf/rewrite/typecho2.conf /usr/local/nginx/conf/typecho2.conf
    \cp conf/rewrite/wordpress.conf /usr/local/nginx/conf/wordpress.conf
    \cp conf/rewrite/discuzx.conf /usr/local/nginx/conf/discuzx.conf
    \cp conf/rewrite/none.conf /usr/local/nginx/conf/none.conf
    \cp conf/rewrite/wp2.conf /usr/local/nginx/conf/wp2.conf
    \cp conf/rewrite/phpwind.conf /usr/local/nginx/conf/phpwind.conf
    \cp conf/rewrite/shopex.conf /usr/local/nginx/conf/shopex.conf
    \cp conf/rewrite/dedecms.conf /usr/local/nginx/conf/dedecms.conf
    \cp conf/rewrite/drupal.conf /usr/local/nginx/conf/drupal.conf
    \cp conf/rewrite/ecshop.conf /usr/local/nginx/conf/ecshop.conf
    \cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf
    \cp conf/enable-php.conf /usr/local/nginx/conf/enable-php.conf
    \cp conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php-pathinfo.conf
    \cp conf/proxy-pass-php.conf /usr/local/nginx/conf/proxy-pass-php.conf
    \cp conf/enable-ssl-example.conf /usr/local/nginx/conf/enable-ssl-example.conf

    mkdir -p /home/wwwroot/default
    chmod +w /home/wwwroot/default
    mkdir -p /home/wwwlogs
    chmod 777 /home/wwwlogs

    chown -R www:www /home/wwwroot/default

    mkdir /usr/local/nginx/conf/vhost

    if [ "${Stack}" = "lnmp" ]; then
    cat >/home/wwwroot/default/.user.ini<<EOF
open_basedir=/home/wwwroot/default:/tmp/:/proc/
EOF
    chmod 644 /home/wwwroot/default/.user.ini
    chattr +i /home/wwwroot/default/.user.ini
    fi

    \cp init.d/init.d.nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx

    if [ "${SelectMalloc}" = "3" ]; then
        mkdir /tmp/tcmalloc
        chown -R www:www /tmp/tcmalloc
        sed -i '/nginx.pid/a\
google_perftools_profiles /tmp/tcmalloc;' /usr/local/nginx/conf/nginx.conf
    fi
}