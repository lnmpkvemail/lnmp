#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi
clear
printf "=========================================================================\n"
printf "Proftpd for LNMP V1.0  ,  Written by Licess \n"
printf "=========================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install Proftpd for lnmp \n"
printf "\n"
printf "For more information please visit http://www.lnmp.org \n"
printf "\n"
printf "Usage: ./proftpd.sh \n"
printf "=========================================================================\n"
cur_dir=$(pwd)


	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start install ProFTPd..."
	char=`get_char`

echo "Install building packages..."
cat /etc/issue | grep -Eqi '(Debian|Ubuntu)' && apt-get update;apt-get install build-essential gcc g++ make -y || yum -y install make gcc gcc-c++ gcc-g77

echo "Start download files..."
wget -c ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.4b.tar.gz
tar zxf proftpd-1.3.4b.tar.gz
cd proftpd-1.3.4b
./configure --prefix=/usr/local/proftpd
make && make install
cd ../

ln -s /usr/local/proftpd/sbin/proftpd /usr/local/bin/
ln -s /usr/local/proftpd/bin/ftpasswd /usr/local/bin/

mkdir /usr/local/proftpd/var/log/
mkdir /usr/local/proftpd/etc/vhost/

cat >/usr/local/proftpd/etc/proftpd.conf<<EOF
# This is a basic ProFTPD configuration file (rename it to
# 'proftpd.conf' for actual use.  It establishes a single server
# and a single anonymous login.  It assumes that you have a user/group
# "nobody" and "ftp" for normal operation and anon.

ServerName                      "ProFTPD FTP Server"
ServerType                      standalone
DefaultServer                   on

# Port 21 is the standard FTP port.
Port                            21

# Don't use IPv6 support by default.
UseIPv6                         off

# Umask 022 is a good standard umask to prevent new dirs and files
# from being group and world writable.
Umask                           022

# To prevent DoS attacks, set the maximum number of child processes
# to 30.  If you need to allow more than 30 concurrent connections
# at once, simply increase this value.  Note that this ONLY works
# in standalone mode, in inetd mode you should use an inetd server
# that allows you to limit maximum number of processes per service
# (such as xinetd).
MaxInstances                    30

# Set the user and group under which the server will run.
User                            nobody
Group                           nogroup

PassivePorts                    20000 30000
# To cause every FTP user to be "jailed" (chrooted) into their home
# directory, uncomment this line.


DefaultRoot ~

AllowOverwrite    on

AllowRetrieveRestart   on
AllowStoreRestart      on
UseReverseDNS off
IdentLookups off
#DisplayLogin welcome.msg
ServerIdent off
RequireValidShell off
AuthUserFile /usr/local/proftpd/etc/ftpd.passwd
AuthOrder mod_auth_file.c mod_auth_unix.c

# Normally, we want files to be overwriteable.
AllowOverwrite          on

# Bar use of SITE CHMOD by default
<Limit SITE_CHMOD>
  DenyAll
</Limit>
SystemLog     /usr/local/proftpd/var/log/proftpd.log
Include /usr/local/proftpd/etc/vhost/*.conf
EOF

wget -c http://soft.vpser.net/lnmp/ext/init.d.proftpd
cp init.d.proftpd /etc/init.d/proftpd
chmod +x /etc/init.d/proftpd

cat /etc/issue | grep -Eqi '(Debian|Ubuntu)' && update-rc.d -f proftpd defaults;ln -s /usr/sbin/nologin /sbin/nologin || chkconfig --level 345 proftpd on

if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 20 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 20000:30000 -j ACCEPT
/sbin/iptables-save
fi

cp proftpd_vhost.sh /root/proftpd_vhost.sh

clear
printf "=======================================================================\n"
printf "Starting proftpd...\n"
/etc/init.d/proftpd start
printf "=======================================================================\n"
printf "Install ProFTPd completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install ProFTPd for LNMP V1.0  ,  Written by Licess \n"
printf "=======================================================================\n"
printf "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install ProFTPd for lnmp \n"
printf "\n"
printf "For more information please visit http://www.lnmp.org \n"
printf "=======================================================================\n"
