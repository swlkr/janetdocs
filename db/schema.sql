CREATE TABLE schema_migrations (version text primary key);
CREATE TABLE account (
  id integer primary key,
  email text,
  access_token text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
, login text not null default '');
CREATE TABLE package (
  id integer primary key,
  name text not null,
  url text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
);
CREATE TABLE binding (
  id integer primary key,
  name text not null,
  docstring text,
  package_id integer references package(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
);
CREATE TABLE example (
  id integer primary key,
  body text not null,
  binding_id integer not null references binding(id),
  account_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
);
CREATE TABLE link (
  source integer not null references binding(id),
  target integer not null references binding(id),
  PRIMARY KEY (source, target)
);
