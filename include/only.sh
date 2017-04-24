#!/bin/bash

Nginx_Dependent()
{
    if [ "$PM" = "yum" ]; then
        rpm -e httpd httpd-tools --nodeps
        yum -y remove httpd*
        for packages in make gcc gcc-c++ gcc-g77 wget crontabs zlib zlib-devel openssl openssl-devel;
        do yum -y install $packages; done
    elif [ "$PM" = "apt" ]; then
        apt-get update -y
        dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
        for removepackages in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker;
        do apt-get purge -y $removepackages; done
        for packages in debian-keyring debian-archive-keyring build-essential gcc g++ make autoconf automake wget cron openssl libssl-dev zlib1g zlib1g-dev ;
        do apt-get --no-install-recommends install -y $packages --force-yes; done
    fi
}

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
    Nginx_Dependent
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/pcre/${Pcre_Ver}.tar.bz2 ${Pcre_Ver}.tar.bz2
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
