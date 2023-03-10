--
-- Script was generated by Devart dbForge Studio 2020 for MySQL, Version 9.0.338.0
-- Product home page: http://www.devart.com/dbforge/mysql/studio
-- Script date 2/12/2023 5:02:50 PM
-- Server version: 8.0.26
-- Client version: 4.1
--

-- 
-- Disable foreign keys
-- 
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- 
-- Set SQL mode
-- 
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE `nckh.blockchain.team4`;

--
-- Drop procedure `proc_user_delete`
--
DROP PROCEDURE IF EXISTS proc_user_delete;

--
-- Drop procedure `proc_user_Insert`
--
DROP PROCEDURE IF EXISTS proc_user_Insert;

--
-- Drop procedure `proc_certificate_insert`
--
DROP PROCEDURE IF EXISTS proc_certificate_insert;

--
-- Drop procedure `proc_certificate_revoke`
--
DROP PROCEDURE IF EXISTS proc_certificate_revoke;

--
-- Drop procedure `proc_certificate_send`
--
DROP PROCEDURE IF EXISTS proc_certificate_send;

--
-- Drop procedure `proc_certificate_sign`
--
DROP PROCEDURE IF EXISTS proc_certificate_sign;

--
-- Drop table `certificate`
--
DROP TABLE IF EXISTS certificate;

--
-- Drop procedure `proc_contact_hidden`
--
DROP PROCEDURE IF EXISTS proc_contact_hidden;

--
-- Drop procedure `proc_contact_insert`
--
DROP PROCEDURE IF EXISTS proc_contact_insert;

--
-- Drop procedure `proc_contact_unhidden`
--
DROP PROCEDURE IF EXISTS proc_contact_unhidden;

--
-- Drop table `contact`
--
DROP TABLE IF EXISTS contact;

--
-- Drop table `user`
--
DROP TABLE IF EXISTS user;

--
-- Set default database
--
USE `nckh.blockchain.team4`;

