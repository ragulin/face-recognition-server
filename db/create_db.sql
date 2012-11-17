CREATE TABLE label
(
  id INTEGER PRIMARY KEY,
  name varchar(255)
);

CREATE TABLE image
(
  id INTEGER PRIMARY KEY,
  path varchar(255),
  label_id INTEGER,
  FOREIGN KEY(label_id) REFERENCES label(id)
);
