-- register admin
-- TODO make admin group when ACL is done
select %PSQL_SCHEMA%.register_person('%ADMIN_FIRST_NAME%', '%ADMIN_LAST_NAME%', '%ADMIN_EMAIL%', '%ADMIN_PASSWORD%');
