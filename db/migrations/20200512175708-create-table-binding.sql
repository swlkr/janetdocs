-- up
create table binding (
  id integer primary key,
  name text not null,
  docstring text,
  package_id integer references package(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table binding
