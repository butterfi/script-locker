-- this list was imported into Email Networks Feb 3, 2010
-- users not in groups 
select distinct 
ctp.field_display_name_value as "name", 
n.uid as "uid", 
u.mail as "email",
ctp.field_profile_city_value as "city",
ctp.field_profile_zip_value as "zip",
ctp.field_profile_state_value as "state",
ctp.field_profile_country_value as "country"
from content_type_profile ctp, users u, node n
where ctp.nid= n.nid
and n.uid=u.uid 
and u.mail is not null 
and u.status=1
and n.uid not in (
select distinct n.uid
from content_type_profile ctp, users u, node n, og_uid o
where ctp.nid= n.nid
and n.uid=u.uid
and n.uid=o.uid
and o.is_active=1
and u.status=1)
order by n.uid