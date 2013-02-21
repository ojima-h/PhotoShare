CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TEXT,
  updated_at TEXT
);



