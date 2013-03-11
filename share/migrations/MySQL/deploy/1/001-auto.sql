-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Mar 11 22:08:12 2013
-- 
;
SET foreign_key_checks=0;
--
-- Table: `events`
--
CREATE TABLE `events` (
  `id` integer NOT NULL AUTO_INCREMENT,
  `name` char(255) NOT NULL,
  `group_id` integer NOT NULL,
  `passphrase` char(255) NULL,
  INDEX `events_idx_group_id` (`group_id`),
  PRIMARY KEY (`id`),
  UNIQUE `events_name` (`name`),
  CONSTRAINT `events_fk_group_id` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `groups`
--
CREATE TABLE `groups` (
  `id` integer NOT NULL AUTO_INCREMENT,
  `name` char(255) NOT NULL,
  `default_event_id` integer NULL,
  INDEX `groups_idx_default_event_id` (`default_event_id`),
  PRIMARY KEY (`id`),
  UNIQUE `groups_name` (`name`),
  CONSTRAINT `groups_fk_default_event_id` FOREIGN KEY (`default_event_id`) REFERENCES `events` (`id`)
) ENGINE=InnoDB;
--
-- Table: `photos`
--
CREATE TABLE `photos` (
  `id` integer NOT NULL AUTO_INCREMENT,
  `content_type` char(127) NOT NULL,
  `event_id` integer NOT NULL,
  INDEX `photos_idx_event_id` (`event_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `photos_fk_event_id` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer NOT NULL AUTO_INCREMENT,
  `name` char(255) NOT NULL,
  `email` char(255) NOT NULL,
  `password` char(255) NOT NULL,
  `default_group_id` integer NULL,
  INDEX `users_idx_default_group_id` (`default_group_id`),
  PRIMARY KEY (`id`),
  UNIQUE `users_email` (`email`),
  UNIQUE `users_name` (`name`),
  CONSTRAINT `users_fk_default_group_id` FOREIGN KEY (`default_group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `users_groups`
--
CREATE TABLE `users_groups` (
  `user_id` integer NOT NULL,
  `group_id` integer NOT NULL,
  INDEX `users_groups_idx_group_id` (`group_id`),
  INDEX `users_groups_idx_user_id` (`user_id`),
  PRIMARY KEY (`user_id`, `group_id`),
  CONSTRAINT `users_groups_fk_group_id` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_groups_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;
