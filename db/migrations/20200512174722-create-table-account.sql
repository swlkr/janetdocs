-- up
create table account (
  id integer primary key,
  email text,
  access_token text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table account