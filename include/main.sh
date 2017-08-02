#!/bin/bash

DB_Info=('MySQL 5.1.73' 'MySQL 5.5.56' 'MySQL 5.6.36' 'MySQL 5.7.18' 'MariaDB 5.5.56' 'MariaDB 10.0.30' 'MariaDB 10.1.23')
PHP_Info=('PHP 5.2.17' 'PHP 5.3.29' 'PHP 5.4.45' 'PHP 5.5.38' 'PHP 5.6.31' 'PHP 7.0.21' 'PHP 7.1.7')
Apache_Info=('Apache 2.2.34' 'Apache 2.4.27')

Database_Selection()
{
#which MySQL Version do you want to install?
    DBSelect="2"
    Echo_Yellow "You have 5 options for your DataBase install."
    echo "1: Install ${DB_Info[0]}"
    echo "2: Install ${DB_Info[1]} (Default)"
    echo "3: Install ${DB_Info[2]}"
    echo "4: Install ${DB_Info[3]}"
    echo "5: Install ${DB_Info[4]}"
    echo "6: Install ${DB_Info[5]}"
    echo "7: Install ${DB_Info[6]}"
    echo "0: DO NOT Install MySQL/MariaDB"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7 or 0): " DBSelect

    case "${DBSelect}" in
    1)
        echo "You will install ${DB_Info[0]}"
        ;;
    2)
        echo "You will install ${DB_Info[1]}"
        ;;
    3)
        echo "You will Install ${DB_Info[2]}"
        ;;
    4)
        echo "You will install ${DB_Info[3]}"
        ;;
    5)
        echo "You will install ${DB_Info[4]}"
        ;;
    6)
        echo "You will install ${DB_Info[5]}"
        ;;
    7)
        echo "You will install ${DB_Info[6]}"
        ;;
    0)
        echo "Do not install MySQL/MariaDB!"
        ;;
    *)
        echo "No input,You will install ${DB_Info[1]}"
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

    if [[ "${DBSelect}" != "0" ]]; then
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
    fi
}

PHP_Selection()
{
#which PHP Version do you want to install?
    echo "==========================="

    PHPSelect="3"
    Echo_Yellow "You have 6 options for your PHP install."
    echo "1: Install ${PHP_Info[0]}"
    echo "2: Install ${PHP_Info[1]}"
    echo "3: Install ${PHP_Info[2]}"
    echo "4: Install ${PHP_Info[3]} (Default)"
    echo "5: Install ${PHP_Info[4]}"
    echo "6: Install ${PHP_Info[5]}"
    echo "7: Install ${PHP_Info[6]}"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6 or 7): " PHPSelect

    case "${PHPSelect}" in
    1)
        echo "You will install ${PHP_Info[0]}"
        if [[ "${DBSelect}" = 0 ]]; then
            echo "You didn't select MySQL/MariaDB can't select ${PHP_Info[0]}!"
            exit 1
        fi
        ;;
    2)
        echo "You will install ${PHP_Info[1]}"
        ;;
    3)
        echo "You will Install ${PHP_Info[2]}"
        ;;
    4)
        echo "You will install ${PHP_Info[3]}"
        ;;
    5)
        echo "You will install ${PHP_Info[4]}"
        ;;
    6)
        echo "You will install ${PHP_Info[5]}"
        ;;
    7)
        echo "You will install ${PHP_Info[6]}"
        ;;
    *)
        echo "No input,You will install ${PHP_Info[3]}"
        PHPSelect="4"
    esac
}

