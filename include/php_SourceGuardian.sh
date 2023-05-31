#!/usr/bin/env bash

Install_SourceGuardian()
{
    echo "====== Installing SourceGuardian Loader ======"
    Press_Start

    rm -f ${PHP_Path}/conf.d/001-sourceguardian.ini
    Addons_Get_PHP_Ext_Dir
    PHP_Short_Ver="$(echo ${Cur_PHP_Version} | cut -d. -f1-2)"
    if echo ${zend_ext_dir} | grep -Eqi "non-zts"; then
        zend_ext="ixed.${PHP_Short_Ver}.lin"
    else
        zend_ext="ixed.${PHP_Short_Ver}ts.lin"
    fi

    cd ${cur_dir}/src

    if [ "${ARCH}" = "x86_64" ]; then
        echo "${ARCH}"
        Download_Files ${Download_Mirror}/web/sourceguardian/14.0.0/loaders.linux-${ARCH}.zip loaders.linux-${ARCH}.zip
    elif [ "${ARCH}" = "i386" ]; then
        if echo "${Cur_PHP_Version}" | grep -Eqi '^7.[2-4].*|8.[0-2].*'; then
            Echo_Red "Current PHP version does not support SourceGuardian!"
            exit 1
        fi
        Download_Files ${Download_Mirror}/web/sourceguardian/12.1.2/loaders.linux-${ARCH}.zip loaders.linux-${ARCH}.zip
    elif [ "${ARCH}" = "armhf" ]; then
        if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.*'; then
            Echo_Red "Current PHP version does not support SourceGuardian!"
            exit 1
        elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.[3-6].*|7.[0-3].*'; then
            Download_Files ${Download_Mirror}/web/sourceguardian/12.1.2/loaders.linux-${ARCH}.zip loaders.linux-${ARCH}.zip
        elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.4.*|^8.[0-2].*'; then
            Download_Files ${Download_Mirror}/web/sourceguardian/14.0.3/loaders.linux-${ARCH}.zip loaders.linux-${ARCH}.zip
        fi
    elif [ "${ARCH}" = "aarch64" ]; then
        if echo "${Cur_PHP_Version}" | grep -Eqi '^5.*'; then
            Echo_Red "Current PHP version does not support SourceGuardian!"
            exit 1
        elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.[0-3].*'; then
            Download_Files ${Download_Mirror}/web/sourceguardian/12.1.2/loaders.linux-${ARCH}.zip loaders.linux-${ARCH}.zip
        elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.4.*|8.[0-2].*'; then
            Download_Files ${Download_Mirror}/web/sourceguardian/14.0.3/loaders.linux-${ARCH}.zip loaders.linux-${ARCH}.zip
        fi
    else
        Echo_Red "Unsupported architecture!"
        exit 1
    fi

    unzip loaders.linux-${ARCH}.zip -d loaders.linux-${ARCH}

    if [ ! -s "${zend_ext}" ]; then
        echo "${zend_ext} not found!"
        Echo_Red "SourceGuardian does not provide a loader for current PHP version."
    else
        [[ ! -d "${zend_ext_dir}" ]] && mkdir -p "${zend_ext_dir}"
        \cp "loaders.linux-${ARCH}/${zend_ext}" "${zend_ext_dir}"
        echo "Writing SourceGuardian loader to configure files..."
        cat >${PHP_Path}/conf.d/001-sourceguardian.ini<<EOF
extension=${zend_ext}
EOF
    fi

    if [ -s "${zend_ext_dir}${zend_ext}" ]; then
        rm -rf loaders.linux-${ARCH}
        Restart_PHP
        Echo_Green "====== SourceGuardian Loader install completed ======"
        Echo_Green "SourceGuardian Loader installed successfully, enjoy it!"
    else
        rm -rf loaders.linux-${ARCH}
        rm -f ${PHP_Path}/conf.d/001-sourceguardian.ini
        Echo_Red "SourceGuardian Loader install failed!"
    fi
 }

 Uninstall_SourceGuardian()
 {
    echo "You will uninstall SourceGuardian Loader..."
    Press_Start
    rm -f ${PHP_Path}/conf.d/001-sourceguardian.ini
    Restart_PHP
    Echo_Green "Uninstall SourceGuardian Loader completed."
 }
