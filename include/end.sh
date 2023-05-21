#!/usr/bin/env bash

Add_Iptables_Rules()
{
    #add iptables firewall rules
    if command -v iptables >/dev/null 2>&1; then
        iptables -I INPUT 1 -i lo -j ACCEPT
        iptables -I INPUT 2 -m state --state ESTABLISHED,RELATED -j ACCEPT
        iptables -I INPUT 3 -p tcp --dport 22 -j ACCEPT
        iptables -I INPUT 4 -p tcp --dport 80 -j ACCEPT
        iptables -I INPUT 5 -p tcp --dport 443 -j ACCEPT
        iptables -I INPUT 6 -p tcp --dport 3306 -j DROP
        iptables -I INPUT 7 -p icmp -m icmp --icmp-type 8 -j ACCEPT
        if [ "$PM" = "yum" ]; then
            yum -y install iptables-services
            service iptables save
            service iptables reload
            if command -v firewalld >/dev/null 2>&1; then
                systemctl stop firewalld
                systemctl disable firewalld
            fi
            StartUp iptables
        elif [ "$PM" = "apt" ]; then
            apt-get --no-install-recommends install -y iptables-persistent
            if [ -s /etc/init.d/netfilter-persistent ]; then
                /etc/init.d/netfilter-persistent save
                /etc/init.d/netfilter-persistent reload
                StartUp netfilter-persistent
            else
                /etc/init.d/iptables-persistent save
                /etc/init.d/iptables-persistent reload
                StartUp iptables-persistent
            fi
        fi
    fi
}

