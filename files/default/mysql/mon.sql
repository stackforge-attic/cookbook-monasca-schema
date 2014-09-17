CREATE DATABASE IF NOT EXISTS `mon` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mon`;

SET foreign_key_checks = 0;

DROP TABLE IF EXISTS `alarm`;
CREATE TABLE `alarm` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alarm_definition_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `state` enum('UNDETERMINED','OK','ALARM') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`alarm_definition_id`),
  CONSTRAINT `fk_alarm_definition_id` FOREIGN KEY (`alarm_definition_id`) REFERENCES `alarm_definition` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `alarm_action`;
CREATE TABLE `alarm_action` (
  `alarm_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alarm_state` enum('UNDETERMINED','OK','ALARM') COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`alarm_id`,`alarm_state`,`action_id`),
  CONSTRAINT `fk_alarm_action_alarm_id` FOREIGN KEY (`alarm_id`) REFERENCES `alarm_definition` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `alarm_definition` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tenant_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expression` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('LOW','MEDIUM','HIGH','CRITICAL') COLLATE utf8mb4_unicode_ci NOT NULL,
  `match_by` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `actions_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tenant_id` (`tenant_id`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `alarm_metric`;
CREATE TABLE `alarm_metric` (
  `alarm_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `metric_definition_dimensions_id` binary(20) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  PRIMARY KEY (`alarm_id`,`metric_definition_dimensions_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `metric_definition`;
CREATE TABLE `metric_definition` (
  `id` binary(20) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tenant_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `region` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `metric_definition_dimensions`;
CREATE TABLE `metric_definition_dimensions` (
  `id` binary(20) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `metric_definition_id` binary(20) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `metric_dimension_set_id` binary(20) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `metric_dimension`;
CREATE TABLE `metric_dimension` (
  `dimension_set_id` binary(20) NOT NULL DEFAULT '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PRIMARY KEY (`id`)';

DROP TABLE IF EXISTS `notification_method`;
CREATE TABLE `notification_method` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tenant_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('EMAIL','SMS') COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `sub_alarm`;
CREATE TABLE `sub_alarm` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alarm_definition_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `function` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `metric_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `operator` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `threshold` double NOT NULL,
  `period` int(11) NOT NULL,
  `periods` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_sub_alarm` (`alarm_definition_id`),
  CONSTRAINT `fk_sub_alarm` FOREIGN KEY (`alarm_definition_id`) REFERENCES `alarm_definition` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `sub_alarm_dimension`;
CREATE TABLE `sub_alarm_dimension` (
  `sub_alarm_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dimension_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `value` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`sub_alarm_id`,`dimension_name`),
  CONSTRAINT `fk_sub_alarm_dimension` FOREIGN KEY (`sub_alarm_id`) REFERENCES `sub_alarm` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `schema_migrations`;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE USER 'notification'@'%' IDENTIFIED BY 'password';
GRANT SELECT ON mon.* TO 'notification'@'%';
CREATE USER 'notification'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON mon.* TO 'notification'@'localhost';

CREATE USER 'monapi'@'%' IDENTIFIED BY 'password';
GRANT ALL ON mon.* TO 'monapi'@'%';
CREATE USER 'monapi'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON mon.* TO 'monapi'@'localhost';

CREATE USER 'thresh'@'%' IDENTIFIED BY 'password';
GRANT ALL ON mon.* TO 'thresh'@'%';
CREATE USER 'thresh'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON mon.* TO 'thresh'@'localhost';

SET foreign_key_checks = 1;
