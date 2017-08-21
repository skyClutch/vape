-- create a new enum type
create type %PSQL_SCHEMA%.post_topic as enum (
  'discussion',
  'inspiration',
  'help',
  'showcase'
);

-- create the post table
create table %PSQL_SCHEMA%.post (
  id               serial primary key,
  author_id        integer not null references %PSQL_SCHEMA%.person(id),
  headline         text not null check (char_length(headline) < 280),
  body             text,
  topic            %PSQL_SCHEMA%.post_topic,
  created_at       timestamp default now()
);

-- add some annotations
comment on table  %PSQL_SCHEMA%.post is 'A forum post written by a person.';
comment on column %PSQL_SCHEMA%.post.id is 'The primary key for the post.';
comment on column %PSQL_SCHEMA%.post.headline is 'The title written by the person.';
comment on column %PSQL_SCHEMA%.post.author_id is 'The id of the author person.';
comment on column %PSQL_SCHEMA%.post.topic is 'The topic this has been posted in.';
comment on column %PSQL_SCHEMA%.post.body is 'The main body text of our post.';
comment on column %PSQL_SCHEMA%.post.created_at is 'The time this post was created.';

-- create post summary function
create function %PSQL_SCHEMA%.post_summary(
  post %PSQL_SCHEMA%.post,
  length int default 50,
  omission text default '…'
) returns text as $$
  select case
    when post.body is null then null
    else substr(post.body, 0, length) || omission
  end
$$ language sql stable;

comment on function %PSQL_SCHEMA%.post_summary(%PSQL_SCHEMA%.post, int, text) is 'A truncated version of the body for summaries.';

-- latest post function
create function %PSQL_SCHEMA%.person_latest_post(person %PSQL_SCHEMA%.person) returns %PSQL_SCHEMA%.post as $$
  select post.*
  from %PSQL_SCHEMA%.post as post
  where post.author_id = person.id
  order by created_at desc
  limit 1
$$ language sql stable;

comment on function %PSQL_SCHEMA%.person_latest_post(%PSQL_SCHEMA%.person) is 'Get’s the latest post written by the person.';

-- search post function
create function %PSQL_SCHEMA%.search_posts(search text) returns setof %PSQL_SCHEMA%.post as $$
  select post.*
  from %PSQL_SCHEMA%.post as post
  where post.headline ilike ('%' || search || '%') or post.body ilike ('%' || search || '%')
$$ language sql stable;

comment on function %PSQL_SCHEMA%.search_posts(text) is 'Returns posts containing a given search term.';

-- add updated at
alter table %PSQL_SCHEMA%.post add column updated_at timestamp default now();

-- add triggers and function for update
create trigger post_updated_at before update
  on %PSQL_SCHEMA%.post
  for each row
  execute procedure %PSQL_SCHEMA%_private.set_updated_at();
