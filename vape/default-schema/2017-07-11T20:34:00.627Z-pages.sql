-- create page table
create table %PSQL_SCHEMA%.page (
  id               serial primary key,
  route            text not null check (char_length(route) < 2000),
  name             text not null check (char_length(route) < 280),
  template         text not null check (char_length(route) < 280),
  data             jsonb not null,
  created_at       timestamp default now(),
  updated_at       timestamp default now()
);

-- page docs
comment on table %PSQL_SCHEMA%.page is 'A collection of pages for the app';
comment on column %PSQL_SCHEMA%.page.route is 'The route where this page should be shown';
comment on column %PSQL_SCHEMA%.page.name is 'The page name';
comment on column %PSQL_SCHEMA%.page.template is 'The page template file';
comment on column %PSQL_SCHEMA%.page.data is 'Static data for the page template';

-- create a trigger
create trigger page_updated_at before update
  on %PSQL_SCHEMA%.page
  for each row
  execute procedure %PSQL_SCHEMA%_private.set_updated_at();

-- permissions
-- TODO make admin when ACL is done
grant select on table %PSQL_SCHEMA%.page to %PSQL_SCHEMA%_anonymous, %PSQL_SCHEMA%_person;
grant update on table %PSQL_SCHEMA%.page to %PSQL_SCHEMA%_person;
grant insert on table %PSQL_SCHEMA%.page to %PSQL_SCHEMA%_person;
grant delete on table %PSQL_SCHEMA%.page to %PSQL_SCHEMA%_person;
