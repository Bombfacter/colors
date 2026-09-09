-- COP4331 COLORS app database
-- Lab 2: schema + seed data

CREATE DATABASE IF NOT EXISTS COP4331;
USE COP4331;

CREATE TABLE IF NOT EXISTS Users (
  ID INT NOT NULL AUTO_INCREMENT,
  FirstName VARCHAR(50) NOT NULL DEFAULT '',
  LastName VARCHAR(50) NOT NULL DEFAULT '',
  Login VARCHAR(50) NOT NULL DEFAULT '',
  Password VARCHAR(50) NOT NULL DEFAULT '',
  PRIMARY KEY (ID)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Colors (
  ID INT NOT NULL AUTO_INCREMENT,
  Name VARCHAR(50) NOT NULL DEFAULT '',
  UserID INT NOT NULL DEFAULT '0',
  PRIMARY KEY (ID)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Contacts (
  ID INT NOT NULL AUTO_INCREMENT,
  FirstName VARCHAR(50) NOT NULL DEFAULT '',
  LastName VARCHAR(50) NOT NULL DEFAULT '',
  Phone VARCHAR(50) NOT NULL DEFAULT '',
  Email VARCHAR(50) NOT NULL DEFAULT '',
  UserID INT NOT NULL DEFAULT '0',
  PRIMARY KEY (ID)
) ENGINE = InnoDB;

-- Seed data (passwords are MD5 hashes of: COP4331, Test)
INSERT INTO Users (FirstName,LastName,Login,Password) VALUES ('Aashish','Yadavally','AYadavally','5832a71366768098cceb7095efb774f2');
INSERT INTO Users (FirstName,LastName,Login,Password) VALUES ('Sam','Hill','SamH','0cbc6611f5540bd0809a388dc95a615b');

INSERT INTO Colors (Name,UserID) VALUES ('Blue',1);
INSERT INTO Colors (Name,UserID) VALUES ('White',1);
INSERT INTO Colors (Name,UserID) VALUES ('Black',1);
INSERT INTO Colors (Name,UserID) VALUES ('gray',1);
INSERT INTO Colors (Name,UserID) VALUES ('Magenta',1);
INSERT INTO Colors (Name,UserID) VALUES ('Yellow',1);
INSERT INTO Colors (Name,UserID) VALUES ('Cyan',1);
INSERT INTO Colors (Name,UserID) VALUES ('Salmon',1);
INSERT INTO Colors (Name,UserID) VALUES ('Chartreuse',1);
INSERT INTO Colors (Name,UserID) VALUES ('Lime',1);
INSERT INTO Colors (Name,UserID) VALUES ('Light Blue',1);
INSERT INTO Colors (Name,UserID) VALUES ('Light Gray',1);
INSERT INTO Colors (Name,UserID) VALUES ('Light Red',1);
INSERT INTO Colors (Name,UserID) VALUES ('Light Green',1);
INSERT INTO Colors (Name,UserID) VALUES ('Brown',1);
INSERT INTO Colors (Name,UserID) VALUES ('Beige',1);

INSERT INTO Colors (Name,UserID) VALUES ('Blue',2);
INSERT INTO Colors (Name,UserID) VALUES ('Black',2);
INSERT INTO Colors (Name,UserID) VALUES ('Yellow',2);

-- App-level DB user (used by PHP, scoped to this database only)
-- CREATE USER 'colorsapp'@'%' IDENTIFIED BY 'REPLACE_WITH_REAL_PASSWORD';
-- GRANT ALL PRIVILEGES ON COP4331.* TO 'colorsapp'@'%';
-- FLUSH PRIVILEGES;
