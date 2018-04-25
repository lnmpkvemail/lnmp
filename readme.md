# LNMP一键安装包 - Readme

## LNMP一键安装包是什么?

LNMP一键安装包是一个用Linux Shell编写的可以为CentOS/RHEL/Fedora/Aliyun/Amazon、Debian/Ubuntu/Raspbian/Deepin/Mint Linux VPS或独立主机安装LNMP(Nginx/MySQL/PHP)、LNMPA(Nginx/MySQL/PHP/Apache)、LAMP(Apache/MySQL/PHP)生产环境的Shell程序。

## LNMP一键安装包有哪些功能？

支持自定义Nginx、PHP编译参数及网站和数据库目录、支持生成LetseEcrypt证书、LNMP模式支持多PHP版本、支持单独安装Nginx/MySQL/MariaDB/Pureftpd服务器，同时提供一些实用的辅助工具如：虚拟主机管理、FTP用户管理、Nginx、MySQL/MariaDB、PHP的升级、常用缓存组件Redis/Xcache等的安装、重置MySQL root密码、502自动重启、日志切割、SSH防护DenyHosts/Fail2Ban、备份等许多实用脚本。

* LNMP官网：<https://lnmp.org>
* 作者: licess <admin@lnmp.org>
* 问题反馈&技术支持论坛：<https://bbs.vpser.net/forum-25-1.html>
* 打赏捐赠：<https://lnmp.org/donation.html>

## LNMP安装

安装前确认已经安装wget命令，如提示wget: command not found ，使用`yum install wget` 或 `apt-get install wget` 命令安装。
为防止掉线等情况，建议使用screen，可以先执行：screen -S lnmp 命令后，再执行LNMP安装命令：
`wget http://soft.vpser.net/lnmp/lnmp1.5beta.tar.gz -cO lnmp1.5beta.tar.gz && tar zxf lnmp1.5beta.tar.gz && cd lnmp1.5 && ./install.sh {lnmp|lnmpa|lamp}`

如断线可使用`screen -r lnmp` 恢复。**详细安装教程参考：<https://lnmp.org/install.html>**

## 常用功能说明

**以下操作需在lnmp安装包目录下执行，如lnmp1.5**

### 自定义参数
lnmp.conf配置文件，可以修改lnmp.conf自定义下载服务器地址、网站/数据库目录及添加nginx模块和php编译参数；不论安装升级都会调用该文件里的设置(如果修改了默认的参数建议备份此文件)；

### FTP服务器
执行：`./pureftpd.sh` 安装，可使用 `lnmp ftp {add|list|del}` 进行管理。

### 升级脚本：
执行：`./upgrade.sh` 按提示进行选择
也可以直接带参数：`./upgrade.sh {nginx|mysql|mariadb|php|phpa|m2m|phpmyadmin}`
* 参数: nginx 可升级至任意Nginx版本。
* 参数: mysql 可升级至任意MySQL版本，MySQL升级风险较大，虽然会自动备份数据，依然建议自行再备份一下。
* 参数: mariadb 可升级已安装的Mariadb，虽然会自动备份数据，依然建议自行再备份一下。
* 参数: m2m    可从MySQL升级至Mariadb，虽然会自动备份数据，依然建议自行再备份一下。
* 参数: php   仅适用于LNMP，可升级至大部分PHP版本。
* 参数: phpa    可升级LNMPA/LAMP的PHP至大部分版本。
* 参数: phpmyadmin    可升级phpMyadmin。

### 扩展插件
执行: `./addons.sh {install|uninstall} {eaccelerator|xcache|memcached|opcache|redis|apcu|imagemagick|ioncube}`
以下为扩展插件安装使用说明
#### 缓存加速：
* 参数: xcache 安装时需选择版本和设置密码，http://yourIP/xcache/ 进行管理，用户名 admin，密码为安装xcache时设置的。
* 参数: redis  安装redis
* 参数: memcached 可选择php-memcache或php-memcached扩展。
* 参数: opcache 可访问 http://yourIP/ocp.php 进行管理。
* 参数: eaccelerator 安装。
* 参数: apcu 安装apcu php扩展，支持php7，可访问 http://yourIP/apc.php 进行管理。 
**请勿安装多个缓存类扩展模块，多个可能导致网站出现问题 ！**

