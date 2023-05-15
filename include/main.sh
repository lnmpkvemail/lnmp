#!/usr/bin/env bash

DB_Info=('MySQL 5.1.73' 'MySQL 5.5.62' 'MySQL 5.6.51' 'MySQL 5.7.42' 'MySQL 8.0.33' 'MariaDB 5.5.68' 'MariaDB 10.4.29' 'MariaDB 10.5.20' 'MariaDB 10.6.13' 'MariaDB 10.11.3')
PHP_Info=('PHP 5.2.17' 'PHP 5.3.29' 'PHP 5.4.45' 'PHP 5.5.38' 'PHP 5.6.40' 'PHP 7.0.33' 'PHP 7.1.33' 'PHP 7.2.34' 'PHP 7.3.33' 'PHP 7.4.33' 'PHP 8.0.28' 'PHP 8.1.19' 'PHP 8.2.6')
Apache_Info=('Apache 2.2.34' 'Apache 2.4.57')

Database_Selection()
{
#which MySQL Version do you want to install?
    if [ -z ${DBSelect} ]; then
        DBSelect="2"
        Echo_Yellow "You have 11 options for your DataBase install."
        echo "1: Install ${DB_Info[0]}"
        echo "2: Install ${DB_Info[1]} (Default)"
        echo "3: Install ${DB_Info[2]}"
        echo "4: Install ${DB_Info[3]}"
        echo "5: Install ${DB_Info[4]}"
        echo "6: Install ${DB_Info[5]}"
        echo "7: Install ${DB_Info[6]}"
        echo "8: Install ${DB_Info[7]}"
        echo "9: Install ${DB_Info[8]}"
        echo "10: Install ${DB_Info[9]}"
        echo "0: DO NOT Install MySQL/MariaDB"
        read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7, 8, 9, 10 or 0): " DBSelect
    fi

    case "${DBSelect}" in
    1)
        echo "You will install ${DB_Info[0]}"
        ;;
    2)
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[1]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[1]} from Source."
                Bin="n"
                ;;
            *)
                Bin="n"
                ;;
            esac
        else
            echo "Default install ${DB_Info[1]} from Source."
            Bin="n"
        fi
        ;;
    3)
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[2]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[2]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[2]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[2]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    4)
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[3]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[3]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[3]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[3]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    5)
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" || "${DB_ARCH}" = "aarch64" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[4]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[4]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[4]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[4]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    6)
        echo "You will install ${DB_Info[5]}"
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[3]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[3]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[3]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[3]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    7)
        echo "You will install ${DB_Info[6]}"
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[3]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[3]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[3]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[3]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    8)
        echo "You will install ${DB_Info[7]}"
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[3]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[3]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[3]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[3]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    9)
        echo "You will install ${DB_Info[8]}"
        if [[ "${DB_ARCH}" = "x86_64" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[3]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[3]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[3]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[3]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    10)
        echo "You will install ${DB_Info[9]}"
        if [[ "${DB_ARCH}" = "x86_64" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[3]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[3]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[3]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[3]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            Bin="n"
        fi
        ;;
    0)
        echo "Do not install MySQL/MariaDB!"
        ;;
    *)
        echo "No input,You will install ${DB_Info[1]}"
        DBSelect="2"
    esac

    if [ "${Bin}" != "y" ] && [[ "${DBSelect}" =~ ^5|[7-9]|10$ ]] && [ $(awk '/MemTotal/ {printf( "%d\n", $2 / 1024 )}' /proc/meminfo) -le 1024 ]; then
        echo "Memory less than 1GB, can't install MySQL 8.0 or MairaDB 10.3+!"
        exit 1
    fi

    if [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
        MySQL_Bin="/usr/local/mariadb/bin/mysql"
        MySQL_Config="/usr/local/mariadb/bin/mysql_config"
        MySQL_Dir="/usr/local/mariadb"
    elif [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        MySQL_Bin="/usr/local/mysql/bin/mysql"
        MySQL_Config="/usr/local/mysql/bin/mysql_config"
        MySQL_Dir="/usr/local/mysql"
    fi

    if [[ "${DBSelect}" != "0" ]]; then
        #set mysql root password
        if [ -z ${DB_Root_Password} ]; then
            echo "==========================="
            DB_Root_Password="root"
            Echo_Yellow "Please setup root password of MySQL."
            read -p "Please enter: " DB_Root_Password
            if [ "${DB_Root_Password}" = "" ]; then
                echo "NO input,password will be generated randomly."
                DB_Root_Password="lnmp.org#$RANDOM"
            fi
        fi
        echo "MySQL root password: ${DB_Root_Password}"

        #do you want to enable or disable the InnoDB Storage Engine?
        echo "==========================="

        if [ -z ${InstallInnodb} ]; then
            InstallInnodb="y"
            Echo_Yellow "Do you want to enable or disable the InnoDB Storage Engine?"
            read -p "Default enable,Enter your choice [Y/n]: " InstallInnodb
        fi

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
    if [ -z ${PHPSelect} ]; then
        echo "==========================="

        PHPSelect="3"
        Echo_Yellow "You have 9 options for your PHP install."
        echo "1: Install ${PHP_Info[0]}"
        echo "2: Install ${PHP_Info[1]}"
        echo "3: Install ${PHP_Info[2]}"
        echo "4: Install ${PHP_Info[3]}"
        echo "5: Install ${PHP_Info[4]} (Default)"
        echo "6: Install ${PHP_Info[5]}"
        echo "7: Install ${PHP_Info[6]}"
        echo "8: Install ${PHP_Info[7]}"
        echo "9: Install ${PHP_Info[8]}"
        echo "10: Install ${PHP_Info[9]}"
        echo "11: Install ${PHP_Info[10]}"
        echo "12: Install ${PHP_Info[11]}"
        echo "13: Install ${PHP_Info[12]}"
        read -p "Enter your choice (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13): " PHPSelect
    fi

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
    8)
        echo "You will install ${PHP_Info[7]}"
        ;;
    9)
        echo "You will install ${PHP_Info[8]}"
        ;;
    10)
        echo "You will install ${PHP_Info[9]}"
        ;;
    11)
        echo "You will install ${PHP_Info[10]}"
        ;;
    12)
        echo "You will install ${PHP_Info[11]}"
        ;;
    13)
        echo "You will install ${PHP_Info[12]}"
        ;;
    *)
        echo "No input,You will install ${PHP_Info[4]}"
        PHPSelect="5"
    esac
}