--
-- Create table `user`
--
CREATE TABLE user (
  UserDID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa chính, có kiểu là DID',
  UserCode mediumint NOT NULL COMMENT 'Mã code, để hiển thị lên trang web',
  Password varchar(255) NOT NULL DEFAULT '' COMMENT 'Mật khẩu',
  Keywords varchar(255) NOT NULL DEFAULT '' COMMENT '12 từ khóa để lấy lại mật khẩu',
  Logo varchar(255) DEFAULT NULL COMMENT 'Ảnh đại diện cho tổ chức/sinh viên',
  OrganizationName varchar(255) DEFAULT NULL COMMENT 'Tên tổ chức',
  FirstName varchar(100) DEFAULT NULL,
  LastName varchar(100) DEFAULT NULL,
  Gender tinyint DEFAULT NULL COMMENT 'Giới tính (0-nam; 1-nữ; 3-khác)',
  DateOfBirth date DEFAULT NULL COMMENT 'Ngày sinh',
  IsDeleted tinyint DEFAULT NULL COMMENT 'Bị xóa hay chưa (0-chưa xóa; 1-đã xóa)',
  PRIMARY KEY (UserDID)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_general_ci;

--
-- Create index `UserCode` on table `user`
--
ALTER TABLE user
ADD UNIQUE INDEX UserCode (UserCode);

--
-- Create table `contact`
--
CREATE TABLE contact (
  ContactID char(36) NOT NULL DEFAULT '',
  ContactCode mediumint UNSIGNED NOT NULL,
  UserDID varchar(255) NOT NULL DEFAULT '',
  DIDContact varchar(255) NOT NULL DEFAULT '',
  ContactStatus varchar(100) DEFAULT NULL,
  CreatedDate datetime DEFAULT NULL,
  IsHidden tinyint NOT NULL,
  PRIMARY KEY (ContactID)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_general_ci;

--
-- Create index `ContactCode` on table `contact`
--
ALTER TABLE contact
ADD UNIQUE INDEX ContactCode (ContactCode);

--
-- Create foreign key
--
ALTER TABLE contact
ADD CONSTRAINT FK_contact_DIDContact FOREIGN KEY (DIDContact)
REFERENCES user (UserDID);

--
-- Create foreign key
--
ALTER TABLE contact
ADD CONSTRAINT FK_contact_UserDID FOREIGN KEY (UserDID)
REFERENCES user (UserDID);

DELIMITER $$

--
-- Create procedure `proc_contact_unhidden`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_contact_unhidden (IN v_ContactCode varchar(255))
COMMENT 'Xóa '
BEGIN
  UPDATE contact c
  SET c.IsHidden = 0
  WHERE c.ContactCode = v_ContactCode;
END
$$

--
-- Create procedure `proc_contact_insert`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_contact_insert (IN v_ContactID char(36), IN v_UserDID varchar(255), IN v_DIDContact varchar(255), IN v_ContactStatus varchar(100), IN v_CreatedDate datetime)
COMMENT 'Thêm mới một liên lạc'
BEGIN
  -- Lấy giá trị lớn nhất của user code
  DECLARE CODE mediumint;
  SELECT
    MAX(ContactCode) INTO CODE
  FROM contact;

  -- Nếu table xxx chưa có data sẽ mặc định CODE = 100000
  IF CODE IS NULL THEN
    SET CODE = 100000;
  ELSE
    SET CODE = CODE + 1;
  END IF;

  -- Thực hiện insert
  INSERT INTO contact
    VALUES (v_ContactID, CODE, v_UserDID, v_DIDContact, v_ContactStatus, v_CreatedDate, 0);

END
$$

--
-- Create procedure `proc_contact_hidden`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_contact_hidden (IN v_ContactCode varchar(255))
COMMENT 'Xóa '
BEGIN
  UPDATE contact c
  SET c.IsHidden = 1
  WHERE c.ContactCode = v_ContactCode;
END
$$

DELIMITER ;

--
-- Create table `certificate`
--
CREATE TABLE certificate (
  CertificateID char(36) NOT NULL DEFAULT '' COMMENT 'Khóa chính của bảng, sinh ra từ mã GUID',
  IssuedDID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa ngoại, liên kết với bảng user, có kiểu DID',
  ReceivedDID varchar(255) NOT NULL DEFAULT '',
  CertificateCode mediumint NOT NULL COMMENT 'Mã code, để hiển thị lên trang web',
  CertificateType varchar(100) NOT NULL DEFAULT '' COMMENT 'Kiểu bằng cấp',
  CertificateName varchar(255) NOT NULL DEFAULT '' COMMENT 'Tên bằng cấp',
  Classification varchar(50) NOT NULL DEFAULT '' COMMENT 'Loại bằng cấp',
  CreatedDate datetime DEFAULT NULL,
  CertificateStatus tinyint DEFAULT NULL COMMENT 'Trạng thái của bằng cấp (1-Draft/2-Signed/3-Received/4-Revoked)',
  IsSend tinyint NOT NULL COMMENT 'Gửi bằng hay chưa (0-Chưa gửi/1-Đã gửi)',
  SentDate datetime DEFAULT NULL COMMENT 'Ngày tháng xuất/nhận bằng',
  IsSigned tinyint DEFAULT 0 COMMENT 'Được kí hay chưa (0-chưa kí; 1-đã kí)',
  SignedBy varchar(255) DEFAULT NULL COMMENT 'Kí bới',
  SignedDate datetime DEFAULT NULL COMMENT 'Ngày kí',
  PRIMARY KEY (CertificateID)
)
ENGINE = INNODB,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_general_ci;

--
-- Create index `FK_certificate_IssuedDID2` on table `certificate`
--
ALTER TABLE certificate
ADD INDEX FK_certificate_IssuedDID2 (IssuedDID);

--
-- Create foreign key
--
ALTER TABLE certificate
ADD CONSTRAINT FK_certificate_IssuedDID FOREIGN KEY (IssuedDID)
REFERENCES user (UserDID);

--
-- Create foreign key
--
ALTER TABLE certificate
ADD CONSTRAINT FK_certificate_ReceivedDID FOREIGN KEY (ReceivedDID)
REFERENCES user (UserDID);

DELIMITER $$

--
-- Create procedure `proc_certificate_sign`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_certificate_sign (IN v_SignedBy varchar(255))
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 2,
      c.IsSigned = 1,
      c.SignedBy = v_SignedBy,
      c.SignedDate = NOW();
END
$$

--
-- Create procedure `proc_certificate_send`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_certificate_send ()
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 3,
      c.IsSend = 1,
      c.SentDate = NOW();
END
$$

--
-- Create procedure `proc_certificate_revoke`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_certificate_revoke ()
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 4;
END
$$

--
-- Create procedure `proc_certificate_insert`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_certificate_insert (IN v_CertificateID char(36), IN v_IssuedDID varchar(255), IN v_ReveivedDID varchar(255), IN v_CertificateType varchar(100), IN v_CertificateName varchar(255), IN v_Classification varchar(50))
BEGIN
  -- Lấy giá trị lớn nhất của user code
  DECLARE CODE mediumint;
  SELECT
    MAX(certificatecode) INTO CODE
  FROM certificate;

  -- Nếu table xxx chưa có data sẽ mặc định CODE = 100000
  IF CODE IS NULL THEN
    SET CODE = 100000;
  ELSE
    SET CODE = CODE + 1;
  END IF;

  INSERT INTO certificate
    VALUES (v_CertificateID, v_IssuedDID, v_ReveivedDID, CODE, v_CertificateType, v_CertificateName, v_Classification, NOW(), 1, 0, NULL, 0, '', NULL);
END
$$

--
-- Create procedure `proc_user_Insert`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_user_Insert (IN v_UserDID varchar(255), IN v_Password varchar(255), IN v_Keywords varchar(255), IN v_Logo varchar(255), IN v_OrganizationName varchar(255), IN v_FirstName varchar(100), IN v_LastName varchar(100), IN v_Gender tinyint, IN v_DateOfBirth date)
COMMENT 'Procedure thêm mới 1 user'
BEGIN
  -- Lấy giá trị lớn nhất của user code
  DECLARE CODE mediumint;
  SELECT
    MAX(usercode) INTO CODE
  FROM user;

  -- Nếu table xxx chưa có data sẽ mặc định CODE = 100000
  IF CODE IS NULL THEN
    SET CODE = 100000;
  ELSE
    SET CODE = CODE + 1;
  END IF;

  INSERT INTO user
    VALUES (v_UserDID, CODE, v_Password, v_Keywords, v_Logo, v_OrganizationName, v_FirstName, v_LastName, v_Gender, v_DateOfBirth, 0);
END
$$

--
-- Create procedure `proc_user_delete`
--
CREATE DEFINER = 'root'@'localhost'
PROCEDURE proc_user_delete (IN v_UserCode mediumint)
COMMENT 'Xóa 1 người dùng'
BEGIN
  UPDATE user u
  SET u.IsDeleted = 1
  WHERE u.UserCode = v_UserCode;
END
$$

DELIMITER ;

-- 
-- Dumping data for table user
--
INSERT INTO user VALUES
('did:prism:09sdf8g098sdf0g98sd0f9g80sd9f8g09sd8fg', 100000, '12345678', 'sip cobweb heavenly homeless few combative ritzy pin agree voyage ignore salt', 'abc.xyz', 'UTC', '', '', NULL, NULL, 0),
('did:prism:19sdf8g098sdf0g98sd0f9g80sd9f8g09sd8fg', 100001, '12345678', 'bleach kind handsomely obey arithmetic powder encourage grass whirl fuel breakable trousers', 'abc.xyz', '', 'Nguyen', 'Van A', 0, '2023-02-12', 0),
('did:prism:29sdf8g098sdf0g98sd0f9g80sd9f8g09sd8fg', 100002, '12345678', 'flavor fanatical produce idiotic fuzzy cars corn hapless bashful explain guard stretch', 'abc.xyz', '', 'Nguyen', 'Thi B', 1, '2023-02-12', 0);

-- 
-- Dumping data for table contact
--
INSERT INTO contact VALUES
('a3b216ae-6088-4d40-a34b-28d3ee2049ec', 100000, 'did:prism:29sdf8g098sdf0g98sd0f9g80sd9f8g09sd8fg', 'did:prism:09sdf8g098sdf0g98sd0f9g80sd9f8g09sd8fg', 'Pending', '2023-02-12 14:59:28', 0);

-- 
-- Dumping data for table certificate
--
INSERT INTO certificate VALUES
('a7dd4856-7184-42a1-9409-f92de3ba5468', 'did:prism:09sdf8g098sdf0g98sd0f9g80sd9f8g09sd8fg', 'did:prism:29sdf8g098sdf0g98sd0f9g80sd9f8g09sd8fg', 100000, 'Education Degree', 'UTC University Degree', 'Good', '2023-02-12 16:53:22', 3, 1, '2023-02-12 16:56:08', 1, 'Long', '2023-02-12 16:55:49');

-- 
-- Restore previous SQL mode
-- 
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;

-- 
-- Enable foreign keys
-- 
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;