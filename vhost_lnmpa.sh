#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Add Virtual Host for LNMPA,  Written by Licess "
echo "========================================================================="
echo "LNMP is a tool to auto-compile & install Nginx+MySQL+PHP+Apache on Linux "
echo "This script is a tool to add virtual host for Nginx And Apache "
echo "For more information please visit http://www.lnmp.org/"
echo ""
echo "========================================================================="

if [ "$1" != "--help" ]; then

	domain="www.lnmp.org"
	read -p "Please input domain:" domain
	if [ "$domain" = "" ]; then
		echo "Error: Domain Name Can't be empty!!"
		exit 1
	fi
	if [ ! -f "/usr/local/nginx/conf/vhost/$domain.conf" ]; then
	echo "==========================="
	echo "domain=$domain"
	echo "===========================" 
	else
	echo "==========================="
	echo "$domain is exist!"
	echo "==========================="	
	fi
	
	echo "Do you want to add more domain name? (y/n)"
	read add_more_domainame

	if [ "$add_more_domainame" == 'y' ]; then

	  echo "Type domainname,example(bbs.vpser.net forums.vpser.net luntan.vpser.net):"
	  read moredomain
          echo "==========================="
          echo domain list="$moredomain"
          echo "==========================="
	  moredomainame=" $moredomain"
	fi

	vhostdir="/home/wwwroot/$domain"
	echo "Please input the directory for the domain:$domain :"
	read -p "(Default directory: /home/wwwroot/$domain):" vhostdir
	if [ "$vhostdir" = "" ]; then
		vhostdir="/home/wwwroot/$domain"
	fi
	echo "==========================="
	echo Virtual Host Directory="$vhostdir"
	echo "==========================="

#set Server Administrator Email Address

	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi

	echo "==========================="
	echo "Allow access_log? (y/n)"
	echo "==========================="
	read access_log

	if [ "$access_log" == 'n' ]; then
	  al="access_log off;"
	else
	  echo "Type access_log name(Default access log file:$domain.log):"
	  read al_name
	  if [ "$al_name" = "" ]; then
		al_name="$domain"
	  fi
	  al="access_log  /home/wwwlogs/$al_name.log  access;"
	echo "==========================="
	echo You access log file="$al_name.log"
	echo "==========================="
	fi

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
	echo "Press any key to start create virtul host..."
	char=`get_char`


if [ ! -d /usr/local/nginx/conf/vhost ]; then
	mkdir /usr/local/nginx/conf/vhost
fi

echo "Create Virtul Host directory......"
mkdir -p $vhostdir
touch /home/wwwlogs/$al_name.log
echo "set permissions of Virtual Host directory......"
chmod -R 755 $vhostdir
chown -R www:www $vhostdir

cat >/usr/local/nginx/conf/vhost/$domain.conf<<eof
server
	{
		listen 80;
		#listen [::]:80;
		server_name $domain$moredomainame;
		index index.html index.htm index.php default.html default.htm default.php;
		root  $vhostdir;

		location / {
			try_files \$uri @apache;
			}

		location @apache {
			internal;
			proxy_pass http://127.0.0.1:88;
			include proxy.conf;
			}

		location ~ [^/]\.php(/|$)
			{
				proxy_pass http://127.0.0.1:88;
				include proxy.conf;
			}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		$al
	}
eof

cat >/usr/local/apache/conf/vhost/$domain.conf<<eof
<VirtualHost *:88>
ServerAdmin webmaster@example.com
php_admin_value open_basedir "$vhostdir:/tmp/:/var/tmp/:/proc/"
DocumentRoot "$vhostdir"
ServerName $domain
ErrorLog "logs/$al_name-error_log"
CustomLog "logs/$al_name-access_log" common
</VirtualHost>
eof

if [ "$access_log" == 'n' ]; then
sed -i 's/ErrorLog/#ErrorLog/g' /usr/local/apache/conf/vhost/$domain.conf
sed -i 's/CustomLog/#CustomLog/g' /usr/local/apache/conf/vhost/$domain.conf
fi

if [ "$add_more_domainame" == 'y' ]; then
sed -i "/ServerName/a\
ServerAlias $moredomainame" /usr/local/apache/conf/vhost/$domain.conf
fi

echo "Test Nginx configure file......"
/usr/local/nginx/sbin/nginx -t
echo ""
echo "Restart Nginx......"
/usr/local/nginx/sbin/nginx -s reload
echo "Restart Apache......"
/etc/init.d/httpd restart

echo "========================================================================="
echo "Add Virtual Host for LNMP,  Written by Licess "
echo "========================================================================="
echo "For more information please visit http://www.lnmp.org/"
echo ""
echo "Your domain:$domain $moredomainame"
echo "Directory of $domain:$vhostdir"
echo ""
echo "========================================================================="
fi