MemoryAllocator_Selection()
{
#which Memory Allocator do you want to install?
    if [ -z ${SelectMalloc} ]; then
        echo "==========================="

        SelectMalloc="1"
        Echo_Yellow "You have 3 options for your Memory Allocator install."
        echo "1: Don't install Memory Allocator. (Default)"
        echo "2: Install Jemalloc"
        echo "3: Install TCMalloc"
        read -p "Enter your choice (1, 2 or 3): " SelectMalloc
    fi

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
        MySQLMAOpt=''
        NginxMAOpt=''
    elif [ "${SelectMalloc}" =  "2" ]; then
        MySQL51MAOpt='--with-mysqld-ldflags=-ljemalloc'
        MySQLMAOpt='[mysqld_safe]
malloc-lib=/usr/lib/libjemalloc.so'
        NginxMAOpt="--with-ld-opt='-ljemalloc'"
    elif [ "${SelectMalloc}" =  "3" ]; then
        MySQL51MAOpt='--with-mysqld-ldflags=-ltcmalloc'
        MySQLMAOpt='[mysqld_safe]
malloc-lib=/usr/lib/libtcmalloc.so'
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
    if [ -z ${ServerAdmin} ]; then
        ServerAdmin=""
        read -p "Please enter Administrator Email Address: " ServerAdmin
    fi
    if [ "${ServerAdmin}" == "" ]; then
        echo "Administrator Email Address will set to webmaster@example.com!"
        ServerAdmin="webmaster@example.com"
    else
        echo "==========================="
        echo Server Administrator Email: "${ServerAdmin}"
        echo "==========================="
    fi
    echo "==========================="

#which Apache Version do you want to install?
    if [ -z ${ApacheSelect} ]; then
        ApacheSelect="1"
        Echo_Yellow "You have 2 options for your Apache install."
        echo "1: Install ${Apache_Info[0]}"
        echo "2: Install ${Apache_Info[1]} (Default)"
        read -p "Enter your choice (1 or 2): " ApacheSelect
    fi

    if [ "${ApacheSelect}" = "1" ]; then
        echo "You will install ${Apache_Info[0]}"
    elif [ "${ApacheSelect}" = "2" ]; then
        echo "You will install ${Apache_Info[1]}"
    else
        echo "No input,You will install ${Apache_Info[1]}"
        ApacheSelect="2"
    fi
    if [[ "${PHPSelect}" = "1" && "${ApacheSelect}" = "2" ]]; then
        Echo_Red "PHP 5.2.17 is not compatible with Apache 2.4.*."
        Echo_Red "Force use Apache 2.2.31"
        ApacheSelect="1"
    fi
}

