# LNMP One-Click Installer - English README

## Description of the LNMP one-click installation package

The LNMP one-click installer is a Linux kernel written for CentOS/RHEL/Fedora/Aliyun/Amazon, Debian/Ubuntu/Raspbian/Deepin/Mint Linux VPS, or a stand-alone host with LNMP (Nginx/MySQL/PHP), LNMPA (Nginx/MySQL/PHP/Apache) or LAMP (Apache/MySQL/PHP) production environment shell.

## Features of the LNMP one-click installation package

- Supports custom Nginx
- PHP compilation parameters
- Website and database directories
- Supports generation of LetsEncrypt certificates
- LNMP mode support for multiple PHP versions
- Support for separate installation of Nginx/MySQL/MariaDB/Pureftpd server
- Provides useful auxiliary tools such as:
  - Virtual host management
  - FTP user management
  - Nginx
  - MySQL/MariaDB
  - PHP upgrade
  - Installation of commonly used cache components Redis/Xcache
  - Reset MySQL root password
  - 502 automatic restart
  - Log cutting
  - SSH protection DenyHosts/Fail2Ban
  - Backup
  - Many other useful scripts

### Links

- [LNMP official website][lnmp]
- Author: [licess][licess]
- [Feedback & Technical Support Forum][support]
- [Reward Donation][donate]

## LNMP Installation

Before installing, make sure that the `wget` command is installed. If the command, `wget: command not found` is displayed, use `yum install wget` or `apt-get install wget` command to install it.

To prevent disconnection or other situations, it is recommended to use `screen`. You can execute `screen -S lnmp` command first and then execute the LNMP installation commands below:

```bash
$ wget http://soft.vpser.net/lnmp/lnmp1.5beta.tar.gz -cO lnmp1.5beta.tar.gz
$ tar zxf lnmp1.5beta.tar.gz
$ cd lnmp1.5
$ ./install.sh {lnmp|lnmpa|lamp} # select one of the three options e.g. ./install.sh lnmpa
```

If your connection gets broken, use `screen -r lnmp` to recover.

**A detailed installation tutorial [can be found here][install].**

## Description of Common Functions

**The following operations need to be performed in the lnmp installation package directory, such as lnmp1.5.**

### Custom Parameters

You can modify the `lnmp.conf` configuration file by adding a custom download server address, website / database directory and add `nginx` and `php` compiler parameters. Both the installation and upgrade will call the settings found in the `lnmp.conf` file. If you modify the default parameters we suggest you back this file up first before upgrading.

### FTP Server

Command to run: `./pureftpd.sh`
Installation can be managed by running `lnmp ftp {add|list|del}`.

### Upgrade Script

Command to run: `./upgrade.sh`
Follow the prompts to upgrade.

The command can also take any of these parameters:
`./upgrade.sh {nginx|mysql|mariadb|php|phpa|m2m|phpmyadmin}`

- `nginx` can be upgraded to any Nginx version.
- `mysql` can be upgraded to any MySQL version. The MySQL upgrade risk is relatively large. Even though the script will automatically back up the data, it is still recommended to back it up before running this.
- `mariadb` can upgrade the installed Mariadb. Even though the script will automatically back up the data, it is still recommended to back it up before running this.
- `m2m` can be upgraded from MySQL to Mariadb. Even though the script will automatically back up the data, it is still recommended to back it up before running this.
- `php` applies only to LNMP and can be upgraded to most PHP versions.
- `phpa` can upgrade LNMPA and LAMP to the most recent version of PHP.
- `phpmyadmin` upgrades the current version of phpMyadmin.

### Extensions

Command to run: 
`./addons.sh {install|uninstall} {eaccelerator|xcache|memcached|opcache|redis|apcu|imagemagick|ioncube}`

The following is the installation and usage instructions for the extension plug-in.

#### Cache Acceleration

- When `xcache` is installed, version and setting a password must be selected. Management can be performed at http://YOUR_IP_ADDRESS/xcache/. The default username is `admin` and the password is set when `xcache` is installed.
- `redis` install redis.
- `memcached` you can choose `php-memcache` or `php-memcached` extensions.
- `opcache` can be managed by visiting http://YOUR_IP_ADDRESS/ocp.php.
- `eaccelerator` installation.
- `apcu` let's you install apcu php extensions with support for php7. You can access http://YOUR_IP_ADDRESS/apc.php to manage the extension.

**Do not install more than one cache module as multiple installations may cause problems!**

#### Image Processing:

imageMagick install (or uninstall) command: `./addons.sh {install|uninstall} imageMagick`

The imageMagick path is: `/usr/local/imagemagick/bin/`.

#### Decryption:

IonCube install (or uninstall) command: `./addons.sh {install|uninstall} ionCube`.

#### Other Common Scripts

