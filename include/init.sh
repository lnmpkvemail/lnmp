#!/bin/bash

Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

CentOS_InstallNTP()
{
    Echo_Blue "[+] Installing ntp..."
    yum install -y ntp
    ntpdate -u pool.ntp.org
    date
    start_time=$(date +%s)
}

Deb_InstallNTP()
{
    apt-get update -y
    Echo_Blue "[+] Installing ntp..."
    apt-get install -y ntpdate
    ntpdate -u pool.ntp.org
    date
    start_time=$(date +%s)
}

CentOS_RemoveAMP()
{
    Echo_Blue "[-] Yum remove packages..."
    rpm -qa|grep httpd
    rpm -e httpd httpd-tools --nodeps
    rpm -qa|grep mysql
    rpm -e mysql mysql-libs --nodeps
    rpm -qa|grep php
    rpm -e php-mysql php-cli php-gd php-common php --nodeps

    Remove_Error_Libcurl

    yum -y remove httpd*
    yum -y remove mysql-server mysql mysql-libs
    yum -y remove php*
    yum clean all
}

Deb_RemoveAMP()
{
    Echo_Blue "[-] apt-get remove packages..."
    apt-get update -y
    for removepackages in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5 php5 php5-common php5-cgi php5-cli php5-mysql php5-curl php5-gd;
    do apt-get purge -y $removepackages; done
    killall apache2
    dpkg -l |grep apache
    dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
    dpkg -l |grep mysql
    dpkg -P mysql-server mysql-common libmysqlclient15off libmysqlclient15-dev
    dpkg -l |grep php
    dpkg -P php5 php5-common php5-cli php5-cgi php5-mysql php5-curl php5-gd
    apt-get autoremove -y && apt-get clean
}

Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Xen_Hwcap_Setting()
{
    if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
        sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
    fi
}

Check_Hosts()
{
    if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
        echo "Hosts: ok."
    else
        echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    fi
    pingresult=`ping -c1 lnmp.org 2>&1`
    echo "${pingresult}"
    if echo "${pingresult}" | grep -q "unknown host"; then
        echo "DNS...fail"
        echo "Writing nameserver to /etc/resolv.conf ..."
        echo -e "nameserver 208.67.220.220\nnameserver 114.114.114.114" > /etc/resolv.conf
    else
        echo "DNS...ok"
    fi
}

RHEL_Modify_Source()
{
    Get_RHEL_Version
    \cp ${cur_dir}/conf/CentOS-Base-163.repo /etc/yum.repos.d/CentOS-Base-163.repo
    sed -i "s/\$releasever/${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
    sed -i "s/RPM-GPG-KEY-CentOS-6/RPM-GPG-KEY-CentOS-${RHEL_Ver}/g" /etc/yum.repos.d/CentOS-Base-163.repo
    yum clean all
    yum makecache
}

