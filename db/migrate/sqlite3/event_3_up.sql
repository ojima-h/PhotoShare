CREATE TABLE events (
  id            INTEGER PRIMARY KEY,
  name          TEXT    UNIQUE NOT NULL,
  group_id       INTEGER NOT NULL,
  created_at    TEXT,
  updated_at    TEXT,
  FOREIGN KEY(group_id)  REFERENCES groups
);









