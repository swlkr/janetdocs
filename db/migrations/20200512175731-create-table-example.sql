-- up
create table example (
  id integer primary key,
  body text not null,
  binding_id integer not null references binding(id),
  account_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table example
