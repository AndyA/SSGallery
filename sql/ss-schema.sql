CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ss`;
USE `ss`;
-- MySQL dump 10.15  Distrib 10.0.12-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: ss
-- ------------------------------------------------------
-- Server version	10.0.12-MariaDB-1~wheezy

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ss_collection`
--

DROP TABLE IF EXISTS `ss_collection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_collection` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Collection id',
  `name` varchar(60) NOT NULL COMMENT 'Collection name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_coordinates`
--

DROP TABLE IF EXISTS `ss_coordinates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_coordinates` (
  `acno` int(10) unsigned NOT NULL COMMENT 'Asset id',
  `location` geometry NOT NULL,
  PRIMARY KEY (`acno`),
  SPATIAL KEY `location` (`location`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_copyright_class`
--

DROP TABLE IF EXISTS `ss_copyright_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_copyright_class` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Copyright class id',
  `name` char(1) NOT NULL COMMENT 'Copyright class',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_copyright_holder`
--

DROP TABLE IF EXISTS `ss_copyright_holder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_copyright_holder` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Copyright holder id',
  `name` varchar(200) NOT NULL COMMENT 'Copyright holder name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=568 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_exif`
--

DROP TABLE IF EXISTS `ss_exif`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_exif` (
  `acno` int(10) unsigned NOT NULL COMMENT 'Asset id',
  `exif` longtext,
  PRIMARY KEY (`acno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_format`
--

DROP TABLE IF EXISTS `ss_format`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_format` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Format id',
  `name` varchar(50) NOT NULL COMMENT 'Format name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_image`
--

DROP TABLE IF EXISTS `ss_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_image` (
  `hash` char(64) DEFAULT NULL COMMENT 'SHA1 hash',
  `acno` int(10) unsigned NOT NULL COMMENT 'Asset id',
  `kind_id` int(10) unsigned DEFAULT NULL,
  `collection_id` int(10) unsigned DEFAULT NULL,
  `copyright_class_id` int(10) unsigned DEFAULT NULL,
  `copyright_holder_id` int(10) unsigned DEFAULT NULL,
  `format_id` int(10) unsigned DEFAULT NULL,
  `location_id` int(10) unsigned DEFAULT NULL,
  `news_restriction_id` int(10) unsigned DEFAULT NULL,
  `personality_id` int(10) unsigned DEFAULT NULL,
  `origin_date` date DEFAULT NULL,
  `photographer_id` int(10) unsigned DEFAULT NULL,
  `subject_id` int(10) unsigned DEFAULT NULL,
  `width` int(5) unsigned DEFAULT NULL,
  `height` int(5) unsigned DEFAULT NULL,
  `seq` double DEFAULT NULL,
  `annotation` text,
  `headline` text,
  PRIMARY KEY (`acno`),
  KEY `ss_image_hash` (`hash`),
  KEY `ss_image_seq` (`seq`),
  KEY `ss_image_kind_id` (`kind_id`),
  KEY `ss_image_collection_id` (`collection_id`),
  KEY `ss_image_copyright_class_id` (`copyright_class_id`),
  KEY `ss_image_copyright_holder_id` (`copyright_holder_id`),
  KEY `ss_image_format_id` (`format_id`),
  KEY `ss_image_location_id` (`location_id`),
  KEY `ss_image_news_restriction_id` (`news_restriction_id`),
  KEY `ss_image_personality_id` (`personality_id`),
  KEY `ss_image_origin_date` (`origin_date`),
  KEY `ss_image_photographer_id` (`photographer_id`),
  KEY `ss_image_subject_id` (`subject_id`),
  KEY `ss_image_width` (`width`),
  KEY `ss_image_height` (`height`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_image_keyword`
--

DROP TABLE IF EXISTS `ss_image_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_image_keyword` (
  `id` int(10) unsigned NOT NULL COMMENT 'Keyword id',
  `acno` int(10) unsigned NOT NULL COMMENT 'Asset id',
  PRIMARY KEY (`id`,`acno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_keyword`
--

DROP TABLE IF EXISTS `ss_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_keyword` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Keyword id',
  `name` varchar(60) NOT NULL COMMENT 'Keyword',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3322 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_kind`
--

DROP TABLE IF EXISTS `ss_kind`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_kind` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Image kind id',
  `name` varchar(60) NOT NULL COMMENT 'Image kind name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_location`
--

DROP TABLE IF EXISTS `ss_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_location` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Location id',
  `name` varchar(100) NOT NULL COMMENT 'Location name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=229 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_news_restriction`
--

DROP TABLE IF EXISTS `ss_news_restriction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_news_restriction` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'News restriction id',
  `name` varchar(1000) NOT NULL COMMENT 'News restriction name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_personality`
--

DROP TABLE IF EXISTS `ss_personality`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_personality` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Personality id',
  `name` varchar(2000) NOT NULL COMMENT 'Personality name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12792 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_photographer`
--

DROP TABLE IF EXISTS `ss_photographer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_photographer` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Photographer id',
  `name` varchar(200) NOT NULL COMMENT 'Photographer name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1399 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_random`
--

DROP TABLE IF EXISTS `ss_random`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_random` (
  `acno` int(10) unsigned NOT NULL COMMENT 'Asset id',
  `r0` tinyint(3) unsigned DEFAULT NULL,
  `r1` tinyint(3) unsigned DEFAULT NULL,
  `r2` tinyint(3) unsigned DEFAULT NULL,
  `r3` tinyint(3) unsigned DEFAULT NULL,
  `r4` tinyint(3) unsigned DEFAULT NULL,
  `r5` tinyint(3) unsigned DEFAULT NULL,
  `r6` tinyint(3) unsigned DEFAULT NULL,
  `r7` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`acno`),
  KEY `ss_random_r0` (`r0`),
  KEY `ss_random_r1` (`r1`),
  KEY `ss_random_r2` (`r2`),
  KEY `ss_random_r3` (`r3`),
  KEY `ss_random_r4` (`r4`),
  KEY `ss_random_r5` (`r5`),
  KEY `ss_random_r6` (`r6`),
  KEY `ss_random_r7` (`r7`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ss_subject`
--

DROP TABLE IF EXISTS `ss_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ss_subject` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Subject term id',
  `name` varchar(200) NOT NULL COMMENT 'Subject term',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=288 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'ss'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-07-25 12:34:35
