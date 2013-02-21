-- Convert schema '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/1/001-auto.yml' to '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE events (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL,
  group_id integer NOT NULL,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX events_idx_group_id ON events (group_id);

;
CREATE UNIQUE INDEX events_name ON events (name);

;
CREATE TABLE groups (
  id INTEGER PRIMARY KEY NOT NULL,
  name text NOT NULL
);

;
CREATE UNIQUE INDEX groups_name ON groups (name);

;

COMMIT;

