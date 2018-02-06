#!/bin/bash

Install_Nginx_Openssl()
{
    if [ "${Enable_Nginx_Openssl}" = 'y' ]; then
        Download_Files ${Download_Mirror}/lib/openssl/${Openssl_Ver}.tar.gz ${Openssl_Ver}.tar.gz
        [[ -d "${Openssl_Ver}" ]] && rm -rf ${Openssl_Ver}
        tar zxf ${Openssl_Ver}.tar.gz
        Nginx_With_Openssl="--with-openssl=${cur_dir}/src/${Openssl_Ver}"
    fi
}

Install_Nginx_Lua()
{
    if [ "${Enable_Nginx_Lua}" = 'y' ]; then
        echo "Installing Lua for Nginx..."
        cd ${cur_dir}/src
        Download_Files ${Download_Mirror}/lib/lua/${Luajit_Ver}.tar.gz ${Luajit_Ver}.tar.gz
        Download_Files ${Download_Mirror}/lib/lua/${LuaNginxModule}.tar.gz ${LuaNginxModule}.tar.gz
        Download_Files ${Download_Mirror}/lib/lua/${NgxDevelKit}.tar.gz ${NgxDevelKit}.tar.gz

        Echo_Blue "[+] Installing ${Luajit_Ver}... "
        tar zxf ${LuaNginxModule}.tar.gz
        tar zxf ${NgxDevelKit}.tar.gz
        if [[ ! -s /usr/local/luajit/bin/luajit || ! -s /usr/local/luajit/include/luajit-2.0/luajit.h || ! -s /usr/local/luajit/lib/libluajit-5.1.so ]]; then
            Tar_Cd ${Luajit_Ver}.tar.gz ${Luajit_Ver}
            make
            make install PREFIX=/usr/local/luajit
            cd ${cur_dir}/src
            rm -rf ${cur_dir}/src/${Luajit_Ver}
        fi

        cat > /etc/ld.so.conf.d/luajit.conf<<EOF
/usr/local/luajit/lib
EOF
        if [ "${Is_64bit}" = "y" ]; then
            ln -sf /usr/local/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
        else
            ln -sf /usr/local/luajit/lib/libluajit-5.1.so.2 /usr/lib/libluajit-5.1.so.2
        fi
        ldconfig

        cat >/etc/profile.d/luajit.sh<<EOF
export LUAJIT_LIB=/usr/local/luajit/lib
export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0
EOF

        source /etc/profile.d/luajit.sh

        Nginx_Module_Lua="--with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib --add-module=${cur_dir}/src/${LuaNginxModule} --add-module=${cur_dir}/src/${NgxDevelKit}"
    fi
}

Install_Nginx()
{
    Echo_Blue "[+] Installing ${Nginx_Ver}... "
    groupadd www
    useradd -s /sbin/nologin -g www www

    cd ${cur_dir}/src
    Install_Nginx_Openssl
    Install_Nginx_Lua
    Tar_Cd ${Nginx_Ver}.tar.gz ${Nginx_Ver}
    if echo ${Nginx_Ver} | grep -Eqi 'nginx-[0-1].[5-8].[0-9]' || echo ${Nginx_Ver} | grep -Eqi 'nginx-1.9.[1-4]$'; then
        ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module ${Nginx_With_Openssl} ${Nginx_Module_Lua} ${NginxMAOpt} ${Nginx_Modules_Options}
    else
        ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module ${Nginx_With_Openssl} ${Nginx_Module_Lua} ${NginxMAOpt} ${Nginx_Modules_Options}
    fi
    make && make install
    cd ../

    ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx

    rm -f /usr/local/nginx/conf/nginx.conf
    cd ${cur_dir}
    if [ "${Stack}" = "lnmpa" ]; then
        \cp conf/nginx_a.conf /usr/local/nginx/conf/nginx.conf
        \cp conf/proxy.conf /usr/local/nginx/conf/proxy.conf
        \cp conf/proxy-pass-php.conf /usr/local/nginx/conf/proxy-pass-php.conf
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
    \cp conf/rewrite/codeigniter.conf /usr/local/nginx/conf/codeigniter.conf
    \cp conf/rewrite/laravel.conf /usr/local/nginx/conf/laravel.conf
    \cp conf/rewrite/thinkphp.conf /usr/local/nginx/conf/thinkphp.conf
    \cp conf/rewrite/yii2.conf /usr/local/nginx/conf/yii2.conf
    \cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf
    \cp conf/enable-php.conf /usr/local/nginx/conf/enable-php.conf
    \cp conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php-pathinfo.conf
    \cp conf/enable-ssl-example.conf /usr/local/nginx/conf/enable-ssl-example.conf
    \cp conf/magento2-example.conf /usr/local/nginx/conf/magento2-example.conf
    if [ "${Enable_Nginx_Lua}" = 'y' ]; then
        sed -i "/location \/nginx_status/i\        location /lua\n        {\n            default_type text/html;\n            content_by_lua 'ngx.say\(\"hello world\"\)';\n        }\n" /usr/local/nginx/conf/nginx.conf
    fi

    mkdir -p ${Default_Website_Dir}
    chmod +w ${Default_Website_Dir}
    mkdir -p /home/wwwlogs
    chmod 777 /home/wwwlogs

    chown -R www:www ${Default_Website_Dir}

    mkdir /usr/local/nginx/conf/vhost

    if [ "${Default_Website_Dir}" != "/home/wwwroot/default" ]; then
        sed -i "s#/home/wwwroot/default#${Default_Website_Dir}#g" /usr/local/nginx/conf/nginx.conf
    fi

    if [ "${Stack}" = "lnmp" ]; then
        cat >${Default_Website_Dir}/.user.ini<<EOF
open_basedir=${Default_Website_Dir}:/tmp/:/proc/
EOF
        chmod 644 ${Default_Website_Dir}/.user.ini
        chattr +i ${Default_Website_Dir}/.user.ini
        cat >>/usr/local/nginx/conf/fastcgi.conf<<EOF
fastcgi_param PHP_ADMIN_VALUE "open_basedir=\$document_root/:/tmp/:/proc/";
EOF
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
