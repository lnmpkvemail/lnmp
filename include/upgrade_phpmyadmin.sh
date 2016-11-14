#!/bin/bash

Upgrade_phpMyAdmin()
{
    phpMyAdmin_Version=""
    echo "You can get version number from https://www.phpmyadmin.net/downloads/"
    read -p "Please enter phpMyAdmin version you want, (example: 4.4.15 ): " phpMyAdmin_Version
    if [ "${phpMyAdmin_Version}" = "" ]; then
        echo "Error: You must enter a phpMyAdmin version!!"
        exit 1
    fi
    echo "+---------------------------------------------------------+"
    echo "|   You will upgrade phpMyAdmin version to ${phpMyAdmin_Version}"
    echo "+---------------------------------------------------------+"

    Press_Start

    echo "============================check files=================================="
    cd ${cur_dir}/src
    if [ -s phpMyAdmin-${phpMyAdmin_Version}-all-languages.tar.bz2 ]; then
        echo "phpMyAdmin-${phpMyAdmin_Version}-all-languages.tar.bz2 [found]"
    else
        echo "Notice: phpMyAdmin-${phpMyAdmin_Version}-all-languages.tar.bz2 not found!!!download now......"
        wget -c --progress=bar:force https://files.phpmyadmin.net/phpMyAdmin/${phpMyAdmin_Version}/phpMyAdmin-${phpMyAdmin_Version}-all-languages.tar.bz2
        if [ $? -eq 0 ]; then
            echo "Download phpMyAdmin-${phpMyAdmin_Version}-all-languages.tar.bz2 successfully!"
        else
            echo "You enter phpMyAdmin Version was:"${phpMyAdmin_Version}
            Echo_Red "Error! You entered a wrong version number, please check!"
            sleep 5
            exit 1
        fi
    fi
    echo "============================check files=================================="
    echo "Backup old phpMyAdmin..."
    mv ${Default_Website_Dir}/phpmyadmin ${Default_Website_Dir}/phpmyadmin${Upgrade_Date}
    echo "Uncompress phpMyAdmin-${phpMyAdmin_Version}-all-languages.tar.bz2 ..."
    tar jxf phpMyAdmin-${phpMyAdmin_Version}-all-languages.tar.bz2
    mv phpMyAdmin-${phpMyAdmin_Version}-all-languages ${Default_Website_Dir}/phpmyadmin
    \cp ${cur_dir}/conf/config.inc.php ${Default_Website_Dir}/phpmyadmin/config.inc.php
    sed -i 's/LNMPORG/LNMP.org'$RANDOM'VPSer.net/g' ${Default_Website_Dir}/phpmyadmin/config.inc.php
    mkdir ${Default_Website_Dir}/phpmyadmin/{upload,save}
    chmod 755 -R ${Default_Website_Dir}/phpmyadmin/
    chown www:www -R ${Default_Website_Dir}/phpmyadmin/
    Echo_Green "======== upgrade phpMyAdmin completed ======"
}
