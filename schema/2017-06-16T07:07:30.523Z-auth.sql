-- add pgcrypto
create extension if not exists "pgcrypto";

-- add private person account table
create table pta_dist_14_private.person_account (
  person_id        integer primary key references pta_dist_14.person(id) on delete cascade,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

comment on table pta_dist_14_private.person_account is 'Private information about a person’s account.';
comment on column pta_dist_14_private.person_account.person_id is 'The id of the person associated with this account.';
comment on column pta_dist_14_private.person_account.email is 'The email address of the person.';
comment on column pta_dist_14_private.person_account.password_hash is 'An opaque hash of the person’s password.';

-- register person function
create function pta_dist_14.register_person(
  first_name text,
  last_name text,
  email text,
  password text
) returns pta_dist_14.person as $$
declare
  person pta_dist_14.person;
begin
  insert into pta_dist_14.person (first_name, last_name) values
    (first_name, last_name)
    returning * into person;

  insert into pta_dist_14_private.person_account (person_id, email, password_hash) values
    (person.id, email, crypt(password, gen_salt('bf')));

  return person;
end;
$$ language plpgsql strict security definer;

comment on function pta_dist_14.register_person(text, text, text, text) is 'Registers a single person and creates an account in our forum.';

-- create some roles
drop role if exists pta_dist_14_postgraphql;
create role pta_dist_14_postgraphql login password 'vapityvapevapevape';

drop role if exists pta_dist_14_anonymous;
create role pta_dist_14_anonymous;
grant pta_dist_14_anonymous to pta_dist_14_postgraphql;

drop role if exists pta_dist_14_person;
create role pta_dist_14_person;
grant pta_dist_14_person to pta_dist_14_postgraphql;

drop role if exists pta_dist_14_contributor;
create role pta_dist_14_contributor;
grant pta_dist_14_contributor to pta_dist_14_postgraphql;

drop role if exists pta_dist_14_moderator;
create role pta_dist_14_moderator;
grant pta_dist_14_moderator to pta_dist_14_postgraphql;

drop role if exists pta_dist_14_admin;
create role pta_dist_14_admin;
grant pta_dist_14_admin to pta_dist_14_postgraphql;

-- create token type
create type pta_dist_14.jwt_token as (
  role text,
  person_id integer
);

-- add auth function
create function pta_dist_14.authenticate(
  email text,
  password text
) returns pta_dist_14.jwt_token as $$
declare
  account pta_dist_14_private.person_account;
begin
  select a.* into account
  from pta_dist_14_private.person_account as a
  where a.email = $1;

  if account.password_hash = crypt(password, account.password_hash) then
    return ('pta_dist_14_person', account.person_id)::pta_dist_14.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;

comment on function pta_dist_14.authenticate(text, text) is 'Creates a JWT token that will securely identify a person and give them certain permissions.';

-- add  current person function
create function pta_dist_14.current_person() returns pta_dist_14.person as $$
  select *
  from pta_dist_14.person
  where id = current_setting('jwt.claims.person_id')::integer
$$ language sql stable;

comment on function pta_dist_14.current_person() is 'Gets the person who was identified by our JWT.';

-- grants
-- after schema creation and before function creation
alter default privileges revoke execute on functions from public;

grant usage on schema pta_dist_14 to pta_dist_14_anonymous, pta_dist_14_person;

grant select on table pta_dist_14.person to pta_dist_14_anonymous, pta_dist_14_person;
grant update, delete on table pta_dist_14.person to pta_dist_14_person;

grant select on table pta_dist_14.post to pta_dist_14_anonymous, pta_dist_14_person;
grant insert, update, delete on table pta_dist_14.post to pta_dist_14_person;
grant usage on sequence pta_dist_14.post_id_seq to pta_dist_14_person;

grant execute on function pta_dist_14.person_full_name(pta_dist_14.person) to pta_dist_14_anonymous, pta_dist_14_person;
grant execute on function pta_dist_14.post_summary(pta_dist_14.post, integer, text) to pta_dist_14_anonymous, pta_dist_14_person;
grant execute on function pta_dist_14.person_latest_post(pta_dist_14.person) to pta_dist_14_anonymous, pta_dist_14_person;
grant execute on function pta_dist_14.search_posts(text) to pta_dist_14_anonymous, pta_dist_14_person;
grant execute on function pta_dist_14.authenticate(text, text) to pta_dist_14_anonymous, pta_dist_14_person;
grant execute on function pta_dist_14.current_person() to pta_dist_14_anonymous, pta_dist_14_person;

grant execute on function pta_dist_14.register_person(text, text, text, text) to pta_dist_14_anonymous;

-- enable row-level security
alter table pta_dist_14.person enable row level security;
alter table pta_dist_14.post enable row level security;

-- read policy for anybody
create policy select_person on pta_dist_14.person for select
  using (true);

create policy select_post on pta_dist_14.post for select
  using (true);

-- write/delete policies for logged in persons on their own accts
create policy update_person on pta_dist_14.person for update to pta_dist_14_person
  using (id = current_setting('jwt.claims.person_id')::integer);

create policy delete_person on pta_dist_14.person for delete to pta_dist_14_person
  using (id = current_setting('jwt.claims.person_id')::integer);

-- post policies
create policy insert_post on pta_dist_14.post for insert to pta_dist_14_person
  with check (author_id = current_setting('jwt.claims.person_id')::integer);

create policy update_post on pta_dist_14.post for update to pta_dist_14_person
  using (author_id = current_setting('jwt.claims.person_id')::integer);

create policy delete_post on pta_dist_14.post for delete to pta_dist_14_person
  using (author_id = current_setting('jwt.claims.person_id')::integer);