MemoryAllocator_Selection()
{
#which Memory Allocator do you want to install?
    echo "==========================="

    SelectMalloc="1"
    Echo_Yellow "You have 3 options for your Memory Allocator install."
    echo "1: Don't install Memory Allocator. (Default)"
    echo "2: Install Jemalloc"
    echo "3: Install TCMalloc"
    read -p "Enter your choice (1, 2 or 3): " SelectMalloc

    case "${SelectMalloc}" in
    1)
        echo "You will install not install Memory Allocator."
        ;;
    2)
        echo "You will install JeMalloc"
        ;;
    3)
        echo "You will Install TCMalloc"
        ;;
    *)
        echo "No input,You will not install Memory Allocator."
        SelectMalloc="1"
    esac

    if [ "${SelectMalloc}" =  "1" ]; then
        MySQL51MAOpt=''
        MySQL55MAOpt=''
        NginxMAOpt=''
    elif [ "${SelectMalloc}" =  "2" ]; then
        MySQL51MAOpt='--with-mysqld-ldflags=-ljemalloc'
        MySQL55MAOpt="-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc' -DWITH_SAFEMALLOC=OFF"
        MariaDBMAOpt=''
        NginxMAOpt="--with-ld-opt='-ljemalloc'"
    elif [ "${SelectMalloc}" =  "3" ]; then
        MySQL51MAOpt='--with-mysqld-ldflags=-ltcmalloc'
        MySQL55MAOpt="-DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc' -DWITH_SAFEMALLOC=OFF"
        MariaDBMAOpt="-DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc' -DWITH_SAFEMALLOC=OFF"
        NginxMAOpt='--with-google_perftools_module'
    fi
}

Dispaly_Selection()
{
    Database_Selection
    PHP_Selection
    MemoryAllocator_Selection
}

Apache_Selection()
{
    echo "==========================="
#set Server Administrator Email Address
    ServerAdmin=""
    read -p "Please enter Administrator Email Address: " ServerAdmin
    if [ "${ServerAdmin}" == "" ]; then
        echo "Administrator Email Address will set to webmaster@example.com!"
        ServerAdmin="webmaster@example.com"
    else
    echo "==========================="
    echo Server Administrator Email: "${ServerAdmin}"
    echo "==========================="
    fi

#which Apache Version do you want to install?
    echo "==========================="

    ApacheSelect="1"
    Echo_Yellow "You have 2 options for your Apache install."
    echo "1: Install ${Apache_Info[0]} (Default)"
    echo "2: Install ${Apache_Info[1]}"
    read -p "Enter your choice (1 or 2): " ApacheSelect

    if [ "${ApacheSelect}" = "1" ]; then
        echo "You will install ${Apache_Info[0]}"
    elif [ "${ApacheSelect}" = "2" ]; then
        echo "You will install ${Apache_Info[1]}"
    else
        echo "No input,You will install ${Apache_Info[0]}"
        ApacheSelect="1"
    fi
    if [[ "${PHPSelect}" = "1" && "${ApacheSelect}" = "2" ]]; then
        Echo_Red "PHP 5.2.17 is not compatible with Apache 2.4.*."
        Echo_Red "Force use Apache 2.2.31"
        ApacheSelect="1"
    fi
}

Kill_PM()
{
    if ps aux | grep "yum" | grep -qv "grep"; then
        killall yum
    elif ps aux | grep "apt-get" | grep -qv "grep"; then
        killall apt-get
    fi
}

Press_Install()
{
    echo ""
    Echo_Green "Press any key to install...or Press Ctrl+c to cancel"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
    . include/version.sh
    Kill_PM
}

Press_Start()
{
    echo ""
    Echo_Green "Press any key to start...or Press Ctrl+c to cancel"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}

Install_LSB()
{
    echo "[+] Installing lsb..."
    if [ "$PM" = "yum" ]; then
        yum -y install redhat-lsb
    elif [ "$PM" = "apt" ]; then
        apt-get update
        apt-get --no-install-recommends install -y lsb-release
    fi
}

Get_Dist_Version()
{
    if [ -s /usr/bin/python3 ]; then
        eval ${DISTRO}_Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1])'`
    elif [ -s /usr/bin/python2 ]; then
        eval ${DISTRO}_Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1]'`
    fi
    if [ $? -ne 0 ]; then
        Install_LSB
        eval ${DISTRO}_Version=`lsb_release -rs`
    fi
}

Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Amazon Linux AMI" /etc/issue || grep -Eq "Amazon Linux AMI" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
        DISTRO='Mint'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_RHEL_Version()
{
    Get_Dist_Name
    if [ "${DISTRO}" = "RHEL" ]; then
        if grep -Eqi "release 5." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 5"
            RHEL_Ver='5'
        elif grep -Eqi "release 6." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 6"
            RHEL_Ver='6'
        elif grep -Eqi "release 7." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 7"
            RHEL_Ver='7'
        fi
    fi
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}