#### 图像处理：
* imageMagick安装卸载执行：`./addons.sh {install|uninstall} imageMagick` imageMagick路径：/usr/local/imagemagick/bin/。

#### 解密：
* IonCube安装执行：`./addons.sh {install|uninstall} ionCube`。

#### 其他常用脚本：
* 可选1，多PHP版本安装执行：`./install.sh mphp` 可以安装多个PHP版本 ，只支持LNMP模式，lnmp vhost add时进行选择或使用时需要将nginx虚拟主机配置文件里的include enable-php.conf替换为 include enable-php5.6.conf 即可前面的5.6换成你刚才安装的PHP的大版本号5.* 或7.0之类的。
* 可选2，数据库安装执行：`./install.sh db` 可以直接单独安装MySQL或MariaDB数据库。
* 可选3，Nginx安装执行：`./install.sh nginx`可以直接单独安装Nginx。
**以下工具在lnmp安装包tools目录下**可拷贝到其他目录下运行
* 可选4，执行：`./reset_mysql_root_password.sh` 可重置MySQL/MariaDB的root密码。
* 可选5，执行：`./check502.sh`  可检测php-fpm是否挂掉,502报错时重启，配合crontab使用。
* 可选6，执行：`./cut_nginx_logs.sh` 日志切割脚本。
* 可选7，执行：`./remove_disable_function.sh` 运行此脚本可删掉禁用函数。

### 无人值守安装

**无人值守命令生成工具：<https://lnmp.org/auto.html>**
* 设置如下环境变量即可完全无人值守安装

变量名 | 变量值含义
--- | ---
LNMP_Auto | 启用无人值守自动安装
DBSelect | 数据库版本序号
DB_Root_Password | 数据库root密码（不可为空），不安装数据库时可不加该参数
InstallInnodb | 是否安装Innodb引擎，y 或 n ，不安装数据库时可不加该参数
PHPSelect | PHP版本序号
SelectMalloc | 内存分配器版本序号
ApacheSelect | Apache版本序号，仅LNMPA和LAMP模式需添加该参数
ServerAdmin | 管理员邮箱，仅LNMPA和LAMP模式需添加该参数

* 各程序版本对应序号

MySQL版本 | 对应序号 | PHP版本 | 对应序号 | 内存分配器 | 对应序号 | Apache版本 | 对应序号
:------: | :------: | :------: | :------: | :------: | :--------: | :--------: | :--------:
MySQL 5.1 | 1 | PHP 5.2 | 1 | 不安装 | 1 | Apache 2.2 | 1
MySQL 5.5 | 2 | PHP 5.3 | 2 | Jemalloc | 2 | Apache 2.4 | 2
MySQL 5.6 | 3 | PHP 5.4 | 3 | TCMalloc | 3 | |
MySQL 5.7 | 4 | PHP 5.5 | 4 | | | |
MySQL 8.0 | 5 | PHP 5.6 | 5 | | | |
MariaDB 5.5 | 6 | PHP 7.0 | 6 | | | |
MariaDB 10.0 | 7 | PHP 7.1 | 7 | | | |
MariaDB 10.1 | 8 | PHP 7.2 | 8 | | | |
MariaDB 10.2 | 9 | | | | | |
不安装数据库 | 0 | | | | | |

