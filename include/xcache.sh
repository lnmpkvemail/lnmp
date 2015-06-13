 #!/bin/bash

Install_XCache()
{       
    echo "You will install ${XCache_Ver}..."

    xadmin_pass=""
    read -p "Please enter admin password of XCache Administration Page: " xadmin_pass
    if [ "${xadmin_pass}" = "" ]; then
        echo "password can't be NULL!"
        exit 1
    else
    echo "================================================="
    echo "Your admin password of XCache was:${xadmin_pass}"
    echo "================================================="
    fi
    xmd5pass=`echo -n "${xadmin_pass}" |md5sum |awk '{print $1}'`

    
    echo "====== Installing XCache ======"
    Press_Install

    sed -i '/;xcache/,/;xcache end/d' /usr/local/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}xcache.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cpu_count=`cat /proc/cpuinfo |grep -c processor`

    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/xcache/${XCache_Ver}.tar.gz ${XCache_Ver}.tar.gz
    Tar_Cd ${XCache_Ver}.tar.gz ${XCache_Ver}
    /usr/local/php/bin/phpize
    ./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=/usr/local/php/bin/php-config
    make
    make install
    cd ../

    cat >>/usr/local/php/etc/php.ini<<EOF
;xcache
[xcache-common]
extension = ${zend_ext}

[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
;run: echo -n "yourpassword" |md5sum |awk '{print $1}' to get md5 password
xcache.admin.pass = "${xmd5pass}"

[xcache]
xcache.shm_scheme =        "mmap"
xcache.size  =               20M
; set to cpu count (cat /proc/cpuinfo |grep -c processor)
xcache.count =                 ${cpu_count}
xcache.slots =                8K
xcache.ttl   =                 0
xcache.gc_interval =           0
xcache.var_size  =            4M
xcache.var_count =             1
xcache.var_slots =            8K
xcache.var_ttl   =             0
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
xcache.readonly_protection = Off
; for *nix, xcache.mmap_path is a file path, not directory. (auto create/overwrite)
; Use something like "/tmp/xcache" instead of "/dev/*" if you want to turn on ReadonlyProtection
; different process group of php won't share the same /tmp/xcache
xcache.mmap_path =    "/tmp/xcache"
xcache.coredump_directory =   ""
xcache.experimental =        Off
xcache.cacher =               On
xcache.stat   =               On
xcache.optimizer =           Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager =          Off
xcache.coveragedump_directory = ""
;xcache end

EOF

    touch /tmp/xcache && chown www:www /tmp/xcache

    \cp -a ${cur_dir}/src/${XCache_Ver}/htdocs /home/wwwroot/default/xcache
    chown www:www -R /home/wwwroot/default/xcache

    if [ -s "${zend_ext}" ]; then
        Restart_PHP
        echo "======== xcache install completed ======"
        echo "XCache installed successfully, enjoy it!"
    else
        sed -i '/;xcache/,/;xcache end/d' /usr/local/php/etc/php.ini
        echo "XCache install failed!"
    fi
}

Uninstall_XCache()
{
    echo "You will uninstall XCache..."
    Press_Start
    sed -i '/;xcache/,/;xcache end/d' /usr/local/php/etc/php.ini
    echo "Delete xcache files..."
    rm -rf /home/wwwroot/default/xcache
    Restart_PHP
    echo "Uninstall XCache completed."
}