CREATE TABLE groups (
  id            INTEGER PRIMARY KEY,
  name          TEXT    UNIQUE NOT NULL,
  created_at    TEXT,
  updated_at    TEXT
);

CREATE TABLE users_groups (
  id            INTEGER PRIMARY KEY,
  user_id       INTEGER NOT NULL,
  group_id      INTEGER NOT NULL,
  created_at    TEXT,
  updated_at    TEXT,
  FOREIGN KEY(user_id)  REFERENCES users,
  FOREIGN KEY(group_id) REFERENCES groups
);