* 以LNMP模式，默认选项安装MySQL 5.5、MySQL root密码设置为lnmp.org、启用InnoDB、PHP 5.6、不安装内存分配器为例，先执行([建议先运行screen](https://www.vpser.net/manage/run-screen-lnmp.html))，再下载解压lnmp安装包：

`wget http://soft.vpser.net/lnmp/lnmp1.5beta.tar.gz -cO lnmp1.5beta.tar.gz && tar zxf lnmp1.5beta.tar.gz && cd lnmp1.5`

然后设置无人值守参数并安装：

`LNMP_Auto="y" DBSelect="2" DB_Root_Password="lnmp.org" InstallInnodb="y" PHPSelect="5" SelectMalloc="1" ./install.sh lnmp`

(如果缺失参数的话还是会有要求选择缺失选项的提示)。

### 卸载
* 卸载LNMP、LNMPA或LAMP可执行：`./uninstall.sh` 按提示选择即可卸载。

## 状态管理
* LNMP/LNMPA/LMAP状态管理：`lnmp {start|stop|reload|restart|kill|status}`
* Nginx状态管理：`lnmp nginx或/etc/init.d/nginx {start|stop|reload|restart}`
* MySQL状态管理：`lnmp mysql或/etc/init.d/mysql {start|stop|restart|reload|force-reload|status}`
* MariaDB状态管理：`lnmp mariadb或/etc/init.d/mariadb {start|stop|restart|reload|force-reload|status}`
* PHP-FPM状态管理：`lnmp php-fpm或/etc/init.d/php-fpm {start|stop|quit|restart|reload|logrotate}`
* PureFTPd状态管理：`lnmp pureftpd或/etc/init.d/pureftpd {start|stop|restart|kill|status}`
* Apache状态管理：`lnmp httpd或/etc/init.d/httpd {start|stop|restart|graceful|graceful-stop|configtest|status}`

## 虚拟主机管理
* 添加：`lnmp vhost add`
* 删除：`lnmp vhost del`
* 列出：`lnmp vhost list`
* 数据库管理：`lnmp database {add|list|edit|del}`
* FTP用户管理：`lnmp ftp {add|list|edit|del|show}`
* SSL添加：`lnmp ssl add`
* 通配符/泛域名SSL添加：`lnmp dnsssl {cx|ali|cf|dp|he|gd|aws}` 需依赖域名dns api

## 相关图形界面
* PHPMyAdmin：http://yourIP/phpmyadmin/
* phpinfo：http://yourIP/phpinfo.php
* PHP探针：http://yourIP/p.php
* Xcache管理界面：http://yourIP/xcache/
* Zend Opcache管理界面：http://yourIP/ocp.php
* apcu管理界面：http://yourIP/apc.php

## LNMP相关目录文件

### 目录位置
* Nginx：/usr/local/nginx/
* MySQL：/usr/local/mysql/
* MariaDB：/usr/local/mariadb/
* PHP：/usr/local/php/
* 多PHP目录：/usr/local/php5.6/ 版本号随安装版本不同而不同
* PHP扩展插件配置文件目录：/usr/local/php/conf.d/
* PHPMyAdmin：/home/wwwroot/default/phpmyadmin/
* 默认虚拟主机网站目录：/home/wwwroot/default/
* Nginx日志目录：/home/wwwlogs/

### 配置文件：
* Nginx主配置文件：/usr/local/nginx/conf/nginx.conf
* MySQL/MariaDB配置文件：/etc/my.cnf
* PHP配置文件：/usr/local/php/etc/php.ini
* PHP-FPM配置文件：/usr/local/php/etc/php-fpm.conf
* PureFtpd配置文件：/usr/local/pureftpd/etc/pure-ftpd.conf
* Apache配置文件：/usr/local/apache/conf/httpd.conf

### lnmp.conf 配置文件参数说明

| 参数名称 | 参数介绍 | 例子 |
| :-------: | :---------: | :--------: | 
|Download_Mirror|下载镜像|一般默认，如异常可[修改下载镜像](https://lnmp.org/faq/download-url.html)|
|Nginx_Modules_Options|添加Nginx模块或其他编译参数|--add-module=/第三方模块源码目录|
|PHP_Modules_Options|添加PHP模块或编译参数|--enable-exif 有些模块需提前安装好依赖包|
|MySQL_Data_Dir|MySQL数据库目录设置|默认/usr/local/mysql/var|
|MariaDB_Data_Dir|MariaDB数据库目录设置|默认/usr/local/mariadb/var|
|Default_Website_Dir|默认虚拟主机网站目录位置|默认/home/wwwroot/default|
|Enable_Nginx_Openssl|Nginx是否使用新版openssl|默认 y，建议不修改，y是启用并开启到http2|
|Enable_PHP_Fileinfo|是否安装开启php的fileinfo模块|默认n，根据自己情况而定，安装启用的话改成 y|
|Enable_Nginx_Lua|是否为Nginx安装lua支持|默认n，安装lua可以使用一些基于lua的waf网站防火墙|

## 技术支持

**技术支持论坛：<https://bbs.vpser.net/forum-25-1.html>**
