-- Convert schema '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/3/001-auto.yml' to '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE groups ADD COLUMN default_event_id integer;

;
CREATE INDEX groups_idx_default_event_id ON groups (default_event_id);

;
ALTER TABLE users ADD COLUMN default_group_id integer;

;
CREATE INDEX users_idx_default_group_id ON users (default_group_id);

;

COMMIT;

