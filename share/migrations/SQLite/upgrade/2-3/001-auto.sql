-- Convert schema '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/2/001-auto.yml' to '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE users_groups (
  user_id integer NOT NULL,
  group_id integer NOT NULL,
  PRIMARY KEY (user_id, group_id),
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX users_groups_idx_group_id ON users_groups (group_id);

;
CREATE INDEX users_groups_idx_user_id ON users_groups (user_id);

;

COMMIT;