Kill_PM()
{
    if ps aux | grep -E "yum|dnf" | grep -qv "grep"; then
        kill -9 $(ps -ef|grep -E "yum|dnf"|grep -v grep|awk '{print $2}')
        if [ -s /var/run/yum.pid ]; then
            rm -f /var/run/yum.pid
        fi
    elif ps aux | grep -E "apt-get|dpkg|apt" | grep -qv "grep"; then
        kill -9 $(ps -ef|grep -E "apt-get|apt|dpkg"|grep -v grep|awk '{print $2}')
        if [[ -s /var/lib/dpkg/lock-frontend || -s /var/lib/dpkg/lock ]]; then
            rm -f /var/lib/dpkg/lock-frontend
            rm -f /var/lib/dpkg/lock
            dpkg --configure -a
        fi
    fi
}

Press_Install()
{
    if [ -z ${LNMP_Auto} ]; then
        echo ""
        Echo_Green "Press any key to install...or Press Ctrl+c to cancel"
        OLDCONFIG=`stty -g`
        stty -icanon -echo min 1 time 0
        dd count=1 2>/dev/null
        stty ${OLDCONFIG}
    fi
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
    if command -v lsb_release >/dev/null 2>&1; then
        DISTRO_Version=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_Version="$DISTRIB_RELEASE"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_Version="$VERSION_ID"
    fi
    if [[ "${DISTRO}" = "" || "${DISTRO_Version}" = "" ]]; then
        if command -v python2 >/dev/null 2>&1; then
            DISTRO_Version=$(python2 -c 'import platform; print platform.linux_distribution()[1]')
        elif command -v python3 >/dev/null 2>&1; then
            DISTRO_Version=$(python3 -c 'import platform; print(platform.linux_distribution()[1])')
        else
            Install_LSB
            DISTRO_Version=`lsb_release -rs`
        fi
    fi
    printf -v "${DISTRO}_Version" '%s' "${DISTRO_Version}"
}

