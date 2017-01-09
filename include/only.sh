#!/bin/bash

Install_Only_Nginx()
{
    clear
    echo "+-----------------------------------------------------------------------+"
    echo "|              Install Nginx for LNMP, Written by Licess                |"
    echo "+-----------------------------------------------------------------------+"
    echo "|                     A tool to only install Nginx.                     |"
    echo "+-----------------------------------------------------------------------+"
    echo "|           For more information please visit https://lnmp.org          |"
    echo "+-----------------------------------------------------------------------+"
    Press_Install
    Echo_Blue "Install dependent packages..."
    cd ${cur_dir}/src
    if [ "$PM" = "yum" ]; then
        CentOS_Dependent
    elif [ "$PM" = "apt" ]; then
        Deb_Dependent
    fi
    cd ${cur_dir}/src
    Install_Pcre
    if [ `grep -L '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/local/lib" >> /etc/ld.so.conf
    fi
    ldconfig
    Download_Files ${Download_Mirror}/web/nginx/${Nginx_Ver}.tar.gz ${Nginx_Ver}.tar.gz
    Install_Nginx
    StartUp nginx
    /etc/init.d/nginx start
    Add_Iptables_Rules
    \cp ${cur_dir}/conf/index.html ${Default_Website_Dir}/index.html
    Check_Nginx_Files
    exit 0
    exit 0
}

Install_Database()
{
    echo "============================check files=================================="
    cd ${cur_dir}/src
    if [[ "${DBSelect}" = "1" || "${DBSelect}" = "2" || "${DBSelect}" = "3" || "${DBSelect}" = "4" ]]; then
        Download_Files ${Download_Mirror}/datebase/mysql/${Mysql_Ver}.tar.gz ${Mysql_Ver}.tar.gz
    elif [[ "${DBSelect}" = "5" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]]; then
        Download_Files ${Download_Mirror}/datebase/mariadb/${Mariadb_Ver}.tar.gz ${Mariadb_Ver}.tar.gz
    fi
    echo "============================check files=================================="

    Echo_Blue "Install dependent packages..."
    if [ "$PM" = "yum" ]; then
        CentOS_Dependent
    elif [ "$PM" = "apt" ]; then
        Deb_Dependent
    fi
    if [ "${DBSelect}" = "1" ]; then
        Install_MySQL_51
    elif [ "${DBSelect}" = "2" ]; then
        Install_MySQL_55
    elif [ "${DBSelect}" = "3" ]; then
        Install_MySQL_56
    elif [ "${DBSelect}" = "4" ]; then
        Install_MySQL_57
    elif [ "${DBSelect}" = "5" ]; then
        Install_MariaDB_5
    elif [ "${DBSelect}" = "6" ]; then
        Install_MariaDB_10
    elif [ "${DBSelect}" = "7" ]; then
        Install_MariaDB_101
    fi
    TempMycnf_Clean

    if [[ "${DBSelect}" = "5" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]]; then
        StartUp mariadb
        /etc/init.d/mariadb start
    elif [[ "${DBSelect}" = "1" || "${DBSelect}" = "2" || "${DBSelect}" = "3" || "${DBSelect}" = "4" ]]; then
        StartUp mysql
        /etc/init.d/mysql start
    fi

    Check_DB_Files
    if [[ "${isDB}" = "ok" ]]; then
        if [[ "${DBSelect}" = "1" || "${DBSelect}" = "2" || "${DBSelect}" = "3" || "${DBSelect}" = "4" ]]; then
            Echo_Green "MySQL root password: ${DB_Root_Password}"
            Echo_Green "Install ${Mysql_Ver} completed! enjoy it."
            exit 0
            exit 0
        elif [[ "${DBSelect}" = "5" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]]; then
            Echo_Green "MariaDB root password: ${DB_Root_Password}"
            Echo_Green "Install ${Mariadb_Ver} completed! enjoy it."
            exit 0
            exit 0
        fi
    fi
}

Install_Only_Database()
{
    clear
    echo "+-----------------------------------------------------------------------+"
    echo "|      Install MySQL/MariaDB database for LNMP, Written by Licess       |"
    echo "+-----------------------------------------------------------------------+"
    echo "|               A tool to install MySQL/MariaDB for LNMP                |"
    echo "+-----------------------------------------------------------------------+"
    echo "|           For more information please visit https://lnmp.org          |"
    echo "+-----------------------------------------------------------------------+"

    Get_OS_Bit
    Get_Dist_Name
    Check_DB
    if [ ${DB_Name} != "None" ]; then
        echo "You have install ${DB_Name}!"
        exit 1
    fi

    Database_Selection
    Press_Install
    Install_Database 2>&1 | tee /root/install_database.log
}
