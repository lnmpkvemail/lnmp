#!/usr/bin/env bash

Install_Nginx_Openssl()
{
    if [ "${Enable_Nginx_Openssl}" = 'y' ]; then
        if [ ! -n "${Nginx_Version}" ]; then
            Nginx_Version=$(echo ${Nginx_Ver} | sed "s/nginx-//")
        fi
        Nginx_Ver_Com=$(${cur_dir}/include/version_compare 1.13.0 ${Nginx_Version})
        if [[ "${Nginx_Ver_Com}" == "0" ||  "${Nginx_Ver_Com}" == "1" ]]; then
            Download_Files ${Download_Mirror}/lib/openssl/${Openssl_Ver}.tar.gz ${Openssl_Ver}.tar.gz
            [[ -d "${Openssl_Ver}" ]] && rm -rf ${Openssl_Ver}
            tar zxf ${Openssl_Ver}.tar.gz
            Nginx_With_Openssl="--with-openssl=${cur_dir}/src/${Openssl_Ver}"
        else
            Download_Files ${Download_Mirror}/lib/openssl/${Openssl_New_Ver}.tar.gz ${Openssl_New_Ver}.tar.gz
            [[ -d "${Openssl_New_Ver}" ]] && rm -rf ${Openssl_New_Ver}
            tar zxf ${Openssl_New_Ver}.tar.gz
            Nginx_With_Openssl="--with-openssl=${cur_dir}/src/${Openssl_New_Ver} --with-openssl-opt='enable-weak-ssl-ciphers'"
        fi
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
        Download_Files ${Download_Mirror}/lib/lua/${LuaRestyCore}.tar.gz ${LuaRestyCore}.tar.gz
        Download_Files ${Download_Mirror}/lib/lua/${LuaRestyLrucache}.tar.gz ${LuaRestyLrucache}.tar.gz

        Echo_Blue "[+] Installing ${Luajit_Ver}... "
        tar zxf ${LuaNginxModule}.tar.gz
        tar zxf ${NgxDevelKit}.tar.gz
        Tar_Cd ${Luajit_Ver}.tar.gz ${Luajit_Ver}
        make
        make install PREFIX=/usr/local/luajit
        cd ${cur_dir}/src
        rm -rf ${cur_dir}/src/${Luajit_Ver}

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
export LUAJIT_INC=/usr/local/luajit/include/luajit-2.1
EOF

        source /etc/profile.d/luajit.sh

        Tar_Cd ${LuaRestyCore}.tar.gz ${LuaRestyCore}
        make install PREFIX=/usr/local/nginx
        cd -
        Tar_Cd ${LuaRestyLrucache}.tar.gz ${LuaRestyLrucache}
        make install PREFIX=/usr/local/nginx
        cd -

        Nginx_Ver_Com=$(${cur_dir}/include/version_compare 1.21.5 ${Nginx_Version})
        if [[  "${Nginx_Ver_Com}" == "1" ]]; then
            Nginx_Module_Lua="--with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib --add-module=${cur_dir}/src/${LuaNginxModule} --add-module=${cur_dir}/src/${NgxDevelKit}"
        else
            if [ "${Nginx_With_Pcre}" = "" ]; then
                Nginx_Module_Lua="--with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib --add-module=${cur_dir}/src/${LuaNginxModule} --add-module=${cur_dir}/src/${NgxDevelKit} --with-pcre=${cur_dir}/src/${Pcre_Ver} --with-pcre-jit"
                cd ${cur_dir}/src
                Download_Files ${Download_Mirror}/web/pcre/${Pcre_Ver}.tar.bz2 ${Pcre_Ver}.tar.bz2
                Tar_Cd ${Pcre_Ver}.tar.bz2
            else
                Nginx_Module_Lua="--with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib --add-module=${cur_dir}/src/${LuaNginxModule} --add-module=${cur_dir}/src/${NgxDevelKit}"
            fi
        fi
    fi
}

