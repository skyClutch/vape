-- create page table
create table jff.page (
  id               serial primary key,
  route            text not null check (char_length(route) < 2000),
  name             text not null check (char_length(route) < 280),
  template         text not null check (char_length(route) < 280),
  data             jsonb not null,
  created_at       timestamp default now(),
  updated_at       timestamp default now()
);

-- page docs
comment on table jff.page is 'A collection of pages for the app';
comment on column jff.page.route is 'The route where this page should be shown';
comment on column jff.page.name is 'The page name';
comment on column jff.page.template is 'The page template file';
comment on column jff.page.data is 'Static data for the page template';

-- create a trigger
create trigger page_updated_at before update
  on jff.page
  for each row
  execute procedure jff_private.set_updated_at();

-- permissions
-- TODO make admin when ACL is done
grant select on table jff.page to jff_anonymous, jff_person;
grant update on table jff.page to jff_person;
grant insert on table jff.page to jff_person;
grant delete on table jff.page to jff_person;
