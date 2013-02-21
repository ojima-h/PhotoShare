-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Feb 22 00:19:51 2013
-- 

;
BEGIN TRANSACTION;
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
COMMIT;