- Option 1: multiple PHP versions installation command: `./install.sh mphp` this will install multiple PHP versions. It only supports LNMP mode. lnmp vhost needs to be selected or used when you include the nginx virtual host configuration file. Replace `enable-php.conf` with `enable-php5.6.conf` to replace the previous 5.6 with the version 5.x or 7.0 of the PHP version you just installed.
- Option 2: database installation command: `./install.sh db` will install MySQL or MariaDB database.
- Option 3: Nginx installation command: `./install.sh nginx` will install Nginx directly.

**The following tools can be copied to other directories under the lnmp installation package's tools directory.**

- Option 4: command to execute: `./reset_mysql_root_password.sh` to reset the root password for MySQL/MariaDB.
- Option 5: command to execute: `./check502.sh` to detect if `php-fpm` hangs. Restart 502 when reporting an error. Use this script by setting up a `crontab` to check the status and restart if needed.
- Option 6: command to execute: `./cut_nginx_logs.sh` is a log cutting script.
- Option 7: command to execute: `./remove_disable_function.sh` run this script to remove the disable function.

### Automated Installation

**[Click here][auto_install] for the Automated Command Generation Tool.**

- Set the following environment variables to completely automate your installation.

| Variable Name    | Variable Value Description                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------ |
| LNMP_Auto        | Enable Automated Installation                                                                                |
| DBSelect         | Database Version Number                                                                                      |
| DB_Root_Password | Database root password (cannot be empty), do not add this parameter if the database is not installed         |
| InstallInnodb    | Whether to install Innodb engine (y or n) this parameter must not be added if the database is not installed  |
| PHPSelect        | PHP Version Number                                                                                           |
| SelectMalloc     | Memory Distributor Version Number                                                                            |
| ApacheSelect     | Apache version number, this parameter needs to be added if using LNMPA or LAMP mode                          |
| ServerAdmin      | Admin Email. This parameter needs to be added if using LNMPA or LAMP mode                                    |

- Corresponding serial number for each program (use these with the environment variables above)

| MySQL version               | Corresponding serial number | PHP version | Corresponding serial number | Memory distributor | Corresponding serial number | Apache version | Corresponding serial number |
| --------------------------- | --------------------------- | ----------- | --------------------------- | ------------------ | --------------------------- | -------------- | --------------------------- |
| MySQL 5.1                   | 1                           | PHP 5.2     | 1                           | Not Installed      | 1                           | Apache 2.2     | 1                           |
| MySQL 5.5                   | 2                           | PHP 5.3     | 2                           | Jemalloc           | 2                           | Apache 2.4     | 2                           |
| MySQL 5.6                   | 3                           | PHP 5.4     | 3                           | TCMalloc           | 3                           |                |                             |
| MySQL 5.7                   | 4                           | PHP 5.5     | 4                           |                    |                             |                |                             |
| MySQL 8.0                   | 5                           | PHP 5.6     | 5                           |                    |                             |                |                             |
| MariaDB 5.5                 | 6                           | PHP 7.0     | 6                           |                    |                             |                |                             |
| MariaDB 10.0                | 7                           | PHP 7.1     | 7                           |                    |                             |                |                             |
| MariaDB 10.1                | 8                           | PHP 7.2     | 8                           |                    |                             |                |                             |
| MariaDB 10.2                | 9                           |             |                             |                    |                             |                |                             |
| Do not install the database | 0                           |             |                             |                    |                             |                |                             |

In LNMP mode the default options are:

- Install MySQL 5.5
- MySQL root password set to lnmp.org
- InnoDB enabled
- PHP 5.6

Do not install the memory allocator, first execute [the first run screen][run_screen] and then download and unzip the lnmp installation package by running the following commands:

```bash
$ wget http://soft.vpser.net/lnmp/lnmp1.5beta.tar.gz -cO lnmp1.5beta.tar.gz
$ tar zxf lnmp1.5beta.tar.gz
$ cd lnmp1.5
```

Then set the automated installation parameters and run the install script:

```bash
LNMP_Auto="y" DBSelect="2" DB_Root_Password="lnmp.org"
InstallInnodb="y" PHPSelect="5" SelectMalloc="1"
$ ./install.sh lnmp
```

If there are any missing parameters (above) the script will prompt you, asking to complete any missing options.

### Uninstall

- Uninstall LNMP, LNMPA, or LAMP by executing the following command: `./uninstall.sh`
- Follow the prompts to uninstall.

## Status Management Commands

- LNMP/LNMPA/LMAP status management: `lnmp {start|stop|reload|restart|kill|status}`
- Nginx status management: `lnmp nginx or /etc/init.d/nginx {start|stop|reload|restart}`
- MySQL status management: `lnmp mysql or /etc/init.d/mysql {start|stop|restart|reload|force-reload|status}`
- MariaDB status management: `lnmp mariadb or /etc/init.d/mariadb {start|stop|restart|reload|force-reload|status}`
- PHP-FPM status management: `lnmp php-fpm or /etc/init.d/php-fpm {start|stop|quit|restart|reload|logrotate}`
- PureFTPd status management: `lnmp pureftpd or /etc/init.d/pureftpd {start|stop|restart|kill|status}`
- Apache status management: `lnmp httpd or /etc/init.d/httpd {start|stop|restart|graceful|graceful-stop|configtest|status}`

