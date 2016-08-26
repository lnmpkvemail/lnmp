#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

. lnmp.conf
. include/main.sh
. include/init.sh
. include/mysql.sh
. include/mariadb.sh
. include/end.sh

clear
echo "+-----------------------------------------------------------------------+"
echo "|      Install MySQL/MariaDB database for LNMP, Written by Licess       |"
echo "+-----------------------------------------------------------------------+"
echo "|               A tool to install MySQL/MariaDB for LNMP                |"
echo "+-----------------------------------------------------------------------+"
echo "|          For more information please visit http://www.lnmp.org        |"
echo "+-----------------------------------------------------------------------+"

cur_dir=$(pwd)
Get_OS_Bit
Get_Dist_Name

if [ -s /usr/local/mysql/bin/mysql ]; then
    echo "You have install MySQL!"
    exit 1
elif [ -s /usr/local/mariadb/bin/mysql ]; then
    echo "You have install MariaDB!"
    exit 1
fi

#which MySQL Version do you want to install?
DBSelect="2"
Echo_Yellow "You have 5 options for your DataBase install."
echo "1: Install MySQL 5.1.73"
echo "2: Install MySQL 5.5.48 (Default)"
echo "3: Install MySQL 5.6.29"
echo "4: Install MySQL 5.7.11"
echo "5: Install MariaDB 5.5.48"
echo "6: Install MariaDB 10.0.23"
echo "7: Install MariaDB 10.1.16"
read -p "Enter your choice (1, 2, 3, 4, 5, 6 or 7): " DBSelect

case "${DBSelect}" in
1)
    echo "You will install MySQL 5.1.73"
    ;;
2)
    echo "You will install MySQL 5.5.48"
    ;;
3)
    echo "You will Install MySQL 5.6.29"
    ;;
4)
    echo "You will install MySQL 5.7.11"
    ;;
5)
    echo "You will install MariaDB 5.5.48"
    ;;
6)
    echo "You will install MariaDB 10.0.23"
    ;;
7)
    echo "You will install MariaDB 10.1.16"
    ;;
*)
    echo "No input,You will install MySQL 5.5.48"
    DBSelect="2"
esac

if [[ "${DBSelect}" = "3" || "${DBSelect}" = "4" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]] && [ `free -m | grep Mem | awk '{print  $2}'` -le 1024 ]; then
    echo "Memory less than 1GB, can't install MySQL 5.6, 5.7 or MairaDB 10!"
    exit 1
fi

if [[ "${DBSelect}" = "5" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]]; then
    MySQL_Bin="/usr/local/mariadb/bin/mysql"
    MySQL_Config="/usr/local/mariadb/bin/mysql_config"
    MySQL_Dir="/usr/local/mariadb"
elif [[ "${DBSelect}" = "1" || "${DBSelect}" = "2" || "${DBSelect}" = "3" || "${DBSelect}" = "4" ]]; then
    MySQL_Bin="/usr/local/mysql/bin/mysql"
    MySQL_Config="/usr/local/mysql/bin/mysql_config"
    MySQL_Dir="/usr/local/mysql"
fi

#set mysql root password
echo "==========================="
DB_Root_Password="root"
Echo_Yellow "Please setup root password of MySQL.(Default password: root)"
read -p "Please enter: " DB_Root_Password
if [ "${DB_Root_Password}" = "" ]; then
    DB_Root_Password="root"
fi
echo "MySQL root password: ${DB_Root_Password}"

#do you want to enable or disable the InnoDB Storage Engine?
echo "==========================="

InstallInnodb="y"
Echo_Yellow "Do you want to enable or disable the InnoDB Storage Engine?"
read -p "Default enable,Enter your choice [Y/n]: " InstallInnodb

case "${InstallInnodb}" in
[yY][eE][sS]|[yY])
    echo "You will enable the InnoDB Storage Engine"
    InstallInnodb="y"
    ;;
[nN][oO]|[nN])
    echo "You will disable the InnoDB Storage Engine!"
    InstallInnodb="n"
    ;;
*)
    echo "No input,The InnoDB Storage Engine will enable."
    InstallInnodb="y"
esac

Press_Install

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
        for packages in make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch libicu-devel;
        do yum -y install $packages; done
    elif [ "$PM" = "apt" ]; then
        apt-get update
        for packages in build-essential gcc g++ make cmake autoconf automake file libicu-dev;
        do apt-get install -y $packages --force-yes; done
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
        elif [[ "${DBSelect}" = "5" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]]; then
            Echo_Green "MariaDB root password: ${DB_Root_Password}"
            Echo_Green "Install ${Mariadb_Ver} completed! enjoy it."
        fi
    fi
}

Install_Database 2>&1 | tee /root/install_database.log