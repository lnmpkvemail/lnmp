#!/bin/bash

Mariadb_Sec_Setting()
{
    cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
    /usr/local/mariadb/lib
    /usr/local/lib
EOF
    ldconfig

    if [ -d "/proc/vz" ];then
    ulimit -s unlimited
    fi
    /etc/init.d/mariadb start

    ln -s /usr/local/mariadb/bin/mysql /usr/bin/mysql
    ln -s /usr/local/mariadb/bin/mysqldump /usr/bin/mysqldump
    ln -s /usr/local/mariadb/bin/myisamchk /usr/bin/myisamchk
    ln -s /usr/local/mariadb/bin/mysqld_safe /usr/bin/mysqld_safe

    /usr/local/mariadb/bin/mysqladmin -u root password ${MysqlRootPWD}

    cat > /tmp/mariadb_sec_script<<EOF
    use mysql;
    update user set password=password('${MysqlRootPWD}') where user='root';
    delete from user where not (user='root') ;
    delete from user where user='root' and password=''; 
    drop database test;
    DROP USER ''@'%';
    flush privileges;
EOF

    /usr/local/mariadb/bin/mysql -u root -p${MysqlRootPWD} -h localhost < /tmp/mariadb_sec_script

    rm -f /tmp/mariadb_sec_script

    echo -e "\nexpire_logs_days = 10" >> /etc/my.cnf
    sed -i '/skip-external-locking/a\max_connections = 1000' /etc/my.cnf

    /etc/init.d/mariadb restart
    /etc/init.d/mariadb stop
}

Install_MariaDB_5()
{
    Echo_Blue "[+] Installing ${Mariadb_Ver}..."
    rm -f /etc/my.cnf
    Tar_Cd ${Mariadb_Ver}.tar.gz ${Mariadb_Ver}
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DSYSCONFDIR=/etc -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 ${MariaDBMAOpt}
    make && make install

    groupadd mariadb
    useradd -s /sbin/nologin -M -g mariadb mariadb

    \cp support-files/my-medium.cnf /etc/my.cnf
    sed '/skip-external-locking/i\pid-file = /usr/local/mariadb/var/mariadb.pid' -i /etc/my.cnf
    sed '/skip-external-locking/i\log_error = /usr/local/mariadb/var/mariadb.err' -i /etc/my.cnf
    sed '/skip-external-locking/i\basedir = /usr/local/mariadb' -i /etc/my.cnf
    sed '/skip-external-locking/i\datadir = /usr/local/mariadb/var' -i /etc/my.cnf
    sed '/skip-external-locking/i\user = mariadb' -i /etc/my.cnf
    if [ "${InstallInnodb}" = "y" ]; then
    sed -i 's:#innodb:innodb:g' /etc/my.cnf
    sed -i 's:/usr/local/mariadb/data:/usr/local/mariadb/var:g' /etc/my.cnf
    else
    sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
    fi

    /usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=/usr/local/mariadb/var --user=mariadb
    chown -R mariadb /usr/local/mariadb/var
    chgrp -R mariadb /usr/local/mariadb/.
    \cp support-files/mysql.server /etc/init.d/mariadb
    chmod 755 /etc/init.d/mariadb

    Mariadb_Sec_Setting
}

Install_MariaDB_10()
{
    Echo_Blue "[+] Installing ${Mariadb_Ver}..."
    rm -f /etc/my.cnf
    Tar_Cd ${Mariadb_Ver}.tar.gz ${Mariadb_Ver}
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DSYSCONFDIR=/etc -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 ${MariaDBMAOpt}
    make && make install

    groupadd mariadb
    useradd -s /sbin/nologin -M -g mariadb mariadb

    \cp support-files/my-medium.cnf /etc/my.cnf
    sed '/skip-external-locking/i\pid-file = /usr/local/mariadb/var/mariadb.pid' -i /etc/my.cnf
    sed '/skip-external-locking/i\log_error = /usr/local/mariadb/var/mariadb.err' -i /etc/my.cnf
    sed '/skip-external-locking/i\basedir = /usr/local/mariadb' -i /etc/my.cnf
    sed '/skip-external-locking/i\datadir = /usr/local/mariadb/var' -i /etc/my.cnf
    sed '/skip-external-locking/i\user = mariadb' -i /etc/my.cnf
    if [ "${InstallInnodb}" = "y" ]; then
    sed -i 's:#innodb:innodb:g' /etc/my.cnf
    sed -i 's:/usr/local/mariadb/data:/usr/local/mariadb/var:g' /etc/my.cnf
    else
    sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
    fi

    /usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=/usr/local/mariadb/var --user=mariadb
    chown -R mariadb /usr/local/mariadb/var
    chgrp -R mariadb /usr/local/mariadb/.
    \cp support-files/mysql.server /etc/init.d/mariadb
    chmod 755 /etc/init.d/mariadb

    Mariadb_Sec_Setting
}