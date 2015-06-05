#!/bin/bash

Verify_MariaDB_Password()
{
    read -p "verify your current MySQL root password:" mariadb_root_password
    /usr/local/mariadb/bin/mysql -uroot -p${mysql_root_password} -e "quit"
    if [ $? -eq 0 ]; then
        echo "MariaDB root password correct."
    else
        echo "MariaDB root password incorrect!Please check!"
        Verify_MySQL_Password
    fi
}

Backup_MariaDB()
{
    echo "Starting backup all databases..."
    echo "If the database is large, the backup time will be longer."
    /usr/local/mariadb/bin/mysqldump -uroot -p${mariadb_root_password} --all-databases > /root/mariadb_all_backup$(date +"%Y%m%d").sql
    if [ $? -eq 0 ]; then
        echo "MariaDB databases backup successfully.";
    else
        echo "MariaDB databases backup failed,Please backup databases manually!"
        exit 1
    fi
    lnmp stop

    mv /etc/init.d/mariadb /etc/init.d/mariadb.bak.${Upgrade_Date}
    mv /etc/my.cnf /etc/my.conf.mariadb.bak.${Upgrade_Date}
    cp -a /usr/local/mariadb /usr/local/oldmariadb${Upgrade_Date}
}

Upgrade_MariaDB()
{
    cur_mariadb_version=`/usr/local/mariadb/bin/mysql -V | awk '{print $5}' | tr -d "\-MariaDB,"`

    Check_DB
    if [ "${Is_MySQL}" = "y" ]; then
        Echo_Red "Current database was MySQL, Can't run MariaDB upgrade script."
    fi

    Verify_MariaDB_Password

    mariadb_version=""
    echo "Current MariaDB Version:${cur_mariadb_version}"
    echo "You can get version number from https://downloads.mariadb.org/"
    echo "Please enter MariaDB Version you want."
    read -p "(example: 10.0.15 ): " mariadb_version
    if [ "${mariadb_version}" = "" ]; then
        echo "Error: You must input MariaDB Version!!"
        exit 1
    fi

    #do you want to install the InnoDB Storage Engine?
    echo "==========================="

    installinnodb="y"
    echo "Do you want to install the InnoDB Storage Engine?"
    read -p "(Default yes,if you want please input: y ,if not please enter: n):" installinnodb

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

    echo "====================================================================="
    echo "You will upgrade MariaDB V${cur_mysql_version} to V${mariadb_version}"
    echo "====================================================================="

    Press_Start

    echo "============================check files=================================="
    cd ${cur_dir}/src
    if [ -s mariadb-${mariadb_version}.tar.gz ]; then
          echo "mariadb-${mariadb_version}.tar.gz [found]"
    else
            echo "Error: mariadb-${mariadb_version}.tar.gz not found!!!download now......"
            wget -c https://downloads.mariadb.org/interstitial/mariadb-${mariadb_version}/source/mariadb-${mariadb_version}.tar.gz
        if [ $? -eq 0 ]; then
            echo "Download mariadb-${mariadb_version}.tar.gz successfully!"
        else
            wget -c https://downloads.mariadb.org/interstitial/mariadb-${mariadb_version}/kvm-tarbake-jaunty-x86/mariadb-${mariadb_version}.tar.gz
            if [ $? -eq 0 ]; then
                echo "Download mariadb-${mariadb_version}.tar.gz successfully!"
            else
                echo "You enter MariaDB Version was:"${mariadb_version}
                Echo_Red "Error! You entered a wrong version number, please check!"
                sleep 5
                exit 1
            fi
        fi
    fi
    echo "============================check files=================================="

    Backup_MariaDB
    
    echo "Starting upgrade MariaDB..."
    Tar_Cd mariadb-${mariadb_version}.tar.gz mariadb-${mariadb_version}
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make && make install

    groupadd mariadb
    useradd -s /sbin/nologin -M -g mariadb mariadb

    \cp support-files/my-medium.cnf /etc/my.cnf
    sed '/skip-external-locking/i\pid-file = /usr/local/mariadb/var/mariadb.pid' -i /etc/my.cnf
    sed '/skip-external-locking/i\log_error = /usr/local/mariadb/var/mariadb.err' -i /etc/my.cnf
    sed '/skip-external-locking/i\basedir = /usr/local/mariadb' -i /etc/my.cnf
    sed '/skip-external-locking/i\datadir = /usr/local/mariadb/var' -i /etc/my.cnf
    sed '/skip-external-locking/i\user = mariadb' -i /etc/my.cnf
    if [ $installinnodb = "y" ]; then
    sed -i 's:#innodb:innodb:g' /etc/my.cnf
    sed -i 's:/usr/local/mariadb/data:/usr/local/mariadb/var:g' /etc/my.cnf
    else
    sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
    fi

    echo -e "\nexpire_logs_days = 10" >> /etc/my.cnf
    sed -i '/skip-external-locking/a\max_connections = 1000' /etc/my.cnf

cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
/usr/local/mariadb/lib
/usr/local/lib
EOF

    /usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=/usr/local/mariadb/var --user=mariadb
    chown -R mariadb /usr/local/mariadb/var
    chgrp -R mariadb /usr/local/mariadb/.
    cp support-files/mysql.server /etc/init.d/mariadb
    chmod 755 /etc/init.d/mariadb

    if [ -d "/proc/vz" ];then
        ulimit -s unlimited
    fi
    /etc/init.d/mariadb start

    /usr/local/mariadb/bin/mysqladmin -u root password $mysql_root_password

cat > /tmp/mariadb_sec_script<<EOF
use mysql;
update user set password=password('${mysql_root_password}') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

    /usr/local/mariadb/bin/mysql -u root -p${mysql_root_password} -h localhost < /tmp/mariadb_sec_script

    rm -f /tmp/mariadb_sec_script

    echo "import backup databases..."
    /usr/local/mariadb/bin/mysql -u root -p${mysql_root_password} < /root/mariadb_all_backup$(date +"%Y%m%d").sql
    [ $? -eq 0 ] && echo "MariaDB databases import successfully." || echo "MariaDB databases import failed,Please import databases manually!"

    echo "Repair databases..."
    /usr/local/mariadb/bin/mysql_upgrade -u root -p${mysql_root_password}

    ln -sf /usr/local/mariadb/bin/mysql /usr/bin/mysql
    ln -sf /usr/local/mariadb/bin/mysqldump /usr/bin/mysqldump
    ln -sf /usr/local/mariadb/bin/myisamchk /usr/bin/myisamchk
    ln -sf /usr/local/mariadb/bin/mysqld_safe /usr/bin/mysqld_safe

    echo "Stopping MariaDB..."
    /etc/init.d/mariadb stop

    sed -i 's#/etc/init.d/mysql#/etc/init.d/mariadb#g' /bin/lnmp

    lnmp start
    if [[ -s /usr/local/mariadb/bin/mysql && -s /usr/local/mariadb/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        Echo_Green "======== upgrade MariaDB completed ======"
    else
        Echo_Red "======== upgrade MariaDB failed ======"
        Echo_Red "upgrade MariaDB log: /root/upgrade_mariadb.log"
        echo "You upload upgrade_mariadb.log to LNMP Forum for help."
    fi
}
