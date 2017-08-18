-- add  current person function
create or replace function pta_dist_14.current_person() returns pta_dist_14.person as $$
  declare 
    person pta_dist_14.person;
  begin
    select * into person
      from pta_dist_14.person
      where id = current_setting('jwt.claims.person_id')::integer;
      return person;
  exception
    when SQLSTATE '42704' then
      return null;
  end;
$$ language plpgsql stable;

comment on function pta_dist_14.current_person() is 'Gets the person who was identified by our JWT.';
grant execute on function pta_dist_14.current_person() to pta_dist_14_anonymous, pta_dist_14_person;