Add_LNMP_Startup()
{
    echo "Add Startup and Starting LNMP..."
    \cp ${cur_dir}/conf/lnmp /bin/lnmp
    chmod +x /bin/lnmp
    StartUp nginx
    StartOrStop start nginx
    if [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
        StartUp mariadb
        StartOrStop start mariadb
        sed -i 's#/etc/init.d/mysql#/etc/init.d/mariadb#' /bin/lnmp
    elif [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        StartUp mysql
        StartOrStop start mysql
    elif [ "${DBSelect}" = "0" ]; then
        sed -i 's#/etc/init.d/mysql.*##' /bin/lnmp
    fi
    StartUp php-fpm
    StartOrStop start php-fpm
    if [ "${PHPSelect}" = "1" ]; then
        sed -i 's#/usr/local/php/var/run/php-fpm.pid#/usr/local/php/logs/php-fpm.pid#' /bin/lnmp
    fi
}

Add_LNMPA_Startup()
{
    echo "Add Startup and Starting LNMPA..."
    \cp ${cur_dir}/conf/lnmpa /bin/lnmp
    chmod +x /bin/lnmp
    StartUp nginx
    StartOrStop start nginx
    if [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
        StartUp mariadb
        StartOrStop start mariadb
        sed -i 's#/etc/init.d/mysql#/etc/init.d/mariadb#' /bin/lnmp
    elif [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        StartUp mysql
        StartOrStop start mysql
    elif [ "${DBSelect}" = "0" ]; then
        sed -i 's#/etc/init.d/mysql.*##' /bin/lnmp
    fi
    StartUp httpd
    StartOrStop start httpd
}

Add_LAMP_Startup()
{
    echo "Add Startup and Starting LAMP..."
    \cp ${cur_dir}/conf/lamp /bin/lnmp
    chmod +x /bin/lnmp
    StartUp httpd
    StartOrStop start httpd
    if [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
        StartUp mariadb
        StartOrStop start mariadb
        sed -i 's#/etc/init.d/mysql#/etc/init.d/mariadb#' /bin/lnmp
    elif [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        StartUp mysql
        StartOrStop start mysql
    elif [ "${DBSelect}" = "0" ]; then
        sed -i 's#/etc/init.d/mysql.*##' /bin/lnmp
    fi
}

Check_Nginx_Files()
{
    isNginx=""
    echo "============================== Check install =============================="
    echo "Checking ..."
    if [[ -s /usr/local/nginx/conf/nginx.conf && -s /usr/local/nginx/sbin/nginx ]]; then
        Echo_Green "Nginx: OK"
        isNginx="ok"
    else
        Echo_Red "Error: Nginx install failed."
    fi
}

Check_DB_Files()
{
    isDB=""
    if [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
        if [[ -s /usr/local/mariadb/bin/mysql && -s /usr/local/mariadb/bin/mysqld_safe && -s /etc/my.cnf ]]; then
            Echo_Green "MariaDB: OK"
            isDB="ok"
        else
            Echo_Red "Error: MariaDB install failed."
        fi
    elif [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        if [[ -s /usr/local/mysql/bin/mysql && -s /usr/local/mysql/bin/mysqld_safe && -s /etc/my.cnf ]]; then
            Echo_Green "MySQL: OK"
            isDB="ok"
        else
            Echo_Red "Error: MySQL install failed."
        fi
    elif [ "${DBSelect}" = "0" ]; then
        Echo_Green "Do not install MySQL/MariaDB."
        isDB="ok"
    fi
}

Check_PHP_Files()
{
    isPHP=""
    if [ "${Stack}" = "lnmp" ]; then
        if [[ -s /usr/local/php/sbin/php-fpm && -s /usr/local/php/etc/php.ini && -s /usr/local/php/bin/php ]]; then
            Echo_Green "PHP: OK"
            Echo_Green "PHP-FPM: OK"
            isPHP="ok"
        else
            Echo_Red "Error: PHP install failed."
        fi
    else
        if [[ -s /usr/local/php/bin/php && -s /usr/local/php/etc/php.ini ]]; then
            Echo_Green "PHP: OK"
            isPHP="ok"
        else
            Echo_Red "Error: PHP install failed."
        fi
    fi
}

Check_Apache_Files()
{
    isApache=""
    if [[ "${PHPSelect}" =~ ^[6789]|10$ ]]; then
        if [[ -s /usr/local/apache/bin/httpd && -s /usr/local/apache/modules/libphp7.so && -s /usr/local/apache/conf/httpd.conf ]]; then
            Echo_Green "Apache: OK"
            isApache="ok"
        else
            Echo_Red "Error: Apache install failed."
        fi
    elif [[ "${PHPSelect}" =~ ^1[1-3]$ ]]; then
        if [[ -s /usr/local/apache/bin/httpd && -s /usr/local/apache/modules/libphp.so && -s /usr/local/apache/conf/httpd.conf ]]; then
            Echo_Green "Apache: OK"
            isApache="ok"
        else
            Echo_Red "Error: Apache install failed."
        fi
    else
        if [[ -s /usr/local/apache/bin/httpd && -s /usr/local/apache/modules/libphp5.so && -s /usr/local/apache/conf/httpd.conf ]]; then
            Echo_Green "Apache: OK"
            isApache="ok"
        else
            Echo_Red "Error: Apache install failed."
        fi
    fi
}

Clean_DB_Src_Dir()
{
    echo "Clean database src directory..."
    if [[ "${DBSelect}" =~ ^[12345]$ ]]; then
        rm -rf ${cur_dir}/src/${Mysql_Ver}
    elif [[ "${DBSelect}" =~ ^[6789]|10$ ]]; then
        rm -rf ${cur_dir}/src/${Mariadb_Ver}
    fi
    if [[ "${DBSelect}" = "4" ]]; then
        [[ -d "${cur_dir}/src/${Boost_Ver}" ]] && rm -rf ${cur_dir}/src/${Boost_Ver}
    elif [[ "${DBSelect}" = "5" ]]; then
        [[ -d "${cur_dir}/src/${Boost_New_Ver}" ]] && rm -rf ${cur_dir}/src/${Boost_New_Ver}
    fi
}

Clean_PHP_Src_Dir()
{
    echo "Clean PHP src directory..."
    rm -rf ${cur_dir}/src/${Php_Ver}
}

Clean_Web_Src_Dir()
{
    echo "Clean Web Server src directory..."
    if [ "${Stack}" = "lnmp" ]; then
        rm -rf ${cur_dir}/src/${Nginx_Ver}
    elif [ "${Stack}" = "lnmpa" ]; then
        rm -rf ${cur_dir}/src/${Nginx_Ver}
        rm -rf ${cur_dir}/src/${Apache_Ver}
    elif [ "${Stack}" = "lamp" ]; then
        rm -rf ${cur_dir}/src/${Apache_Ver}
    fi
    [[ -d "${cur_dir}/src/${Openssl_Ver}" ]] && rm -rf ${cur_dir}/src/${Openssl_Ver}
    [[ -d "${cur_dir}/src/${Openssl_New_Ver}" ]] && rm -rf ${cur_dir}/src/${Openssl_New_Ver}
    [[ -d "${cur_dir}/src/${Pcre_Ver}" ]] && rm -rf ${cur_dir}/src/${Pcre_Ver}
    [[ -d "${cur_dir}/src/${LuaNginxModule}" ]] && rm -rf ${cur_dir}/src/${LuaNginxModule}
    [[ -d "${cur_dir}/src/${NgxDevelKit}" ]] && rm -rf ${cur_dir}/src/${NgxDevelKit}
    [[ -d "${cur_dir}/src/${NgxFancyIndex_Ver}" ]] && rm -rf ${cur_dir}/src/${NgxFancyIndex_Ver}
}

Print_Sucess_Info()
{
    Clean_Web_Src_Dir
    echo "+------------------------------------------------------------------------+"
    echo "|          LNMP V${LNMP_Ver} for ${DISTRO} Linux Server, Written by Licess          |"
    echo "+------------------------------------------------------------------------+"
    echo "|           For more information please visit https://lnmp.org           |"
    echo "+------------------------------------------------------------------------+"
    echo "|    lnmp status manage: lnmp {start|stop|reload|restart|kill|status}    |"
    echo "+------------------------------------------------------------------------+"
    echo "|  phpMyAdmin: http://IP/phpmyadmin/                                     |"
    echo "|  phpinfo: http://IP/phpinfo.php                                        |"
    echo "|  Prober:  http://IP/p.php                                              |"
    echo "+------------------------------------------------------------------------+"
    echo "|  Add VirtualHost: lnmp vhost add                                       |"
    echo "+------------------------------------------------------------------------+"
    echo "|  Default directory: ${Default_Website_Dir}                              |"
    if [ "${DBSelect}" != "0" ]; then
        echo "+------------------------------------------------------------------------+"
        echo "|  MySQL/MariaDB root password: ${DB_Root_Password}                          |"
    fi
    echo "+------------------------------------------------------------------------+"
    lnmp status
    if command -v ss >/dev/null 2>&1; then
        ss -ntl
    else
        netstat -ntl
    fi
    stop_time=$(date +%s)
    echo "Install lnmp takes $(((stop_time-start_time)/60)) minutes."
    Echo_Green "Install lnmp V${LNMP_Ver} completed! enjoy it."
}

Print_Failed_Info()
{
    if [ -s /bin/lnmp ]; then
        rm -f /bin/lnmp
    fi
    Echo_Red "Sorry, Failed to install LNMP!"
    Echo_Red "Please visit https://bbs.vpser.net/forum-25-1.html feedback errors and logs."
    Echo_Red "You can download /root/lnmp-install.log from your server,and upload lnmp-install.log to LNMP Forum."
}

Check_LNMP_Install()
{
    Check_Nginx_Files
    Check_DB_Files
    Check_PHP_Files
    if [[ "${isNginx}" = "ok" && "${isDB}" = "ok" && "${isPHP}" = "ok" ]]; then
        Print_Sucess_Info
    else
        Print_Failed_Info
    fi
}

Check_LNMPA_Install()
{
    Check_Nginx_Files
    Check_DB_Files
    Check_PHP_Files
    Check_Apache_Files
    if [[ "${isNginx}" = "ok" && "${isDB}" = "ok" && "${isPHP}" = "ok"  &&"${isApache}" = "ok" ]]; then
        Print_Sucess_Info
    else
        Print_Failed_Info
    fi
}

Check_LAMP_Install()
{
    Check_Apache_Files
    Check_DB_Files
    Check_PHP_Files
    if [[ "${isApache}" = "ok" && "${isDB}" = "ok" && "${isPHP}" = "ok" ]]; then
        Print_Sucess_Info
    else
        Print_Failed_Info
    fi
}
