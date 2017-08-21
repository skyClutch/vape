-- create schemas
create schema if not exists public;
drop schema if exists %PSQL_SCHEMA% cascade;
drop schema if exists %PSQL_SCHEMA%_private cascade;
create schema %PSQL_SCHEMA%;
create schema %PSQL_SCHEMA%_private;

-- create person table
create table %PSQL_SCHEMA%.person (
  id               serial primary key,
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);

-- add comments on person table
comment on table  %PSQL_SCHEMA%.person is 'A person of the forum.';
comment on column %PSQL_SCHEMA%.person.id is 'The primary unique identifier for the person.';
comment on column %PSQL_SCHEMA%.person.first_name is 'The person’s first name.';
comment on column %PSQL_SCHEMA%.person.last_name is 'The person’s last name.';
comment on column %PSQL_SCHEMA%.person.about is 'A short description about the person, written by the person.';
comment on column %PSQL_SCHEMA%.person.created_at is 'The time this person was created.';

-- create full name function
create function %PSQL_SCHEMA%.person_full_name(person %PSQL_SCHEMA%.person) returns text as $$
	select person.first_name || ' ' || person.last_name
$$ language sql stable;

comment on function %PSQL_SCHEMA%.person_full_name(%PSQL_SCHEMA%.person) is 'A person’s full name which is a concatenation of their first and last name.';

-- add updated columns
alter table %PSQL_SCHEMA%.person add column updated_at timestamp default now();

-- add triggers and function for update
create function %PSQL_SCHEMA%_private.set_updated_at() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;

create trigger person_updated_at before update
  on %PSQL_SCHEMA%.person
  for each row
  execute procedure %PSQL_SCHEMA%_private.set_updated_at();