Get_Dist_Name()
{
    if grep -Eqi "Alibaba" /etc/issue || grep -Eq "Alibaba Cloud Linux" /etc/*-release; then
        DISTRO='Alibaba'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun Linux" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Oracle Linux" /etc/issue || grep -Eq "Oracle Linux" /etc/*-release; then
        DISTRO='Oracle'
        PM='yum'
    elif grep -Eqi "rockylinux" /etc/issue || grep -Eq "Rocky Linux" /etc/*-release; then
        DISTRO='Rocky'
        PM='yum'
    elif grep -Eqi "almalinux" /etc/issue || grep -Eq "AlmaLinux" /etc/*-release; then
        DISTRO='Alma'
        PM='yum'
    elif grep -Eqi "openEuler" /etc/issue || grep -Eq "openEuler" /etc/*-release; then
        DISTRO='openEuler'
        PM='yum'
    elif grep -Eqi "Anolis OS" /etc/issue || grep -Eq "Anolis OS" /etc/*-release; then
        DISTRO='Anolis'
        PM='yum'
    elif grep -Eqi "Kylin Linux Advanced Server" /etc/issue || grep -Eq "Kylin Linux Advanced Server" /etc/*-release; then
        DISTRO='Kylin'
        PM='yum'
    elif grep -Eqi "OpenCloudOS" /etc/issue || grep -Eq "OpenCloudOS" /etc/*-release; then
        DISTRO='OpenCloudOS'
        PM='yum'
    elif grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
        if grep -Eq "CentOS Stream" /etc/*-release; then
            isCentosStream='y'
        fi
    elif grep -Eqi "Red Hat Enterprise Linux" /etc/issue || grep -Eq "Red Hat Enterprise Linux" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
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
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        DISTRO='Kali'
        PM='apt'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "UnionTech OS" /etc/issue || grep -Eq "UnionTech OS" /etc/*-release; then
        DISTRO='UOS'
        if command -v apt >/dev/null 2>&1; then
            PM='apt'
        elif command -v yum >/dev/null 2>&1; then
            PM='yum'
        fi
    elif grep -Eqi "Kylin Linux Desktop" /etc/issue || grep -Eq "Kylin Linux Desktop" /etc/*-release; then
        DISTRO='Kylin'
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
        elif grep -Eqi "release 8." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 8"
            RHEL_Ver='8'
        elif grep -Eqi "release 9." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 9"
            RHEL_Ver='9'
        fi
        RHEL_Version="$(cat /etc/redhat-release | sed 's/.*release\ //' | sed 's/\ .*//')"
    fi
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
        ARCH='x86_64'
        DB_ARCH='x86_64'
    else
        Is_64bit='n'
        ARCH='i386'
        DB_ARCH='i686'
    fi

    if uname -m | grep -Eqi "arm|aarch64"; then
        Is_ARM='y'
        if uname -m | grep -Eqi "armv7|armv6"; then
            ARCH='armhf'
        elif uname -m | grep -Eqi "aarch64"; then
            ARCH='aarch64'
            DB_ARCH='aarch64'
        else
            ARCH='arm'
        fi
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
        wget -c --progress=dot -e dotbytes=20M --prefer-family=IPv4 --no-check-certificate ${URL}
    fi
}

