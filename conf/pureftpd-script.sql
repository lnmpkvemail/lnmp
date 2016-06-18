GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'ftp'@'localhost' IDENTIFIED BY  'Ftp_DB_Pwd';

FLUSH PRIVILEGES;

drop database if exists ftpusers;

CREATE DATABASE ftpusers;

USE ftpusers;

--
-- Table structure for table 'admin'
--

CREATE TABLE admin (
  Username varchar(35) NOT NULL default '',
  Password char(32) binary NOT NULL default '',
  PRIMARY KEY  (Username)
) ENGINE=MyISAM;

--
-- Data for table 'admin'
--


INSERT INTO admin VALUES ('Administrator',MD5('Ftp_Manager_Pwd'));

--
-- Table structure for table 'users'
--

CREATE TABLE `users` (
  `User` varchar(16) NOT NULL default '',
  `Password` varchar(32) binary NOT NULL default '',
  `Uid` int(11) NOT NULL default '14',
  `Gid` int(11) NOT NULL default '5',
  `Dir` varchar(128) NOT NULL default '',
  `QuotaFiles` int(10) NOT NULL default '500',
  `QuotaSize` int(10) NOT NULL default '30',
  `ULBandwidth` int(10) NOT NULL default '80',
  `DLBandwidth` int(10) NOT NULL default '80',
  `Ipaddress` varchar(15) NOT NULL default '*',
  `Comment` tinytext,
  `Status` enum('0','1') NOT NULL default '1',
  `ULRatio` smallint(5) NOT NULL default '1',
  `DLRatio` smallint(5) NOT NULL default '1',
  PRIMARY KEY  (`User`),
  UNIQUE KEY `User` (`User`)
) ENGINE=MyISAM;

--
-- Data for table 'users'
--


INSERT INTO ftpusers.users VALUES ('ftpuser_1',MD5('tmppasswd'),65534, 31, '/usr', 100, 50, 75, 75, '*', 'Ftp user (for example)', '0', 0, 0);