
-- up
CREATE TABLE link (
  source integer not null references binding(id),
  target integer not null references binding(id),
  PRIMARY KEY (source, target)
);

-- down
DROP TABLE link;
