-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Feb 22 03:45:49 2013
-- 

;
BEGIN TRANSACTION;
--
-- Table: groups
--
CREATE TABLE groups (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL
);
CREATE UNIQUE INDEX groups_name ON groups (name);
--
-- Table: users
--
CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL,
  email text NOT NULL,
  password text NOT NULL
);
CREATE UNIQUE INDEX users_email ON users (email);
CREATE UNIQUE INDEX users_name ON users (name);
--
-- Table: events
--
CREATE TABLE events (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL,
  group_id integer NOT NULL,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX events_idx_group_id ON events (group_id);
CREATE UNIQUE INDEX events_name ON events (name);
--
-- Table: users_groups
--
CREATE TABLE users_groups (
  user_id integer NOT NULL,
  group_id integer NOT NULL,
  PRIMARY KEY (user_id, group_id),
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX users_groups_idx_group_id ON users_groups (group_id);
CREATE INDEX users_groups_idx_user_id ON users_groups (user_id);
COMMIT;
