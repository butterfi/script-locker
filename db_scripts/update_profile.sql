-- history of statements used to massage username

-- change format from: display name (uid) to: display name - uid
update users 
set name = replace(name, " ("," - ");

update users
set name = replace(name, ")","");


-- update user.name with ctp.field_display_name_value, ignore those errors it's a mysql brokenness
update ignore users, node, content_type_profile
set users.name=concat(content_type_profile.field_display_name_value ," - ",users.uid)
where users.uid=node.uid and
users.uid=users.name and
users.name is not null and
users.uid>0 and
node.type='profile' and
node.nid=content_type_profile.nid


-- or --
update users, node, content_type_profile
set users.name=concat(content_type_profile.field_display_name_value ," - ",users.uid)
where users.uid=node.uid and
users.uid=users.name and
users.name is not null and
users.uid+0>0 and
node.type='profile' and
node.nid=content_type_profile.nid


-- find all of the people who will be updated
select  u.uid, u.name, ctp.field_display_name_value
from users u, node n, content_type_profile ctp
where
u.uid=n.uid and
u.name is not null and 
u.uid=u.name and
u.name+0>0 and
n.type='profile' and
n.nid=ctp.nid


----------
-- there are some users with null display names, update them from their node.title
update node, content_type_profile 
set content_type_profile.field_display_name_value=node.title
where content_type_profile.field_display_name_value is null
and content_type_profile.nid=node.nid
and node.type='profile';


select ctp.field_display_name_value, n.title
from content_type_profile ctp, node n
where ctp.nid=n.nid
and n.type='profile'
and ctp.field_display_name_value is null
;


----------
REPAIR TABLE tbl_name QUICK;