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
    yum install python rsyslog -y
    service rsyslog restart
elif [ "$PM" = "apt" ]; then
    apt-get update
    apt-get install python rsyslog -y
    /etc/init.d/rsyslog restart
    /etc/init.d/rsyslog restart
fi

echo "Downloading..."
cd ../src
Download_Files http://soft.vpser.net/security/denyhosts/DenyHosts-2.6.tar.gz DenyHosts-2.6.tar.gz
Tar_Cd DenyHosts-2.6.tar.gz DenyHosts-2.6
echo "Installing..."
python setup.py install

echo "Copy files..."
cd /usr/share/denyhosts/
cp denyhosts.cfg-dist denyhosts.cfg
cp daemon-control-dist daemon-control
chown root daemon-control
chmod 700 daemon-control
\cp /usr/share/denyhosts/daemon-control /etc/init.d/denyhosts

sed -i '/STATE_LOCK_EXISTS\ \=\ \-2/aif not os.path.exists("/var/lock/subsys"): os.makedirs("/var/lock/subsys")' /etc/init.d/denyhosts
if [ "$PM" = "apt" ]; then
    sed -i 's#/var/log/secure#/var/log/auth.log#g' /usr/share/denyhosts/denyhosts.cfg
    ln -sf /usr/local/bin/denyhosts.py /usr/bin/denyhosts.py
fi

StartUp denyhosts
echo "Start DenyHosts..."
/etc/init.d/denyhosts start