-- create schemas
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

-- create a new enum type
create type pta_dist_14.post_topic as enum (
  'discussion',
  'inspiration',
  'help',
  'showcase'
);

-- create the post table
create table pta_dist_14.post (
  id               serial primary key,
  author_id        integer not null references pta_dist_14.person(id),
  headline         text not null check (char_length(headline) < 280),
  body             text,
  topic            pta_dist_14.post_topic,
  created_at       timestamp default now()
);

-- add some annotations
comment on table pta_dist_14.post is 'A forum post written by a person.';
comment on column pta_dist_14.post.id is 'The primary key for the post.';
comment on column pta_dist_14.post.headline is 'The title written by the person.';
comment on column pta_dist_14.post.author_id is 'The id of the author person.';
comment on column pta_dist_14.post.topic is 'The topic this has been posted in.';
comment on column pta_dist_14.post.body is 'The main body text of our post.';
comment on column pta_dist_14.post.created_at is 'The time this post was created.';

-- create full name function
create function pta_dist_14.person_full_name(person pta_dist_14.person) returns text as $$
	select person.first_name || ' ' || person.last_name
$$ language sql stable;

comment on function pta_dist_14.person_full_name(pta_dist_14.person) is 'A person’s full name which is a concatenation of their first and last name.';

-- create post summary function
create function pta_dist_14.post_summary(
  post pta_dist_14.post,
  length int default 50,
  omission text default '…'
) returns text as $$
  select case
    when post.body is null then null
    else substr(post.body, 0, length) || omission
  end
$$ language sql stable;

comment on function pta_dist_14.post_summary(pta_dist_14.post, int, text) is 'A truncated version of the body for summaries.';

-- latest post function
create function pta_dist_14.person_latest_post(person pta_dist_14.person) returns pta_dist_14.post as $$
  select post.*
  from pta_dist_14.post as post
  where post.author_id = person.id
  order by created_at desc
  limit 1
$$ language sql stable;

comment on function pta_dist_14.person_latest_post(pta_dist_14.person) is 'Get’s the latest post written by the person.';

-- search post function
create function pta_dist_14.search_posts(search text) returns setof pta_dist_14.post as $$
  select post.*
  from pta_dist_14.post as post
  where post.headline ilike ('%' || search || '%') or post.body ilike ('%' || search || '%')
$$ language sql stable;

comment on function pta_dist_14.search_posts(text) is 'Returns posts containing a given search term.';

-- add updated columns
alter table pta_dist_14.person add column updated_at timestamp default now();
alter table pta_dist_14.post add column updated_at timestamp default now();

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

create trigger post_updated_at before update
  on pta_dist_14.post
  for each row
  execute procedure pta_dist_14_private.set_updated_at();