Tar_Cd()
{
    local FileName=$1
    local DirName=$2
    local extension=${FileName##*.}
    cd ${cur_dir}/src
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    if [ "$extension" == "gz" ] || [ "$extension" == "tgz" ]; then
        tar zxf "${FileName}"
    elif [ "$extension" == "bz2" ]; then
        tar jxf "${FileName}"
    elif [ "$extension" == "xz" ]; then
        tar Jxf "${FileName}"
    fi
    if [ -n "${DirName}" ]; then
        echo "cd ${DirName}..."
        cd ${DirName}
    fi
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
        echo "${Nginx_Ver}"
    fi

    if [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        echo "${Mysql_Ver}"
    elif [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
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
    if [ "${Enable_PHP_Fileinfo}" = "y" ]; then
        echo "enable PHP fileinfo."
    fi
    if [ "${Enable_Nginx_Lua}" = "y" ]; then
        echo "enable Nginx Lua."
    fi
    if [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        echo "Database Directory: ${MySQL_Data_Dir}"
    elif [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
        echo "Database Directory: ${MariaDB_Data_Dir}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install MySQL/MariaDB!"
    fi
    echo "Default Website Directory: ${Default_Website_Dir}"
}

Print_Sys_Info()
{
    echo "LNMP Version: ${LNMP_Ver}"
    eval echo "${DISTRO} \${${DISTRO}_Version}"
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024 )}' /proc/meminfo)
    echo "Memory is: ${MemTotal} MB "
    df -h
    Check_Openssl
    Check_WSL
    Check_Docker
    if [ "${CheckMirror}" != "n" ]; then
        Get_Country
        echo "Server Location: ${country}"
    fi
}

StartUp()
{
    init_name=$1
    echo "Add ${init_name} service at system startup..."
    if [ "${isWSL}" = "n" ] && [ "${isDocker}" = "n" ] && command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${init_name}.service || -s /lib/systemd/system/${init_name}.service || -s /usr/lib/systemd/system/${init_name}.service ]]; then
        systemctl daemon-reload
        systemctl enable ${init_name}.service
    else
        if [ "$PM" = "yum" ]; then
            chkconfig --add ${init_name}
            chkconfig ${init_name} on
        elif [ "$PM" = "apt" ]; then
            update-rc.d -f ${init_name} defaults
        fi
    fi
}

Remove_StartUp()
{
    init_name=$1
    echo "Removing ${init_name} service at system startup..."
    if [ "${isWSL}" = "n" ] && [ "${isDocker}" = "n" ] && command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${init_name}.service || -s /lib/systemd/system/${init_name}.service || -s /usr/lib/systemd/system/${init_name}.service ]]; then
        systemctl disable ${init_name}.service
    else
        if [ "$PM" = "yum" ]; then
            chkconfig ${init_name} off
            chkconfig --del ${init_name}
        elif [ "$PM" = "apt" ]; then
            update-rc.d -f ${init_name} remove
        fi
    fi
}

Get_Country()
{
    if command -v curl >/dev/null 2>&1; then
        country=`curl -sSk --connect-timeout 30 -m 60 http://ip.vpszt.com/country`
        if [ $? -ne 0 ]; then
            country=`curl -sSk --connect-timeout 30 -m 60 https://ip.vpser.net/country`
        fi
    else
        country=`wget --timeout=5 --no-check-certificate -q -O - http://ip.vpszt.com/country`
    fi
}

Check_Mirror()
{
    if ! command -v curl >/dev/null 2>&1; then
        if [ "$PM" = "yum" ]; then
            yum install -y curl
        elif [ "$PM" = "apt" ]; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y curl
        fi
    fi
    if [ "${Download_Mirror}" = "https://soft.vpser.net" ]; then
        echo "Try http://soft.vpser.net ..."
        mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft.vpser.net`
        if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
            echo "http://soft.vpser.net http code: ${mirror_code}"
            ping -c 3 soft.vpser.net
        else
            ping -c 3 soft.vpser.net
            if [ "${country}" = "CN" ]; then
                echo "Try http://soft1.vpser.net ..."
                mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft1.vpser.net`
                if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                    echo "Change to mirror http://soft1.vpser.net"
                    Download_Mirror='http://soft1.vpser.net'
                else
                    echo "Try http://soft2.vpser.net ..."
                    mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft2.vpser.net`
                    if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                        echo "Change to mirror http://soft2.vpser.net"
                        Download_Mirror='http://soft2.vpser.net'
                    else
                        echo "Can not connect to download mirror,Please modify lnmp.conf manually."
                        echo "More info,please visit https://lnmp.org/faq/download-url.html"
                        exit 1
                    fi
                fi
            else
                echo "Try http://soft2.vpser.net ..."
                mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft2.vpser.net`
                if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                    echo "Change to mirror http://soft2.vpser.net"
                    Download_Mirror='http://soft2.vpser.net'
                else
                    echo "Try http://soft1.vpser.net ..."
                    mirror_code=`curl -o /dev/null -m 20 --connect-timeout 20 -sk -w %{http_code} http://soft1.vpser.net`
                    if [[ "${mirror_code}" = "200" || "${mirror_code}" = "302" ]]; then
                        echo "Change to mirror http://soft1.vpser.net"
                        Download_Mirror='http://soft1.vpser.net'
                    else
                        echo "Can not connect to download mirror,Please modify lnmp.conf manually."
                        echo "More info,please visit https://lnmp.org/faq/download-url.html"
                        exit 1
                    fi
                fi
            fi
        fi
    fi
}

