#!/bin/bash

Deb_Check_MySQL()
{
    apt-get purge -y mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5
    rm -f /etc/my.cnf
    rm -rf /etc/mysql/
}

MySQL_ARM_Patch()
{
    Get_ARM
    if [ "${Is_ARM}" = "y" ]; then
        patch -p1 < ${cur_dir}/src/patch/mysql-5.5-fix-arm-client_plugin.patch
    fi
}

MySQL_Sec_Setting()
{
    if [ -d "/proc/vz" ];then
        ulimit -s unlimited
    fi
    /etc/init.d/mysql start

    ln -sf /usr/local/mysql/bin/mysql /usr/bin/mysql
    ln -sf /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
    ln -sf /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
    ln -sf /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

    /usr/local/mysql/bin/mysqladmin -u root password ${MysqlRootPWD}

    cat > /tmp/mysql_sec_script<<EOF
    use mysql;
    update user set password=password('${MysqlRootPWD}') where user='root';
    delete from user where not (user='root') ;
    delete from user where user='root' and password=''; 
    drop database test;
    DROP USER ''@'%';
    flush privileges;
EOF

    /usr/local/mysql/bin/mysql -u root -p${MysqlRootPWD} -h localhost < /tmp/mysql_sec_script

    rm -f /tmp/mysql_sec_script

    echo -e "\nexpire_logs_days = 10" >> /etc/my.cnf
    sed -i '/skip-external-locking/a\max_connections = 1000' /etc/my.cnf

    /etc/init.d/mysql restart
    /etc/init.d/mysql stop
}

Install_MySQL_51()
{
    Echo_Blue "[+] Installing ${Mysql_Ver}..."
    rm -f /etc/my.cnf
    Tar_Cd ${Mysql_Ver}.tar.gz ${Mysql_Ver}
    if [ "${InstallInnodb}" = "y" ]; then
        ./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=innobase ${MySQL51MAOpt}
    else
        ./configure --prefix=/usr/local/mysql --with-extra-charsets=complex --enable-thread-safe-client --enable-assembler --with-mysqld-ldflags=-all-static --with-charset=utf8 --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile ${MySQL51MAOpt}
    fi
    sed -i '/set -ex;/,/done/d' Makefile
    make && make install
    cd ../

    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql

    \cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
    sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
    if [ "${InstallInnodb}" = "y" ]; then
    sed -i 's:#innodb:innodb:g' /etc/my.cnf
    fi
    /usr/local/mysql/bin/mysql_install_db --user=mysql
    chown -R mysql /usr/local/mysql/var
    chgrp -R mysql /usr/local/mysql/.
    \cp /usr/local/mysql/share/mysql/mysql.server /etc/init.d/mysql
    chmod 755 /etc/init.d/mysql

    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    /usr/local/mysql/lib/mysql
    /usr/local/lib
EOF
    ldconfig

    ln -sf /usr/local/mysql/lib/mysql /usr/lib/mysql
    ln -sf /usr/local/mysql/include/mysql /usr/include/mysql

    MySQL_Sec_Setting
}

Install_MySQL_55()
{
    Echo_Blue "[+] Installing ${Mysql_Ver}..."
    rm -f /etc/my.cnf
    Tar_Cd ${Mysql_Ver}.tar.gz ${Mysql_Ver}
    patch -p1 < ${cur_dir}/src/patch/mysql-openssl.patch
    MySQL_ARM_Patch
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 ${MySQL55MAOpt}
    make && make install

    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql

    \cp support-files/my-medium.cnf /etc/my.cnf
    sed '/skip-external-locking/i\datadir = /usr/local/mysql/var' -i /etc/my.cnf
    if [ "${InstallInnodb}" = "y" ]; then
    sed -i 's:#innodb:innodb:g' /etc/my.cnf
    sed -i 's:/usr/local/mysql/data:/usr/local/mysql/var:g' /etc/my.cnf
    else
    sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
    fi

    /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/var --user=mysql
    chown -R mysql /usr/local/mysql/var
    chgrp -R mysql /usr/local/mysql/.
    \cp support-files/mysql.server /etc/init.d/mysql
    chmod 755 /etc/init.d/mysql

    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    /usr/local/mysql/lib
    /usr/local/lib
EOF
    ldconfig
    ln -sf /usr/local/mysql/lib/mysql /usr/lib/mysql
    ln -sf /usr/local/mysql/include/mysql /usr/include/mysql

    MySQL_Sec_Setting
}

Install_MySQL_56()
{
    Echo_Blue "[+] Installing ${Mysql_Ver}..."
    rm -f /etc/my.cnf
    Tar_Cd ${Mysql_Ver}.tar.gz ${Mysql_Ver}
    patch -p1 < ${cur_dir}/src/patch/mysql-openssl.patch
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 ${MySQL55MAOpt}
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

    /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/var --user=mysql
    chown -R mysql /usr/local/mysql/var
    chgrp -R mysql /usr/local/mysql/.
    \cp support-files/mysql.server /etc/init.d/mysql
    chmod 755 /etc/init.d/mysql

    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    /usr/local/mysql/lib
    /usr/local/lib
EOF
    ldconfig
    ln -sf /usr/local/mysql/lib/mysql /usr/lib/mysql
    ln -sf /usr/local/mysql/include/mysql /usr/include/mysql

    MySQL_Sec_Setting
}