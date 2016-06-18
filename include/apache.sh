#!/bin/bash

Install_Apache_22()
{
    Echo_Blue "[+] Installing ${Apache_Version}..."
    if [ "${Stack}" = "lamp" ]; then
        groupadd www
        useradd -s /sbin/nologin -g www www
        mkdir -p /home/wwwroot/default
        chmod +w /home/wwwroot/default
        mkdir -p /home/wwwlogs
        chmod 777 /home/wwwlogs
        chown -R www:www /home/wwwroot/default
    fi
    Tar_Cd ${Apache_Version}.tar.gz ${Apache_Version}
    ./configure --prefix=/usr/local/apache --enable-mods-shared=most --enable-headers --enable-mime-magic --enable-proxy --enable-so --enable-rewrite --with-ssl --enable-ssl --enable-deflate --enable-suexec --with-included-apr --with-mpm=prefork --with-expat=builtin
    make && make install

    mv /usr/local/apache/conf/httpd.conf /usr/local/apache/conf/httpd.conf.bak
    if [ "${Stack}" = "lamp" ]; then
        \cp ${cur_dir}/conf/httpd22-lamp.conf /usr/local/apache/conf/httpd.conf
        \cp ${cur_dir}/conf/httpd-vhosts-lamp.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
    elif [ "${Stack}" = "lnmpa" ]; then
        \cp ${cur_dir}/conf/httpd22-lnmpa.conf /usr/local/apache/conf/httpd.conf
        \cp ${cur_dir}/conf/httpd-vhosts-lnmpa.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
    fi
    \cp ${cur_dir}/conf/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf
    \cp ${cur_dir}/conf/mod_remoteip.conf /usr/local/apache/conf/extra/mod_remoteip.conf

    sed -i 's/ServerAdmin you@example.com/ServerAdmin '${ServerAdmin}'/g' /usr/local/apache/conf/httpd.conf
    sed -i 's/webmaster@example.com/'${ServerAdmin}'/g' /usr/local/apache/conf/extra/httpd-vhosts.conf
    mkdir -p /usr/local/apache/conf/vhost

    if [ "${Stack}" = "lnmpa" ]; then
        \cp ${cur_dir}/src/patch/mod_remoteip.c .
        /usr/local/apache/bin/apxs -i -c -n mod_remoteip.so mod_remoteip.c
        sed -i 's/#LoadModule/LoadModule/g' /usr/local/apache/conf/extra/mod_remoteip.conf
    fi

    ln -sf /usr/local/lib/libltdl.so.3 /usr/lib/libltdl.so.3
    mkdir /usr/local/apache/conf/vhost

    \cp ${cur_dir}/init.d/init.d.httpd /etc/init.d/httpd
    chmod +x /etc/init.d/httpd
}

Install_Apache_24()
{
    Echo_Blue "[+] Installing ${Apache_Version}..."
    if [ "${Stack}" = "lamp" ]; then
        groupadd www
        useradd -s /sbin/nologin -g www www
        mkdir -p /home/wwwroot/default
        chmod +w /home/wwwroot/default
        mkdir -p /home/wwwlogs
        chmod 777 /home/wwwlogs
        chown -R www:www /home/wwwroot/default
    fi
    Tar_Cd ${Apache_Version}.tar.gz ${Apache_Version}
    cd srclib
    if [ -s "${cur_dir}/src/${APR_Ver}.tar.gz" ]; then
        echo "${APR_Ver}.tar.gz [found]"
        cp ${cur_dir}/src/${APR_Ver}.tar.gz .
    else
        Download_Files ${Download_Mirror}/web/apache/${APR_Ver}.tar.gz ${APR_Ver}.tar.gz
    fi
    if [ -s "${cur_dir}/src/${APR_Util_Ver}.tar.gz" ]; then
        echo "${APR_Util_Ver}.tar.gz [found]"
        cp ${cur_dir}/src/${APR_Util_Ver}.tar.gz .
    else
        Download_Files ${Download_Mirror}/web/apache/${APR_Util_Ver}.tar.gz ${APR_Util_Ver}.tar.gz
    fi
    tar zxf ${APR_Ver}.tar.gz
    tar zxf ${APR_Util_Ver}.tar.gz
    mv ${APR_Ver} apr
    mv ${APR_Util_Ver} apr-util
    cd ..
    ./configure --prefix=/usr/local/apache --enable-mods-shared=most --enable-headers --enable-mime-magic --enable-proxy --enable-so --enable-rewrite --with-ssl --enable-ssl --enable-deflate --with-pcre --with-included-apr --with-apr-util --enable-mpms-shared=all --with-mpm=prefork --enable-remoteip
    make && make install

    mv /usr/local/apache/conf/httpd.conf /usr/local/apache/conf/httpd.conf.bak
    if [ "${Stack}" = "lamp" ]; then
        \cp ${cur_dir}/conf/httpd24-lamp.conf /usr/local/apache/conf/httpd.conf
        \cp ${cur_dir}/conf/httpd-vhosts-lamp.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
    elif [ "${Stack}" = "lnmpa" ]; then
        \cp ${cur_dir}/conf/httpd24-lnmpa.conf /usr/local/apache/conf/httpd.conf
        \cp ${cur_dir}/conf/httpd-vhosts-lnmpa.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
    fi
    \cp ${cur_dir}/conf/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf
    \cp ${cur_dir}/conf/mod_remoteip.conf /usr/local/apache/conf/extra/mod_remoteip.conf
    mkdir /usr/local/apache/conf/vhost

    sed -i 's/NameVirtualHost .*//g' /usr/local/apache/conf/extra/httpd-vhosts.conf

    \cp ${cur_dir}/init.d/init.d.httpd /etc/init.d/httpd
    chmod +x /etc/init.d/httpd
}