Get_ARM()
{
    if uname -m | grep -Eqi "arm"; then
        Is_ARM='y'
    fi
}

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate ${URL}
    fi
}

Tar_Cd()
{
    local FileName=$1
    local DirName=$2
    cd ${cur_dir}/src
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    tar zxf ${FileName}
    echo "cd ${DirName}..."
    cd ${DirName}
}

Tarj_Cd()
{
    local FileName=$1
    local DirName=$2
    cd ${cur_dir}/src
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    tar jxf ${FileName}
    echo "cd ${DirName}..."
    cd ${DirName}
}

Check_LNMPConf()
{
    if [ ! -s "${cur_dir}/lnmp.conf" ]; then
        Echo_Red "lnmp.conf was not exsit!"
        exit 1
    fi
    if [[ "${Download_Mirror}" = "" || "${MySQL_Data_Dir}" = "" || "${MariaDB_Data_Dir}" = "" || "${Default_Website_Dir}" = "" ]]; then
        Echo_Red "Can't get values from lnmp.conf!"
        exit 1
    fi
    if [[ "${MySQL_Data_Dir}" = "/" || "${MariaDB_Data_Dir}" = "/" || "${Default_Website_Dir}" = "/" ]]; then
        Echo_Red "Can't set MySQL/MariaDB/Website Directory to / !"
        exit 1
    fi
}

Print_APP_Ver()
{
    echo "You will install ${Stack} stack."
    if [ "${Stack}" != "lamp" ]; then
        echo ${Nginx_Ver}
    fi

    if [[ "${DBSelect}" = "1" || "${DBSelect}" = "2" || "${DBSelect}" = "3" || "${DBSelect}" = "4" ]]; then
        echo "${Mysql_Ver}"
    elif [[ "${DBSelect}" = "5" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]]; then
        echo "${Mariadb_Ver}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install MySQL/MariaDB!"
    fi

    echo "${Php_Ver}"

    if [ "${Stack}" != "lnmp" ]; then
        echo "${Apache_Ver}"
    fi

    if [ "${SelectMalloc}" = "2" ]; then
        echo "${Jemalloc_Ver}"
    elif [ "${SelectMalloc}" = "3" ]; then
        echo "${TCMalloc_Ver}"
    fi
    echo "Enable InnoDB: ${InstallInnodb}"
    echo "Print lnmp.conf infomation..."
    echo "Download Mirror: ${Download_Mirror}"
    echo "Nginx Additional Modules: ${Nginx_Modules_Options}"
    echo "PHP Additional Modules: ${PHP_Modules_Options}"
    if [[ "${DBSelect}" = "1" || "${DBSelect}" = "2" || "${DBSelect}" = "3" || "${DBSelect}" = "4" ]]; then
        echo "Database Directory: ${MySQL_Data_Dir}"
    elif [[ "${DBSelect}" = "5" || "${DBSelect}" = "6" || "${DBSelect}" = "7" ]]; then
        echo "Database Directory: ${MariaDB_Data_Dir}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install MySQL/MariaDB!"
    fi
    echo "Default Website Directory: ${Default_Website_Dir}"
}

Print_Sys_Info()
{
    eval echo "${DISTRO} \${${DISTRO}_Version}"
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo "Memory is: ${MemTotal} MB "
    df -h
}

StartUp()
{
    init_name=$1
    echo "Add ${init_name} service at system startup..."
    if [ "$PM" = "yum" ]; then
        chkconfig --add ${init_name}
        chkconfig ${init_name} on
    elif [ "$PM" = "apt" ]; then
        update-rc.d -f ${init_name} defaults
    fi
}

Remove_StartUp()
{
    init_name=$1
    echo "Removing ${init_name} service at system startup..."
    if [ "$PM" = "yum" ]; then
        chkconfig ${init_name} off
        chkconfig --del ${init_name}
    elif [ "$PM" = "apt" ]; then
        update-rc.d -f ${init_name} remove
    fi
}

