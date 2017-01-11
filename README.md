This project aims to improve Rails Scaffold allowing to apply pre-defined templates by the developer.

Preparation:

1 - Create the template that should be used. These templates are in the `models/<your model folder>/`

Attention with the tags that should be part of each file, they have the format `##{tag_name}`

2 - Create a json file with the database table information, as shown below:

`{
  "project"   : "beta_project",
  "model"     : "default",
  "table"     : "post",
  "plural"    : "posts",
  "policy"    : "admin,manager",
  "output"    : "local",
  "has_many"  : "perguntas,respostas",  
  "fields"    :    
  [
    { "name":"name",      "type":"string", "search":"y", "index_partial":"y" } ,
    { "name":"content",   "type":"blob" },
    { "name":"tags",      "type":"string", "search":"y" },
    { "name":"other_table_id",  "type":"integer", "select_table":"Othertable.all", "select_id":"id", "select_show":"description", "index":"n" },    
    { "name":"start_show","type":"date" },
    { "name":"end_show",  "type":"datetime" },
    { "name":"role",      "type":"enum", "enum_list":":user, :manager, :admin" },
    { "name":"xpto_id",   "type":"hidden", "value":"@xpto.id" }
  ]
}`

Parameters
- project: project name
- model: subdirectory where the template is
- table: table name
- plural: plural of table name
- policy: user types to add in policy files
- output: place to save output files. "project" or "local"
- has_many: has_many tables (plural mandatory)

Field's Parameters
- name (required)
- type (required): strig, integer, float, date, datetime, hidden, blob
- search: "y" if this field in search field in index.html
- value: value to field in new.html
- align: used to define <td align=""> in index.html center, left, right
- precision: define qty decimal digits 
- index: "n" define this field will not appear in index.html
- index_link: define field as link_to show.html
- select_table: Ruby command to load collection of f.collect_select. example: Table.all or Table.select(:id, :xpto) or Table.where("xpto like ?", variable)
- select_id: field to set field[name]
- select_show: field which show in combobox
- enum: indicate a integer field set from enum list, defined in table's model
