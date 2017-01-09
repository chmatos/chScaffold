JSON

{
  "project" : "beta_project",
  "table"   : "post",
  "plural"  : "posts",
  "policy"  : "admin,manager",
  "fields"  :    
  [
    { "name":"name",      "type":"string", "search":"y" } ,
    { "name":"content",   "type":"blob" },
    { "name":"tags",      "type":"string", "search":"y" },
    { "name":"start_show","type":"date" },
    { "name":"end_show",  "type":"datetime" },
    { "name":"xpto_id",   "type":"hidden", "value":"@xpto.id" }
  ]
}

Parameters
- project: project name
- table: table name
- plural: plural of table name
- policy: user types to add in policy files
- output: place to save output files. "project" or "local"

Field's Parameters
- name (required)
- type (required): strig, integer, float, date, datetime, hidden, blob
- search: "y" if this field in search field in index.html
- value: value to field in new.html
- align: used to define <td align=""> in index.html center, left, right
- precision: define qty decimal digits 
- index: "n" define this field will not appear in index.html
- index_link: define field as link_to show.html

