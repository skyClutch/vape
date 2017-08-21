-- add pgcrypto
create extension if not exists "pgcrypto";

-- add private person account table
create table jff_private.person_account (
  person_id        integer primary key references jff.person(id) on delete cascade,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

comment on table jff_private.person_account is 'Private information about a person’s account.';
comment on column jff_private.person_account.person_id is 'The id of the person associated with this account.';
comment on column jff_private.person_account.email is 'The email address of the person.';
comment on column jff_private.person_account.password_hash is 'An opaque hash of the person’s password.';

-- register person function
create function jff.register_person(
  first_name text,
  last_name text,
  email text,
  password text
) returns jff.person as $$
declare
  person jff.person;
begin
  insert into jff.person (first_name, last_name) values
    (first_name, last_name)
    returning * into person;

  insert into jff_private.person_account (person_id, email, password_hash) values
    (person.id, email, crypt(password, gen_salt('bf')));

  return person;
end;
$$ language plpgsql strict security definer;

comment on function jff.register_person(text, text, text, text) is 'Registers a single person and creates an account in our forum.';

-- create some roles
drop role if exists jff_postgraphql;
create role jff_postgraphql login password '49a00d7ad6cc43aa0f42c877c5b2353095db63a8';

drop role if exists jff_anonymous;
create role jff_anonymous;
grant jff_anonymous to jff_postgraphql;

drop role if exists jff_person;
create role jff_person;
grant jff_person to jff_postgraphql;

drop role if exists jff_contributor;
create role jff_contributor;
grant jff_contributor to jff_postgraphql;

drop role if exists jff_moderator;
create role jff_moderator;
grant jff_moderator to jff_postgraphql;

drop role if exists jff_admin;
create role jff_admin;
grant jff_admin to jff_postgraphql;

-- create token type
create type jff.jwt_token as (
  role text,
  person_id integer
);

-- add auth function
create function jff.authenticate(
  email text,
  password text
) returns jff.jwt_token as $$
declare
  account jff_private.person_account;
begin
  select a.* into account
  from jff_private.person_account as a
  where a.email = $1;

  if account.password_hash = crypt(password, account.password_hash) then
    return ('jff_person', account.person_id)::jff.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;

comment on function jff.authenticate(text, text) is 'Creates a JWT token that will securely identify a person and give them certain permissions.';

-- add  current person function
create or replace function jff.current_person() returns jff.person as $$
  declare 
    person jff.person;
  begin
    select * into person
      from jff.person
      where id = current_setting('jwt.claims.person_id')::integer;
      return person;
  exception
    when SQLSTATE '42704' then
      return null;
  end;
$$ language plpgsql stable;

comment on function jff.current_person() is 'Gets the person who was identified by our JWT.';
grant execute on function jff.current_person() to jff_anonymous, jff_person;

-- grants
-- after schema creation and before function creation
alter default privileges revoke execute on functions from public;

grant usage on schema jff to jff_anonymous, jff_person;

grant select on table jff.person to jff_anonymous, jff_person;
grant update, delete on table jff.person to jff_person;

grant select on table jff.post to jff_anonymous, jff_person;
grant insert, update, delete on table jff.post to jff_person;
grant usage on sequence jff.post_id_seq to jff_person;

grant execute on function jff.person_full_name(jff.person) to jff_anonymous, jff_person;
grant execute on function jff.post_summary(jff.post, integer, text) to jff_anonymous, jff_person;
grant execute on function jff.person_latest_post(jff.person) to jff_anonymous, jff_person;
grant execute on function jff.search_posts(text) to jff_anonymous, jff_person;
grant execute on function jff.authenticate(text, text) to jff_anonymous, jff_person;
grant execute on function jff.current_person() to jff_anonymous, jff_person;

grant execute on function jff.register_person(text, text, text, text) to jff_anonymous;

-- enable row-level security
alter table jff.person enable row level security;
alter table jff.post enable row level security;

-- read policy for anybody
create policy select_person on jff.person for select
  using (true);

create policy select_post on jff.post for select
  using (true);

-- write/delete policies for logged in persons on their own accts
create policy update_person on jff.person for update to jff_person
  using (id = current_setting('jwt.claims.person_id')::integer);

create policy delete_person on jff.person for delete to jff_person
  using (id = current_setting('jwt.claims.person_id')::integer);

-- post policies
create policy insert_post on jff.post for insert to jff_person
  with check (author_id = current_setting('jwt.claims.person_id')::integer);

create policy update_post on jff.post for update to jff_person
  using (author_id = current_setting('jwt.claims.person_id')::integer);

create policy delete_post on jff.post for delete to jff_person
  using (author_id = current_setting('jwt.claims.person_id')::integer);
