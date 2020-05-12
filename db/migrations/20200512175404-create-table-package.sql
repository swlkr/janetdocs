-- up
create table package (
  id integer primary key,
  name text not null,
  url text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table package