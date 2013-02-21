-- Convert schema '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/4/001-auto.yml' to '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE groups_temp_alter (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL
);

;
INSERT INTO groups_temp_alter( id, name) SELECT id, name FROM groups;

;
DROP TABLE groups;

;
CREATE TABLE groups (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL
);

;
CREATE UNIQUE INDEX groups_name02 ON groups (name);

;
INSERT INTO groups SELECT id, name FROM groups_temp_alter;

;
DROP TABLE groups_temp_alter;

;
CREATE TEMPORARY TABLE users_temp_alter (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL,
  email text NOT NULL,
  password text NOT NULL
);

;
INSERT INTO users_temp_alter( id, name, email, password) SELECT id, name, email, password FROM users;

;
DROP TABLE users;

;
CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL,
  email text NOT NULL,
  password text NOT NULL
);

;
CREATE UNIQUE INDEX users_email02 ON users (email);

;
CREATE UNIQUE INDEX users_name02 ON users (name);

;
INSERT INTO users SELECT id, name, email, password FROM users_temp_alter;

;
DROP TABLE users_temp_alter;

;

COMMIT;