Check_CMPT()
{
    if [[ "${DBSelect}" = "5" ]]; then
        if echo "${Ubuntu_Version}" | grep -Eqi "^1[0-7]\." || echo "${Debian_Version}" | grep -Eqi "^[4-8]" || echo "${Raspbian_Version}" | grep -Eqi "^[4-8]" || echo "${CentOS_Version}" | grep -Eqi "^[4-7]"  || echo "${RHEL_Version}" | grep -Eqi "^[4-7]" || echo "${Fedora_Version}" | grep -Eqi "^2[0-3]"; then
            Echo_Red "MySQL 8.0 please use latest linux distributions!"
            exit 1
        fi
    fi
    if [[ "${PHPSelect}" =~ ^1[0-2]$ ]]; then
        if echo "${Ubuntu_Version}" | grep -Eqi "^1[0-7]\." || echo "${Debian_Version}" | grep -Eqi "^[4-8]" || echo "${Raspbian_Version}" | grep -Eqi "^[4-8]" || echo "${CentOS_Version}" | grep -Eqi "^[4-6]"  || echo "${RHEL_Version}" | grep -Eqi "^[4-6]" || echo "${Fedora_Version}" | grep -Eqi "^2[0-3]"; then
            Echo_Red "PHP 7.4 and PHP 8.* please use latest linux distributions!"
            exit 1
        fi
    fi
    if [[ "${PHPSelect}" = "1" ]]; then
        if echo "${Ubuntu_Version}" | grep -Eqi "^19|2[0-7]\." || echo "${Debian_Version}" | grep -Eqi "^1[0-9]" || echo "${Raspbian_Version}" | grep -Eqi "^1[0-9]" || echo "${Deepin_Version}" | grep -Eqi "^2[0-9]" || echo "${UOS_Version}" | grep -Eqi "^2[0-9]" || echo "${Fedora_Version}" | grep -Eqi "^29|3[0-9]"; then
            Echo_Red "PHP 5.2 is not supported on very new linux versions such as Ubuntu 19+, Debian 10, Deepin 20+, Fedora 29+ etc."
            exit 1
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

StartOrStop()
{
    local action=$1
    local service=$2
    if [ "${isWSL}" = "n" ] && [ "${isDocker}" = "n" ] && command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${service}.service ]]; then
        systemctl ${action} ${service}.service
    else
        /etc/init.d/${service} ${action}
    fi
}

Check_WSL() {
    if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then
        echo "running on WSL"
        isWSL="y"
    else
        isWSL="n"
    fi
}

Check_Docker() {
    if [ -f /.dockerenv ]; then
        echo "running on Docker"
        isDocker="y"
    elif [ -f /proc/1/cgroup ] && grep -q docker /proc/1/cgroup; then
        echo "running on Docker"
        isDocker="y"
    elif [ -f /proc/self/cgroup ] && grep -q docker /proc/self/cgroup; then
        echo "running on Docker"
        isDocker="y"
    else
        isDocker="n"
    fi
}

Check_Openssl()
{
    if ! command -v openssl >/dev/null 2>&1; then
        Echo_Blue "[+] Installing openssl..."
        if [ "${PM}" = "yum" ]; then
            yum install -y openssl
        elif [ "${PM}" = "apt" ]; then
            apt-get update -y
            [[ $? -ne 0 ]] && apt-get update --allow-releaseinfo-change -y
            apt-get install -y openssl
        fi
    fi
    openssl version
    if openssl version | grep -Eqi "OpenSSL 3.*"; then
        isOpenSSL3='y'
    fi
}
