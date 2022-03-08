#!/usr/bin/env bash

Install_ionCube()
{
    echo "====== Installing ionCube ======"
    Press_Start

    rm -f ${PHP_Path}/conf.d/001-ioncube.ini
    Addons_Get_PHP_Ext_Dir
    PHP_Short_Ver="$(echo ${Cur_PHP_Version} | cut -d. -f1-2)"
    if echo ${zend_ext_dir} | grep -Eqi "non-zts"; then
        zend_ext="ioncube_loader_lin_${PHP_Short_Ver}.so"
    else
        zend_ext="ioncube_loader_lin_${PHP_Short_Ver}_ts.so"
    fi

    cd ${cur_dir}/src
    rm -rf ioncube
    rm -rf ioncube_loaders_lin_x8*.tar.gz
    [[ "${ARCH}" = "i386" ]] && ARCH='x86'
    [[ "${ARCH}" = "x86_64" ]] && ARCH='x86-64'
    [[ "${ARCH}" = "armhf" ]] && ARCH='armv7l'
    if grep -Eqi "xcache.so" ${PHP_Path}/conf.d/006-xcache.ini; then
        if echo "${ARCH}" | grep -Eqi "x86*"; then
            Download_Files ${Download_Mirror}/web/ioncube/4.7.5/ioncube_loaders_lin_${ARCH}.tar.gz ioncube_loaders_lin_${ARCH}.tar.gz
        else
            Echo_Red "Unsupported architecture with xcache! You can try uninstall xcache and reinstall ioncube loader."
            exit 1
        fi
    else
        if echo "${ARCH}" | grep -Eqi "x86*|armv7l|aarch64"; then
            Download_Files https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${ARCH}.tar.gz ioncube_loaders_lin_${ARCH}.tar.gz
        else
            Echo_Red "Unsupported architecture!"
            exit 1
        fi
    fi
    tar zxf ioncube_loaders_lin_${ARCH}.tar.gz
    if [ ! -d "/usr/local/ioncube" ]; then
        mkdir -p /usr/local/ioncube
    fi
    if [ -s "ioncube/${zend_ext}" ]; then
        \cp "ioncube/${zend_ext}" /usr/local/ioncube/
    else
        Echo_Red "ioncube does not support the current PHP version!"
        exit 1
    fi

    echo "Writing ionCube Loader to configure files..."
    cat >${PHP_Path}/conf.d/001-ioncube.ini<<EOF
[ionCube Loader]
zend_extension="/usr/local/ioncube/${zend_ext}"
;ioncubeend
EOF

    if [ -s "/usr/local/ioncube/${zend_ext}" ]; then
        Restart_PHP
        Echo_Green "====== ionCube install completed ======"
        Echo_Green "ionCube installed successfully, enjoy it!"
    else
        rm -f ${PHP_Path}/conf.d/001-ioncube.ini
        Echo_Red "ionCube install failed!"
    fi
 }

 Uninstall_ionCube()
 {
    echo "You will uninstall ionCube..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/001-ioncube.ini
    #echo "Delete ionCube files..."
    #rm -rf /usr/local/ioncube/
    Restart_PHP
    Echo_Green "Uninstall ionCube completed."
 }
