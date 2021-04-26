 #!/bin/bash

Install_Swoole()
{
    echo "====== Installing Swoole ======"

    Press_Start

    Addons_Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}swoole.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    echo "Modify php.ini......"
    sed -i '/extension = "swoole.so"/d' ${PHP_Path}/etc/php.ini

    cd ${cur_dir}/src

    # 建议使用的 Swoole 版本：https://wiki.swoole.com/#/version/log?id=%e5%bb%ba%e8%ae%ae%e4%bd%bf%e7%94%a8%e7%9a%84swoole%e7%89%88%e6%9c%ac
    if echo "${Cur_PHP_Version}" | grep -Eqi '^5.';then
		Swoole_Stable_Ver='1.10.6'
	elif echo "${Cur_PHP_Version}" | grep -Eqi '^7.[01].';then
		Swoole_Stable_Ver='4.5.11'
	fi

    Download_Files https://github.com/swoole/swoole-src/archive/v${Swoole_Stable_Ver}.tar.gz v${Swoole_Stable_Ver}.tar.gz
    Tar_Cd v${Swoole_Stable_Ver}.tar.gz swoole-${Swoole_Stable_Ver}

    ${PHP_Path}/bin/phpize
    ./configure --with-php-config=${PHP_Path}/bin/php-config
    Make_Install
    cd ../

    echo 'extension = "swoole.so"' >> ${PHP_Path}/etc/php.ini

    Restart_PHP

    if [ -s "${zend_ext}" ]; then
        Echo_Green "====== Swoole install completed ======"
        Echo_Green "Swoole installed successfully, enjoy it!"
    else
        Echo_Red "Swoole install failed!"
    fi
}

Uninstall_Swoole()
{
    echo "You will uninstall Swoole..."
    Press_Start
    sed -i 's/extension = "swoole.so"//g' ${PHP_Path}/etc/php.ini
    Restart_PHP
    echo "Delete Swoole files..."
    Echo_Green "Uninstall Swoole completed."
}
