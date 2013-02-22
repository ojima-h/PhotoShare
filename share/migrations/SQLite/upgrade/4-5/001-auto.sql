-- Convert schema '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/4/001-auto.yml' to '/home/ojima.h/Workspace/PhotoShare/innovation2012/share/migrations/_source/deploy/5/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE photos (
  id INTEGER PRIMARY KEY NOT NULL,
  content_type string NOT NULL,
  event_id integer NOT NULL,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX photos_idx_event_id ON photos (event_id);

;

COMMIT;

