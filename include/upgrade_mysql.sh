#!/bin/bash

Verify_MySQL_Password()
{
    read -p "verify your current MySQL root password:" mysql_root_password
    /usr/local/mysql/bin/mysql -uroot -p${mysql_root_password} -e "quit"
    if [ $? -eq 0 ]; then
        echo "MySQL root password correct."
    else
        echo "MySQL root password incorrect!Please check!"
        Verify_MySQL_Password
    fi
}

Backup_MySQL()
{
    echo "Starting backup all databases..."
    echo "If the database is large, the backup time will be longer."
    /usr/local/mysql/bin/mysqldump -uroot -p${mysql_root_password} --all-databases > /root/mysql_all_backup$(date +"%Y%m%d").sql
    if [ $? -eq 0 ]; then
        echo "MySQL databases backup successfully.";
    else
        echo "MySQL databases backup failed,Please backup databases manually!"
        exit 1
    fi
    lnmp stop
    mv /etc/init.d/mysql /etc/init.d/mysql.bak.${Upgrade_Date}
    mv /etc/my.cnf /etc/my.conf.bak.${Upgrade_Date}
    cp -a /usr/local/mysql /usr/local/oldmysql${Upgrade_Date}
}

Upgrade_MySQL51()
{
    Tar_Cd mysql-${mysql_version}.tar.gz mysql-${mysql_version}
    if [ $installinnodb = "y" ]; then
    ./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=innobase
    else
    ./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile
    fi
    sed -i '/set -ex;/,/done/d' Makefile
    make && make install
    cd ../

    groupadd mysql
    useradd -s /sbin/nologin -g mysql mysql
    \cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
    sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
    if [ $installinnodb = "y" ]; then
        sed -i 's:#innodb:innodb:g' /etc/my.cnf
        sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
    else
        sed '/skip-external-locking/i\nloose-skip-innodb' -i /etc/my.cnf
    fi
}

Upgrade_MySQL55() {
    echo "Starting upgrade MySQL..."

    Tar_Cd mysql-${mysql_version}.tar.gz mysql-${mysql_version}
    patch -p1 < ${cur_dir}/src/patch/mysql-openssl.patch
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make && make install

    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql

    \cp support-files/my-medium.cnf /etc/my.cnf

    sed '/skip-external-locking/i\datadir = /usr/local/mysql/var' -i /etc/my.cnf
    if [ $installinnodb = "y" ]; then
        sed -i 's:#innodb:innodb:g' /etc/my.cnf
        sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
    else
        sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
    fi

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig
}

