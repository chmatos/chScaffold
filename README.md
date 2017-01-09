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

Field's Parameters
- name (required)
- type (required): strig, integer, float, date, datetime, hidden, blob
- search: "y" if this field in search field in index.html
- value: value to field in new.html
- align: used to define <td align=""> in index.html center, left, right
- precision: define qty decimal digits 
- index: "n" define this field will not appear in index.html
- index_link: define field as link_to show.html

