-- create page table
create table pta_dist_14.page (
  id               serial primary key,
  author_id        integer not null references pta_dist_14.person(id),
  route            text not null check (char_length(route) < 2000),
  title            text not null check (char_length(route) < 280),
  template         text,
  data             jsonb not null,
  style            text,
  created_at       timestamp default now(),
  updated_at       timestamp default now()
);

-- page docs
comment on table pta_dist_14.page is 'A collection of pages for the app';
comment on column pta_dist_14.page.author_id is 'The id of the person who created this page';
comment on column pta_dist_14.page.route is 'The route where this page should be shown';
comment on column pta_dist_14.page.title is 'The page title';
comment on column pta_dist_14.page.template is 'The page template';
comment on column pta_dist_14.page.data is 'Static data for the page template';
comment on column pta_dist_14.page.style is 'Extra style to apply to template';

-- add self reference
alter table pta_dist_14.page add column parent_id integer references pta_dist_14.page(id);
comment on column pta_dist_14.page.parent_id is 'Id of parent page';

-- create a trigger
create trigger page_updated_at before update
  on pta_dist_14.page
  for each row
  execute procedure pta_dist_14_private.set_updated_at();

-- permissions
grant select on table pta_dist_14.page to pta_dist_14_anonymous, pta_dist_14_person;
grant update on table pta_dist_14.page to pta_dist_14_person;
grant insert on table pta_dist_14.page to pta_dist_14_person;
grant delete on table pta_dist_14.page to pta_dist_14_person;
