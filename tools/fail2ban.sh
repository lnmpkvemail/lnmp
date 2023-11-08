#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

. ../lnmp.conf
. ../include/main.sh
Get_Dist_Name
Get_Dist_Version

Press_Start

if [ "${PM}" = "yum" ]; then
    for packages in python3 python3-setuptools python3-systemd iptables rsyslog;
    do yum install $packages -y; done
    service rsyslog restart
elif [ "${PM}" = "apt" ]; then
    apt-get update
    for packages in python3 python3-setuptools iptables rsyslog;
    do apt-get install -y $packages; done
    if command -v systemctl >/dev/null 2>&1; then
        systemctl restart rsyslog
    else
        /etc/init.d/rsyslog restart
    fi
fi

echo "Downloading..."
cd ../src
Download_Files ${Download_Mirror}/security/fail2ban/fail2ban-1.0.3.tar.gz fail2ban-1.0.3.tar.gz
tar zxf fail2ban-1.0.3.tar.gz && cd fail2ban-1.0.3
echo "Installing fail2ban..."
python3 setup.py install

echo "Copy configure file..."
\cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i '/^#mode   = normal/a \
enabled  = true\
filter   = sshd\
maxretry = 5\
bantime  = 604800' /etc/fail2ban/jail.local

echo "Copy init files..."
if [ ! -d /var/run/fail2ban ];then
    mkdir /var/run/fail2ban
fi
if [ `iptables -h|grep -c "\-w"` -eq 0 ]; then
    sed -i 's/lockingopt =.*/lockingopt =/g' /etc/fail2ban/action.d/iptables-common.conf
fi

\cp build/fail2ban.service /etc/systemd/system/fail2ban.service
if [ "${PM}" = "yum" ]; then
    \cp files/redhat-initd /etc/init.d/fail2ban
    sed -i 's#^before = paths-debian.conf#before = paths-fedora.conf#' /etc/fail2ban/jail.local
    sed -i 's/^Environment="PYTHONNOUSERSITE=1"/#Environment="PYTHONNOUSERSITE=1"/' /etc/systemd/system/fail2ban.service
    sed -i 's/-xf start/-x start/' /etc/systemd/system/fail2ban.service
elif [ "${PM}" = "apt" ]; then
    \cp files/debian-initd /etc/init.d/fail2ban
fi

chmod +x /etc/init.d/fail2ban
cd ..
rm -rf fail2ban-1.0.3

StartUp fail2ban

echo "Start fail2ban..."
/etc/init.d/fail2ban start