Check_Mirror()
{
    if [ ! -s /usr/bin/curl ]; then
        if [ "$PM" = "yum" ]; then
            yum install -y curl
        elif [ "$PM" = "apt" ]; then
            apt-get update
            apt-get install -y curl
        fi
    fi
    country=`curl -sSk --connect-timeout 30 -m 60 https://ip.vpser.net/country`
    echo "Server Location: ${country}"
    if [ "${Download_Mirror}" = "https://soft.vpser.net" ]; then
        mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft.vpser.net`
        if [ "${mirror_code}" != "200" ]; then
            if [ "${country}" = "CN" ]; then
                mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft1.vpser.net`
                if [ "${mirror_code}" = "200" ]; then
                    echo "Change to mirror http://soft1.vpser.net"
                    Download_Mirror='http://soft1.vpser.net'
                else
                    echo "Change to mirror fttp://soft.vpser.net"
                    Download_Mirror='ftp://soft.vpser.net'
                fi
            else
                mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft2.vpser.net`
                if [ "${mirror_code}" = "200" ]; then
                    echo "Change to mirror http://soft2.vpser.net"
                    Download_Mirror='http://soft2.vpser.net'
                else
                    echo "Change to mirror ftp://soft.vpser.net"
                    Download_Mirror='ftp://soft.vpser.net'
                fi
            fi
        fi
    fi
}

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}

Get_PHP_Ext_Dir()
{
    Cur_PHP_Version="`/usr/local/php/bin/php-config --version`"
    zend_ext_dir="`/usr/local/php/bin/php-config --extension-dir`/"
}

Check_Stack()
{
    if [[ -s /usr/local/php/sbin/php-fpm && -s /usr/local/php/etc/php-fpm.conf && -s /etc/init.d/php-fpm && -s /usr/local/nginx/sbin/nginx ]]; then
        Get_Stack="lnmp"
    elif [[ -s /usr/local/nginx/sbin/nginx && -s /usr/local/apache/bin/httpd && -s /usr/local/apache/conf/httpd.conf && -s /etc/init.d/httpd && ! -s /usr/local/php/sbin/php-fpm ]]; then
        Get_Stack="lnmpa"
    elif [[ -s /usr/local/apache/bin/httpd && -s /usr/local/apache/conf/httpd.conf && -s /etc/init.d/httpd && ! -s /usr/local/php/sbin/php-fpm ]]; then
        Get_Stack="lamp"
    else
        Get_Stack="unknow"
    fi
}

Check_DB()
{
    if [[ -s /usr/local/mariadb/bin/mysql && -s /usr/local/mariadb/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        MySQL_Bin="/usr/local/mariadb/bin/mysql"
        MySQL_Config="/usr/local/mariadb/bin/mysql_config"
        MySQL_Dir="/usr/local/mariadb"
        Is_MySQL="n"
        DB_Name="mariadb"
    elif [[ -s /usr/local/mysql/bin/mysql && -s /usr/local/mysql/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        MySQL_Bin="/usr/local/mysql/bin/mysql"
        MySQL_Config="/usr/local/mysql/bin/mysql_config"
        MySQL_Dir="/usr/local/mysql"
        Is_MySQL="y"
        DB_Name="mysql"
    else
        Is_MySQL="None"
        DB_Name="None"
    fi
}

Do_Query()
{
    echo "$1" >/tmp/.mysql.tmp
    Check_DB
    ${MySQL_Bin} --defaults-file=~/.my.cnf </tmp/.mysql.tmp
    return $?
}

Make_TempMycnf()
{
    cat >~/.my.cnf<<EOF
[client]
user=root
password='$1'
EOF
    chmod 600 ~/.my.cnf
}

Verify_DB_Password()
{
    Check_DB
    status=1
    while [ $status -eq 1 ]; do
        read -s -p "Enter current root password of Database (Password will not shown): " DB_Root_Password
        Make_TempMycnf "${DB_Root_Password}"
        Do_Query ""
        status=$?
    done
    echo "OK, MySQL root password correct."
}

TempMycnf_Clean()
{
    if [ -s ~/.my.cnf ]; then
        rm -f ~/.my.cnf
    fi
    if [ -s /tmp/.mysql.tmp ]; then
        rm -f /tmp/.mysql.tmp
    fi
}