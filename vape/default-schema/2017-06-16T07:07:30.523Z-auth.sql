-- add pgcrypto
create extension if not exists "pgcrypto";

-- add private person account table
create table %PSQL_SCHEMA%_private.person_account (
  person_id        integer primary key references %PSQL_SCHEMA%.person(id) on delete cascade,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

comment on table %PSQL_SCHEMA%_private.person_account is 'Private information about a person’s account.';
comment on column %PSQL_SCHEMA%_private.person_account.person_id is 'The id of the person associated with this account.';
comment on column %PSQL_SCHEMA%_private.person_account.email is 'The email address of the person.';
comment on column %PSQL_SCHEMA%_private.person_account.password_hash is 'An opaque hash of the person’s password.';

-- register person function
create function %PSQL_SCHEMA%.register_person(
  first_name text,
  last_name text,
  email text,
  password text
) returns %PSQL_SCHEMA%.person as $$
declare
  person %PSQL_SCHEMA%.person;
begin
  insert into %PSQL_SCHEMA%.person (first_name, last_name) values
    (first_name, last_name)
    returning * into person;

  insert into %PSQL_SCHEMA%_private.person_account (person_id, email, password_hash) values
    (person.id, email, crypt(password, gen_salt('bf')));

  return person;
end;
$$ language plpgsql strict security definer;

comment on function %PSQL_SCHEMA%.register_person(text, text, text, text) is 'Registers a single person and creates an account in our forum.';

-- create some roles
drop role if exists %PSQL_SCHEMA%_anonymous;
create role %PSQL_SCHEMA%_anonymous;
grant %PSQL_SCHEMA%_anonymous to %PSQL_SCHEMA%_postgraphql;

drop role if exists %PSQL_SCHEMA%_person;
create role %PSQL_SCHEMA%_person;
grant %PSQL_SCHEMA%_person to %PSQL_SCHEMA%_postgraphql;

drop role if exists %PSQL_SCHEMA%_contributor;
create role %PSQL_SCHEMA%_contributor;
grant %PSQL_SCHEMA%_contributor to %PSQL_SCHEMA%_postgraphql;

drop role if exists %PSQL_SCHEMA%_moderator;
create role %PSQL_SCHEMA%_moderator;
grant %PSQL_SCHEMA%_moderator to %PSQL_SCHEMA%_postgraphql;

drop role if exists %PSQL_SCHEMA%_admin;
create role %PSQL_SCHEMA%_admin;
grant %PSQL_SCHEMA%_admin to %PSQL_SCHEMA%_postgraphql;

-- create token type
create type %PSQL_SCHEMA%.jwt_token as (
  role text,
  person_id integer
);

-- add auth function
create function %PSQL_SCHEMA%.authenticate(
  email text,
  password text
) returns %PSQL_SCHEMA%.jwt_token as $$
declare
  account %PSQL_SCHEMA%_private.person_account;
begin
  select a.* into account
  from %PSQL_SCHEMA%_private.person_account as a
  where a.email = $1;

  if account.password_hash = crypt(password, account.password_hash) then
    return ('%PSQL_SCHEMA%_person', account.person_id)::%PSQL_SCHEMA%.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;

comment on function %PSQL_SCHEMA%.authenticate(text, text) is 'Creates a JWT token that will securely identify a person and give them certain permissions.';

-- add  current person function
create or replace function %PSQL_SCHEMA%.current_person() returns %PSQL_SCHEMA%.person as $$
  declare 
    person %PSQL_SCHEMA%.person;
  begin
    select * into person
      from %PSQL_SCHEMA%.person
      where id = current_setting('jwt.claims.person_id')::integer;
      return person;
  exception
    when SQLSTATE '42704' then
      return null;
  end;
$$ language plpgsql stable;

comment on function %PSQL_SCHEMA%.current_person() is 'Gets the person who was identified by our JWT.';
grant execute on function %PSQL_SCHEMA%.current_person() to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;

-- grants
-- after schema creation and before function creation
alter default privileges revoke execute on functions from public;

grant usage on schema %PSQL_SCHEMA% to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;

grant select on table %PSQL_SCHEMA%.person to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant update, delete on table %PSQL_SCHEMA%.person to %PSQL_SCHEMA%_person;

grant select on table %PSQL_SCHEMA%.post to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant insert, update, delete on table %PSQL_SCHEMA%.post to %PSQL_SCHEMA%_person;
grant usage on sequence %PSQL_SCHEMA%.post_id_seq to %PSQL_SCHEMA%_person;

grant execute on function %PSQL_SCHEMA%.person_full_name(%PSQL_SCHEMA%.person) to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant execute on function %PSQL_SCHEMA%.post_summary(%PSQL_SCHEMA%.post, integer, text) to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant execute on function %PSQL_SCHEMA%.person_latest_post(%PSQL_SCHEMA%.person) to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant execute on function %PSQL_SCHEMA%.search_posts(text) to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant execute on function %PSQL_SCHEMA%.authenticate(text, text) to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant execute on function %PSQL_SCHEMA%.current_person() to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;

grant execute on function %PSQL_SCHEMA%.register_person(text, text, text, text) to %PSQL_SCHEMA%_anonymous;

-- enable row-level security
alter table %PSQL_SCHEMA%.person enable row level security;
alter table %PSQL_SCHEMA%.post enable row level security;

-- read policy for anybody
create policy select_person on %PSQL_SCHEMA%.person for select
  using (true);

create policy select_post on %PSQL_SCHEMA%.post for select
  using (true);

-- write/delete policies for logged in persons on their own accts
create policy update_person on %PSQL_SCHEMA%.person for update to %PSQL_SCHEMA%_person
  using (id = current_setting('jwt.claims.person_id')::integer);

create policy delete_person on %PSQL_SCHEMA%.person for delete to %PSQL_SCHEMA%_person
  using (id = current_setting('jwt.claims.person_id')::integer);

-- post policies
create policy insert_post on %PSQL_SCHEMA%.post for insert to %PSQL_SCHEMA%_person
  with check (author_id = current_setting('jwt.claims.person_id')::integer);

create policy update_post on %PSQL_SCHEMA%.post for update to %PSQL_SCHEMA%_person
  using (author_id = current_setting('jwt.claims.person_id')::integer);

create policy delete_post on %PSQL_SCHEMA%.post for delete to %PSQL_SCHEMA%_person
  using (author_id = current_setting('jwt.claims.person_id')::integer);