Ubuntu_Modify_Source()
{
    if [ "${country}" = "CN" ]; then
        OldReleasesURL='http://mirrors.ustc.edu.cn/ubuntu-old-releases/ubuntu/dists/'
    else
        OldReleasesURL='http://old-releases.ubuntu.com/ubuntu/'
    fi
    CodeName=''
    if grep -Eqi "10.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.10'; then
        CodeName='maverick'
    elif grep -Eqi "11.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.04'; then
        CodeName='natty'
    elif  grep -Eqi "11.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^11.10'; then
        CodeName='oneiric'
    elif grep -Eqi "12.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.10'; then
        CodeName='quantal'
    elif grep -Eqi "13.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.04'; then
        CodeName='raring'
    elif grep -Eqi "13.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^13.10'; then
        CodeName='saucy'
    elif grep -Eqi "10.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^10.04'; then
        CodeName='lucid'
    elif grep -Eqi "14.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.10'; then
        CodeName='utopic'
    elif grep -Eqi "15.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.04'; then
        CodeName='vivid'
    elif grep -Eqi "12.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^12.04'; then
        CodeName='precise'
    elif grep -Eqi "15.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^15.10'; then
        CodeName='wily'
    elif grep -Eqi "16.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^16.10'; then
        Ubuntu_Deadline yakkety
    elif grep -Eqi "14.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^14.04'; then
        Ubuntu_Deadline trusty
    elif grep -Eqi "17.04" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^17.04'; then
        Ubuntu_Deadline zesty
    elif grep -Eqi "17.10" /etc/*-release || echo "${Ubuntu_Version}" | grep -Eqi '^17.04'; then
        Ubuntu_Deadline artful
    fi
    if [ "${CodeName}" != "" ]; then
        \cp /etc/apt/sources.list /etc/apt/sources.list.$(date +"%Y%m%d")
        cat > /etc/apt/sources.list<<EOF
deb ${OldReleasesURL} ${CodeName} main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-security main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-updates main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-proposed main restricted universe multiverse
deb ${OldReleasesURL} ${CodeName}-backports main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName} main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-security main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-updates main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-proposed main restricted universe multiverse
deb-src ${OldReleasesURL} ${CodeName}-backports main restricted universe multiverse
EOF
    fi
}

Check_Old_Releases_URL()
{
    OR_Status=`wget --spider --server-response http://${OldReleasesURL}/ubuntu/dists/$1/Release 2>&1 | awk '/^  HTTP/{print $2}'`
    if [ ${OR_Status} != "404" ]; then
        echo "Ubuntu old-releases status: ${OR_Status}";
        CodeName=$1
    fi
}

Ubuntu_Deadline()
{
    yakkety_deadline=`date -d "2017-7-22 00:00:00" +%s`
    trusty_deadline=`date -d "2019-7-22 00:00:00" +%s`
    zesty_deadline=`date -d "2018-1-31 00:00:00" +%s`
    artful_deadline=`date -d "2018-7-31 00:00:00" +%s`
    cur_time=`date  +%s`
    case "$1" in
        yakkety)
            if [ ${cur_time} -gt ${yakkety_deadline} ]; then
                echo "${cur_time} > ${yakkety_deadline}"
                Check_Old_Releases_URL yakkety
            fi
            ;;
        trusty)
            if [ ${cur_time} -gt ${trusty_deadline} ]; then
                echo "${cur_time} > ${trusty_deadline}"
                Check_Old_Releases_URL trusty
            fi
            ;;
        zesty)
            if [ ${cur_time} -gt ${zesty_deadline} ]; then
                echo "${cur_time} > ${zesty_deadline}"
                Check_Old_Releases_URL zesty
            fi
            ;;
        artful)
            if [ ${cur_time} -gt ${artful_deadline} ]; then
                echo "${cur_time} > ${artful_deadline}"
                Check_Old_Releases_URL artful
            fi
            ;;
    esac
}

CentOS_Dependent()
{
    if [ -s /etc/yum.conf ]; then
        \cp /etc/yum.conf /etc/yum.conf.lnmp
        sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
    fi

    Echo_Blue "[+] Yum installing dependent packages..."
    for packages in make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget crontabs libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libzip-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz expat-deve libaio-devel;
    do yum -y install $packages; done

    if [ -s /etc/yum.conf.lnmp ]; then
        mv -f /etc/yum.conf.lnmp /etc/yum.conf
    fi
}

Deb_Dependent()
{
    Echo_Blue "[+] Apt-get installing dependent packages..."
    apt-get update -y
    apt-get autoremove -y
    apt-get -fy install
    export DEBIAN_FRONTEND=noninteractive
    apt-get --no-install-recommends install -y build-essential gcc g++ make
    for packages in debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf automake re2c wget cron bzip2 libzip-dev libc6-dev bison file rcconf flex vim bison m4 gawk less cpp binutils diffutils unzip tar bzip2 libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev openssl libssl-dev zlibc libsasl2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg-dev libpng-dev libpng12-0 libpng12-dev libkrb5-dev curl libcurl3 libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpq-dev libpq5 gettext libpng12-dev libxml2-dev libcap-dev ca-certificates libc-client2007e-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt libxslt1-dev libc-client-dev xz-utils libexpat1-dev libaio-dev;
    do apt-get --no-install-recommends install -y $packages; done
}

Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/lib/autoconf/${Autoconf_Ver}.tar.gz ${Autoconf_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/libiconv/${Libiconv_Ver}.tar.gz ${Libiconv_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/libmcrypt/${LibMcrypt_Ver}.tar.gz ${LibMcrypt_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/mcrypt/${Mcypt_Ver}.tar.gz ${Mcypt_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/mhash/${Mhash_Ver}.tar.bz2 ${Mhash_Ver}.tar.bz2
    Download_Files ${Download_Mirror}/lib/freetype/${Freetype_Ver}.tar.bz2 ${Freetype_Ver}.tar.bz2
    Download_Files ${Download_Mirror}/lib/curl/${Curl_Ver}.tar.bz2 ${Curl_Ver}.tar.bz2
    Download_Files ${Download_Mirror}/web/pcre/${Pcre_Ver}.tar.bz2 ${Pcre_Ver}.tar.bz2
    if [ "${SelectMalloc}" = "2" ]; then
        Download_Files ${Download_Mirror}/lib/jemalloc/${Jemalloc_Ver}.tar.bz2 ${Jemalloc_Ver}.tar.bz2
    elif [ "${SelectMalloc}" = "3" ]; then
        Download_Files ${Download_Mirror}/lib/tcmalloc/${TCMalloc_Ver}.tar.gz ${TCMalloc_Ver}.tar.gz
        Download_Files ${Download_Mirror}/lib/libunwind/${Libunwind_Ver}.tar.gz ${Libunwind_Ver}.tar.gz
    fi
    Download_Files ${Download_Mirror}/web/nginx/${Nginx_Ver}.tar.gz ${Nginx_Ver}.tar.gz
    if [[ "${DBSelect}" =~ ^[1234]$ ]]; then
        Download_Files ${Download_Mirror}/datebase/mysql/${Mysql_Ver}.tar.gz ${Mysql_Ver}.tar.gz
    elif [[ "${DBSelect}" =~ ^[5678]$ ]]; then
        Download_Files ${Download_Mirror}/datebase/mariadb/${Mariadb_Ver}.tar.gz ${Mariadb_Ver}.tar.gz
    fi
    Download_Files ${Download_Mirror}/web/php/${Php_Ver}.tar.bz2 ${Php_Ver}.tar.bz2
    if [ ${PHPSelect} = "1" ]; then
        Download_Files ${Download_Mirror}/web/phpfpm/${Php_Ver}-fpm-0.5.14.diff.gz ${Php_Ver}-fpm-0.5.14.diff.gz
    fi
    Download_Files ${Download_Mirror}/datebase/phpmyadmin/${PhpMyAdmin_Ver}.tar.xz ${PhpMyAdmin_Ver}.tar.xz
    Download_Files ${Download_Mirror}/prober/p.tar.gz p.tar.gz
    if [ "${Stack}" != "lnmp" ]; then
        Download_Files ${Download_Mirror}/web/apache/${Apache_Ver}.tar.bz2 ${Apache_Ver}.tar.bz2
        Download_Files ${Download_Mirror}/web/apache/${APR_Ver}.tar.bz2 ${APR_Ver}.tar.bz2
        Download_Files ${Download_Mirror}/web/apache/${APR_Util_Ver}.tar.bz2 ${APR_Util_Ver}.tar.bz2
    fi
    Download_Files ${Download_Mirror}/lib/openssl/${Openssl_Ver}.tar.gz ${Openssl_Ver}.tar.gz
}

Install_Autoconf()
{
    Echo_Blue "[+] Installing ${Autoconf_Ver}"
    Tar_Cd ${Autoconf_Ver}.tar.gz ${Autoconf_Ver}
    ./configure --prefix=/usr/local/autoconf-2.13
    make && make install
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Autoconf_Ver}
}

Install_Libiconv()
{
    Echo_Blue "[+] Installing ${Libiconv_Ver}"
    Tar_Cd ${Libiconv_Ver}.tar.gz ${Libiconv_Ver}
    patch -p0 < ${cur_dir}/src/patch/libiconv-glibc-2.16.patch
    ./configure --enable-static
    make && make install
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Libiconv_Ver}
}

Install_Libmcrypt()
{
    Echo_Blue "[+] Installing ${LibMcrypt_Ver}"
    Tar_Cd ${LibMcrypt_Ver}.tar.gz ${LibMcrypt_Ver}
    ./configure
    make && make install
    /sbin/ldconfig
    cd libltdl/
    ./configure --enable-ltdl-install
    make && make install
    ln -sf /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
    ln -sf /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
    ln -sf /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
    ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
    ldconfig
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${LibMcrypt_Ver}
}

Install_Mcrypt()
{
    Echo_Blue "[+] Installing ${Mcypt_Ver}"
    Tar_Cd ${Mcypt_Ver}.tar.gz ${Mcypt_Ver}
    ./configure
    make && make install
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Mcypt_Ver}
}

Install_Mhash()
{
    Echo_Blue "[+] Installing ${Mhash_Ver}"
    Tarj_Cd ${Mhash_Ver}.tar.bz2 ${Mhash_Ver}
    ./configure
    make && make install
    ln -sf /usr/local/lib/libmhash.a /usr/lib/libmhash.a
    ln -sf /usr/local/lib/libmhash.la /usr/lib/libmhash.la
    ln -sf /usr/local/lib/libmhash.so /usr/lib/libmhash.so
    ln -sf /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
    ln -sf /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
    ldconfig
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Mhash_Ver}
}

Install_Freetype()
{
    Echo_Blue "[+] Installing ${Freetype_Ver}"
    Tarj_Cd ${Freetype_Ver}.tar.bz2 ${Freetype_Ver}
    ./configure --prefix=/usr/local/freetype
    make && make install

    cat > /etc/ld.so.conf.d/freetype.conf<<EOF
/usr/local/freetype/lib
EOF
    ldconfig
    ln -sf /usr/local/freetype/include/freetype2 /usr/local/include
    ln -sf /usr/local/freetype/include/ft2build.h /usr/local/include
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Freetype_Ver}
}

Install_Curl()
{
    if [[ ! -s /usr/local/curl/bin/curl || ! -s /usr/local/curl/lib/libcurl.so || ! -s /usr/local/curl/include/curl/curl.h ]]; then
        Echo_Blue "[+] Installing ${Curl_Ver}"
        Tarj_Cd ${Curl_Ver}.tar.bz2 ${Curl_Ver}
        ./configure --prefix=/usr/local/curl --enable-ares --without-nss --with-ssl
        make && make install
        cd ${cur_dir}/src/
        rm -rf ${cur_dir}/src/${Curl_Ver}
    fi
    Remove_Error_Libcurl
}

Install_Pcre()
{
    if [ ! -s /usr/bin/pcre-config ] || /usr/bin/pcre-config --version | grep -vEqi '^8.'; then
        Echo_Blue "[+] Installing ${Pcre_Ver}"
        Tarj_Cd ${Pcre_Ver}.tar.bz2 ${Pcre_Ver}
        ./configure
        make && make install
        cd ${cur_dir}/src/
        rm -rf ${cur_dir}/src/${Pcre_Ver}
    fi
}

Install_Jemalloc()
{
    Echo_Blue "[+] Installing ${Jemalloc_Ver}"
    cd ${cur_dir}/src
    Tarj_Cd ${Jemalloc_Ver}.tar.bz2 ${Jemalloc_Ver}
    ./configure
    make && make install
    ldconfig
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Jemalloc_Ver}
}

Install_TCMalloc()
{
    Echo_Blue "[+] Installing ${TCMalloc_Ver}"
    if [ "${Is_64bit}" = "y" ]; then
        Tar_Cd ${Libunwind_Ver}.tar.gz ${Libunwind_Ver}
        CFLAGS=-fPIC ./configure
        make CFLAGS=-fPIC
        make CFLAGS=-fPIC install
        rm -rf ${cur_dir}/src/${Libunwind_Ver}
    fi
    Tar_Cd ${TCMalloc_Ver}.tar.gz ${TCMalloc_Ver}
    if [ "${Is_64bit}" = "y" ]; then
        ./configure
    else
        ./configure --enable-frame-pointers
    fi
    make && make install
    ldconfig
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${TCMalloc_Ver}
}

Install_Icu4c()
{
    if [ ! -s /usr/bin/icu-config ] || /usr/bin/icu-config --version | grep '^3.'; then
        Echo_Blue "[+] Installing ${Libicu4c_Ver}"
        cd ${cur_dir}/src
        Download_Files ${Download_Mirror}/lib/icu4c/${Libicu4c_Ver}-src.tgz ${Libicu4c_Ver}-src.tgz
        Tar_Cd ${Libicu4c_Ver}-src.tgz icu/source
        ./configure --prefix=/usr
        make && make install
        cd ${cur_dir}/src/
        rm -rf ${cur_dir}/src/icu
    fi
}

Install_Boost()
{
    Echo_Blue "[+] Installing ${Boost_Ver}"
    if [ "$PM" = "yum" ]; then
        yum -y install python-devel
    elif [ "$PM" = "apt" ]; then
        apt-get update
        apt-get install -y python-dev
    fi
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/lib/boost/${Boost_Ver}.tar.bz2 ${Boost_Ver}.tar.bz2
    Tarj_Cd ${Boost_Ver}.tar.bz2 ${Boost_Ver}
    ./bootstrap.sh
    ./b2
    ./b2 install
    cd ${cur_dir}/src/
    rm -rf ${cur_dir}/src/${Boost_Ver}
}

Install_Openssl()
{
    if [ ! -s /usr/local/openssl/bin/openssl ] || /usr/local/openssl/bin/openssl version | grep -v 'OpenSSL 1.0.2'; then
        Echo_Blue "[+] Installing ${Openssl_Ver}"
        cd ${cur_dir}/src
        Download_Files ${Download_Mirror}/lib/openssl/${Openssl_Ver}.tar.gz ${Openssl_Ver}.tar.gz
        [[ -d "${Openssl_Ver}" ]] && rm -rf ${Openssl_Ver}
        Tar_Cd ${Openssl_Ver}.tar.gz ${Openssl_Ver}
        ./config -fPIC --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
        make depend
        make && make install
        cd ${cur_dir}/src/
        rm -rf ${cur_dir}/src/${Openssl_Ver}
    fi
}

Install_Nghttp2()
{
    if [[ ! -s /usr/local/nghttp2/lib/libnghttp2.so || ! -s /usr/local/nghttp2/include/nghttp2/nghttp2.h ]]; then
        Echo_Blue "[+] Installing ${Nghttp2_Ver}"
        cd ${cur_dir}/src
        Download_Files ${Download_Mirror}/lib/nghttp2/${Nghttp2_Ver}.tar.xz ${Nghttp2_Ver}.tar.xz
        [[ -d "${Nghttp2_Ver}" ]] && rm -rf ${Nghttp2_Ver}
        tar Jxf ${Nghttp2_Ver}.tar.xz && cd ${Nghttp2_Ver}
        ./configure --prefix=/usr/local/nghttp2
        make && make install
        cd ${cur_dir}/src/
        rm -rf ${cur_dir}/src/${Nghttp2_Ver}
    fi
}

CentOS_Lib_Opt()
{
    if [ "${Is_64bit}" = "y" ] ; then
        ln -sf /usr/lib64/libpng.* /usr/lib/
        ln -sf /usr/lib64/libjpeg.* /usr/lib/
    fi

    ulimit -v unlimited

    if [ `grep -L "/lib"    '/etc/ld.so.conf'` ]; then
        echo "/lib" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib" >> /etc/ld.so.conf
        #echo "/usr/lib/openssl/engines" >> /etc/ld.so.conf
    fi

    if [ -d "/usr/lib64" ] && [ `grep -L '/usr/lib64'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib64" >> /etc/ld.so.conf
        #echo "/usr/lib64/openssl/engines" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/local/lib" >> /etc/ld.so.conf
    fi

    ldconfig

    cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

    echo "fs.file-max=65535" >> /etc/sysctl.conf
}

Deb_Lib_Opt()
{
    if [ "${Is_64bit}" = "y" ]; then
        ln -sf /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/
    else
        ln -sf /usr/lib/i386-linux-gnu/libpng* /usr/lib/
        ln -sf /usr/lib/i386-linux-gnu/libjpeg* /usr/lib/
        ln -sf /usr/include/i386-linux-gnu/asm /usr/include/asm
    fi

    ulimit -v unlimited

    if [ `grep -L "/lib"    '/etc/ld.so.conf'` ]; then
        echo "/lib" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib" >> /etc/ld.so.conf
    fi

    if [ -d "/usr/lib64" ] && [ `grep -L '/usr/lib64'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib64" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/local/lib" >> /etc/ld.so.conf
    fi

    if [ -d /usr/include/x86_64-linux-gnu/curl ]; then
        ln -sf /usr/include/x86_64-linux-gnu/curl /usr/include/
    elif [ -d /usr/include/i386-linux-gnu/curl ]; then
        ln -sf /usr/include/i386-linux-gnu/curl /usr/include/
    fi

    if [ -d /usr/include/arm-linux-gnueabihf/curl ]; then
        ln -sf /usr/include/arm-linux-gnueabihf/curl /usr/include/
    fi

    ldconfig

    cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

    echo "fs.file-max=65535" >> /etc/sysctl.conf
}

Remove_Error_Libcurl()
{
    if [ -s /usr/local/lib/libcurl.so ]; then
        rm -f /usr/local/lib/libcurl*
    fi
}