Install_Ngx_FancyIndex()
{
    if [ "${Enable_Ngx_FancyIndex}" = 'y' ]; then
        echo "Installing Ngx FancyIndex for Nginx..."
        cd ${cur_dir}/src
        Download_Files ${Download_Mirror}/web/nginx/${NgxFancyIndex_Ver}.tar.xz ${NgxFancyIndex_Ver}.tar.xz

        Tar_Cd ${NgxFancyIndex_Ver}.tar.xz
        Ngx_FancyIndex="--add-module=${cur_dir}/src/${NgxFancyIndex_Ver}"
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
    Install_Ngx_FancyIndex
    Tar_Cd ${Nginx_Ver}.tar.gz ${Nginx_Ver}
    if [[ "${DISTRO}" = "Fedora" && ${Fedora_Version} -ge 28 ]]; then
        patch -p1 < ${cur_dir}/src/patch/nginx-libxcrypt.patch
    fi
    Nginx_Ver_Com=$(${cur_dir}/include/version_compare 1.14.2 ${Nginx_Version})
    if gcc -dumpversion|grep -q "^[8]" && [ "${Nginx_Ver_Com}" == "1" ]; then
        patch -p1 < ${cur_dir}/src/patch/nginx-gcc8.patch
    fi
    Nginx_Ver_Com=$(${cur_dir}/include/version_compare 1.9.4 ${Nginx_Version})
    if [[ "${Nginx_Ver_Com}" == "0" ||  "${Nginx_Ver_Com}" == "1" ]]; then
        ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module --with-http_realip_module ${Nginx_With_Openssl} ${Nginx_With_Pcre} ${Nginx_Module_Lua} ${NginxMAOpt} ${Ngx_FancyIndex} ${Nginx_Modules_Options}
    else
        ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-http_realip_module ${Nginx_With_Openssl} ${Nginx_With_Pcre} ${Nginx_Module_Lua} ${NginxMAOpt} ${Ngx_FancyIndex} ${Nginx_Modules_Options}
    fi
    Make_Install
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
    \cp -ra conf/rewrite /usr/local/nginx/conf/
    \cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf
    \cp conf/enable-php.conf /usr/local/nginx/conf/enable-php.conf
    \cp conf/enable-php-pathinfo.conf /usr/local/nginx/conf/enable-php-pathinfo.conf
    \cp -ra conf/example /usr/local/nginx/conf/example
    if [ "${Enable_Nginx_Lua}" = 'y' ]; then
        if ! grep -q 'lua_package_path "/usr/local/nginx/lib/lua/?.lua";' /usr/local/nginx/conf/nginx.conf; then
            sed -i "/server_tokens off;/i\        lua_package_path \"/usr/local/nginx/lib/lua/?.lua\";\n" /usr/local/nginx/conf/nginx.conf
        fi
        if [ "${Stack}" = "lnmp" ]; then
            sed -i "/include enable-php.conf;/i\        location /lua\n        {\n            default_type text/html;\n            content_by_lua 'ngx.say\(\"hello world\"\)';\n        }\n" /usr/local/nginx/conf/nginx.conf
        else
            sed -i "/include proxy-pass-php.conf;/i\        location /lua\n        {\n            default_type text/html;\n            content_by_lua 'ngx.say\(\"hello world\"\)';\n        }\n" /usr/local/nginx/conf/nginx.conf
        fi
    fi
    if [ "${isWSL}" = "y" ]; then
        sed -i "/gzip on;/i\        fastcgi_buffering off;\n" /usr/local/nginx/conf/nginx.conf
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
    \cp init.d/nginx.service /etc/systemd/system/nginx.service
    chmod +x /etc/init.d/nginx

    if [ "${SelectMalloc}" = "3" ]; then
        mkdir /tmp/tcmalloc
        chown -R www:www /tmp/tcmalloc
        sed -i '/nginx.pid/a\
google_perftools_profiles /tmp/tcmalloc;' /usr/local/nginx/conf/nginx.conf
    fi

    if [ "${Stack}" != "lamp" ]; then
        uname_r=$(uname -r)
        if echo $uname_r|grep -Eq "^3\.(9|1[0-9])*|^[4-9]\.*"; then
            echo "3.9+";
            sed -i 's/listen 80 default_server;/listen 80 default_server reuseport;/g' /usr/local/nginx/conf/nginx.conf
        fi
    fi
}