## Virtual Host Management

- Add: `lnmp vhost add`
- Delete: `lnmp vhost del`
- List: `lnmp vhost list`
- Database Management: `lnmp database {add|list|edit|del}`
- FTP user management: `lnmp ftp {add|list|edit|del|show}`
- Add SSL: `lnmp ssl add`

Wildcard or Universal domain name SSL addition command: `lnmp dnsssl {cx|ali|cf|dp|he|gd|aws}`
This command depends on the domain name dns api.

## Web-based Management Interfaces

- PHPMyAdmin: http://YOUR_IP_ADDRESS/phpmyadmin/
- phpinfo: http://YOUR_IP_ADDRESS/phpinfo.php
- PHP Probe: http://YOUR_IP_ADDRESS/p.php
- Xcache management interface: http://YOUR_IP_ADDRESS/xcache/
- Zend Opcache management interface: http://YOUR_IP_ADDRESS/ocp.php
- apcu management interface: http://YOUR_IP_ADDRESS/apc.php

## LNMP Related Catalog Files

### Directory Locations

- Nginx: `/usr/local/nginx/`
- MySQL: `/usr/local/mysql/`
- MariaDB: `/usr/local/mariadb/`
- PHP: `/usr/local/php/`
- Multiple PHP directories: `/usr/local/php5.6/`, the version number varies based on the installed version.
- PHP extensions configuration file directory: `/usr/local/php/conf.d/`
- PHPMyAdmin: `/home/wwwroot/default/phpmyadmin/`
- Default virtual host site directory: `/home/wwwroot/default/`
- Nginx log directory: `/home/wwwlogs/`

### Configuration Files

- Nginx main configuration file: `/usr/local/nginx/conf/nginx.conf`
- MySQL/MariaDB configuration file: `/etc/my.cnf`
- PHP configuration file: `/usr/local/php/etc/php.ini`
- PHP-FPM configuration file: `/usr/local/php/etc/php-fpm.conf`
- PureFtpd configuration file: `/usr/local/pureftpd/etc/pure-ftpd.conf`
- Apache configuration file: `/usr/local/apache/conf/httpd.conf`

### `lnmp.conf` Configuration File Parameter Descriptions

| Parameter Name        | Parameter Description                           | Example                                                                                            |
| --------------------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Download_Mirror       | Download image                                  | General default, [read here to modify the download mirror][download_image]                         |
| Nginx_Modules_Options | Add Nginx module or other compiler parameters   | `--add-module=/third-party` module source directory                                                |
| PHP_Modules_Options   | Adding PHP Modules or Compiler Parameters       | `--enable-exif` Some modules need to be installed ahead of time                                    |
| MySQL_Data_Dir        | MySQL Database Directory Settings               | Default `/usr/local/mysql/var`                                                                     |
| MariaDB_Data_Dir      | MariaDB Database Directory Settings             | Default `/usr/local/mariadb/var`                                                                   |
| Default_Website_Dir   | Default Web Hosting Site Directory Location     | Default `/home/wwwroot/default`                                                                    |
| Enable_Nginx_Openssl  | Whether to use the new version of openssl       | default `y`, it is recommended not to modify, `y` is enabled and open to http2                     |
| Enable_PHP_Fileinfo   | Whether or not to install php's fileinfo module | Default `n`, depending on your own situation, if the installation is enabled, change to `y`        |
| Enable_Nginx_Lua      | Whether to install lua support for Nginx        | ​​default `n`, install lua to use a lua-based waf website firewall                                   |

## Technical Support

**Technical Support Forum: [click here][support]**

[//]: # (Links below, found in the README file. Translated URLs have been included from Chinese to English.)

[run_screen]: https://translate.google.com/translate?hl=auto&sl=zh-CN&tl=en&u=https://www.vpser.net/manage/run-screen-lnmp.html
[lnmp]: https://translate.google.com/translate?hl=auto&sl=zh-CN&tl=en&u=https://lnmp.org
[licess]: mailto:admin@lnmp.org?subject=Github&nbsp;Contact
[support]: https://translate.google.com/translate?hl=auto&sl=zh-CN&tl=en&u=https://bbs.vpser.net/forum-25-1.html
[donate]: https://translate.google.com/translate?hl=auto&sl=zh-CN&tl=en&u=https://lnmp.org/donation.html
[install]: https://translate.google.com/translate?hl=auto&sl=zh-CN&tl=en&u=https://lnmp.org/install.html
[auto_install]: https://translate.google.com/translate?hl=auto&sl=zh-CN&tl=en&u=https://lnmp.org/auto.html
[download_image]: https://translate.google.com/translate?hl=auto&sl=zh-CN&tl=en&u=https://lnmp.org/faq/download-url.html