Upgrade_MySQL56() {
    echo "Starting upgrade MySQL..."
    Tar_Cd mysql-${mysql_version}.tar.gz mysql-${mysql_version}
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make && make install

    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql
cat > /etc/my.cnf<<EOF
# Example MySQL config file for medium systems.
#
# This is for a system with little memory (32M - 64M) where MySQL plays
# an important part, or systems up to 128M where MySQL is used together with
# other programs (such as a web server)
#
# MySQL programs look for option files in a set of
# locations which depend on the deployment platform.
# You can copy this option file to one of those
# locations. For information about these locations, see:
# http://dev.mysql.com/doc/mysql/en/option-files.html
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.

# The following options will be passed to all MySQL clients
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

# Here follows entries for some specific programs

# The MySQL server
[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

# Don't listen on a TCP/IP port at all. This can be a security enhancement,
# if all processes that need to connect to mysqld run on the same host.
# All interaction with mysqld must be made via Unix sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
# 
#skip-networking

# Replication Master Server (default)
# binary logging is required for replication
log-bin=mysql-bin

# binary logging format - mixed recommended
binlog_format=mixed

# required unique id between 1 and 2^32 - 1
# defaults to 1 if master-host is not set
# but will not function as a master if omitted
server-id   = 1

#loose-innodb-trx=0 
#loose-innodb-locks=0 
#loose-innodb-lock-waits=0 
#loose-innodb-cmp=0 
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0 
#loose-innodb-cmpmem=0 
#loose-innodb-cmpmem-reset=0 
#loose-innodb-buffer-page=0 
#loose-innodb-buffer-page-lru=0 
#loose-innodb-buffer-pool-stats=0 
#loose-innodb-metrics=0 
#loose-innodb-ft-default-stopword=0 
#loose-innodb-ft-inserted=0 
#loose-innodb-ft-deleted=0 
#loose-innodb-ft-being-deleted=0 
#loose-innodb-ft-config=0 
#loose-innodb-ft-index-cache=0 
#loose-innodb-ft-index-table=0 
#loose-innodb-sys-tables=0 
#loose-innodb-sys-tablestats=0 
#loose-innodb-sys-indexes=0 
#loose-innodb-sys-columns=0 
#loose-innodb-sys-fields=0 
#loose-innodb-sys-foreign=0 
#loose-innodb-sys-foreign-cols=0

# Uncomment the following if you are using InnoDB tables
#innodb_data_home_dir = /usr/local/mysql/data
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = /usr/local/mysql/data
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
#innodb_buffer_pool_size = 16M
#innodb_additional_mem_pool_size = 2M
# Set .._log_file_size to 25 % of buffer pool size
#innodb_log_file_size = 5M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

    sed '/skip-external-locking/i\datadir = /usr/local/mysql/var' -i /etc/my.cnf
    if [ "${InstallInnodb}" = "y" ]; then
        sed -i 's:#innodb:innodb:g' /etc/my.cnf
        sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
    else
        sed -i '/skip-external-locking/i\innodb=OFF\nignore-builtin-innodb\nskip-innodb\ndefault-storage-engine=MyISAM\ndefault-tmp-storage-engine=MyISAM' /etc/my.cnf
        sed -i 's/#loose-innodb/loose-innodb/g' /etc/my.cnf
    fi

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig
}

StartAll()
{
    echo -e "\nexpire_logs_days = 10" >> /etc/my.cnf
    sed -i '/skip-external-locking/a\max_connections = 1000' /etc/my.cnf
    \cp ${cur_dir}/src/mysql-${mysql_version}/support-files/mysql.server /etc/init.d/mysql
    chmod 755 /etc/init.d/mysql

    ldconfig

    if [ -d "/proc/vz" ];then
        ulimit -s unlimited
    fi

    echo "Repair databases..."
    /usr/local/mysql/bin/mysql_upgrade -u root -p${mysql_root_password}

    ln -sf /usr/local/mysql/bin/mysql /usr/bin/mysql
    ln -sf /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
    ln -sf /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
    ln -sf /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

    lnmp start
    if [[ -s /usr/local/mysql/bin/mysql && -s /usr/local/mysql/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        Echo_Green "======== upgrade MySQL completed ======"
    else
        Echo_Red "======== upgrade MySQL failed ======"
        Echo_Red "upgrade MySQL log: /root/upgrade_mysql.log"
        echo "You upload upgrade_mysql.log to LNMP Forum for help."
    fi
}

Upgrade_MySQL()
{
    upgrade_date=$(date +"%Y%m%d")

    cur_mysql_version=`/usr/local/mysql/bin/mysql -V | awk '{print $5}' | tr -d ","`

    Check_DB
    if [ "${Is_MySQL}" = "n" ]; then
        Echo_Red "Current database was MariaDB, Can't run MySQL upgrade script."
    fi

    Verify_MySQL_Password

    mysql_version=""
    echo "Current MYSQL Version:${cur_mysql_version}"
    echo "You can get version number from http://dev.mysql.com/downloads/mysql/"
    echo "Please input MySQL Version you want."
    read -p "(example: 5.5.36 ): " mysql_version
    if [ "${mysql_version}" = "" ]; then
        echo "Error: You must input MySQL Version!!"
        exit 1
    fi

    if [ "${mysql_version}" == "${cur_mysql_version}" ]; then
        echo "Error: The upgrade MYSQL Version is the same as the old Version!!"
        exit 1
    fi

    #do you want to install the InnoDB Storage Engine?
    echo "==========================="

    installinnodb="y"
    echo "Do you want to install the InnoDB Storage Engine?"
    read -p "(Default yes,if you want please input: y ,if not please enter: n): " installinnodb

    case "${installinnodb}" in
    y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
    echo "You will install the InnoDB Storage Engine"
    installinnodb="y"
    ;;
    n|N|No|NO|no|nO)
    echo "You will NOT install the InnoDB Storage Engine!"
    installinnodb="n"
    ;;
    *)
    echo "No input,The InnoDB Storage Engine will enable."
    installinnodb="y"
    esac

    mysql_short_version=`echo ${mysql_version} | cut -d. -f1-2`

    echo "=================================================="
    echo "You want to upgrade MySQL Version to ${mysql_version}"
    echo "=================================================="

    Press_Start

    echo "============================check files=================================="
    cd ${cur_dir}/src
    if [ -s mysql-${mysql_version}.tar.gz ]; then
        echo "mysql-${mysql_version}.tar.gz [found]"
    else
        echo "Error: mysql-${mysql_version}.tar.gz not found!!!download now......"
        wget -c http://cdn.mysql.com/Downloads/MySQL-${mysql_short_version}/mysql-${mysql_version}.tar.gz
        if [ $? -eq 0 ]; then
            echo "Download mysql-${mysql_version}.tar.gz successfully!"
        else
            echo "You enter MySQL Version was:"${mysql_version}
            Echo_Red "Error! You entered a wrong version number, please check!"
            sleep 5
            exit 1
        fi
    fi
    echo "============================check files=================================="

    Backup_MySQL
    if [ "${mysql_short_version}" = "5.1" ]; then
        Upgrade_MySQL51
    elif [ "${mysql_short_version}" = "5.5" ]; then
        Upgrade_MySQL55
    elif [[ "${mysql_short_version}" = "5.6" || "${mysql_short_version}" = "5.7" ]]; then
        Upgrade_MySQL56
    fi
    StartAll
}
