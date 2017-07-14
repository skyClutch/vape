-- create schemas
drop schema if exists pta_dist_14 cascade;
drop schema if exists pta_dist_14_private cascade;
create schema pta_dist_14;
create schema pta_dist_14_private;

-- create person table
create table pta_dist_14.person (
  id               serial primary key,
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);

-- add comments on person table
comment on table pta_dist_14.person is 'A person of the forum.';
comment on column pta_dist_14.person.id is 'The primary unique identifier for the person.';
comment on column pta_dist_14.person.first_name is 'The person’s first name.';
comment on column pta_dist_14.person.last_name is 'The person’s last name.';
comment on column pta_dist_14.person.about is 'A short description about the person, written by the person.';
comment on column pta_dist_14.person.created_at is 'The time this person was created.';

-- create full name function
create function pta_dist_14.person_full_name(person pta_dist_14.person) returns text as $$
	select person.first_name || ' ' || person.last_name
$$ language sql stable;

comment on function pta_dist_14.person_full_name(pta_dist_14.person) is 'A person’s full name which is a concatenation of their first and last name.';

-- add updated columns
alter table pta_dist_14.person add column updated_at timestamp default now();

-- add triggers and function for update
create function pta_dist_14_private.set_updated_at() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;

create trigger person_updated_at before update
  on pta_dist_14.person
  for each row
  execute procedure pta_dist_14_private.set_updated_at();
