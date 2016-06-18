#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

. ../include/main.sh
Get_Dist_Name

Press_Start

if [ "$PM" = "yum" ]; then
    yum install python iptables rsyslog -y
    service rsyslog restart
elif [ "$PM" = "apt" ]; then
    apt-get update
    apt-get install python iptables rsyslog -y
    /etc/init.d/rsyslog restart
fi

echo "Downloading..."
cd ../src
Download_Files http://soft.vpser.net/security/fail2ban/fail2ban-0.9.1.tar.gz fail2ban-0.9.1.tar.gz
tar zxf fail2ban-0.9.1.tar.gz && cd fail2ban-0.9.1
echo "Installing..."
python setup.py install

echo "Copy configure file..."
\cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/# \[sshd\]/\[sshd\]/g' /etc/fail2ban/jail.local
sed -i 's/# enabled = true/enabled = true/g' /etc/fail2ban/jail.local

echo "Copy init files..."
mkdir /var/run/fail2ban
\cp ../../init.d/init.d.fail2ban /etc/init.d/fail2ban
if [ "$PM" = "yum" ]; then
    sed -i 's#%(sshd_log)s#/var/log/secure#g' /etc/fail2ban/jail.local
elif [ "$PM" = "apt" ]; then
    ln -sf /usr/local/bin/fail2ban-client /usr/bin/fail2ban-client
fi
chmod +x /etc/init.d/fail2ban

StartUp fail2ban

echo "Start fail2ban..."
/etc/init.d/fail2ban start