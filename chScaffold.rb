####################################################################################################
def grava(texto)
  puts texto
end

####################################################################################################
def mkdir(path)
  dirname = File.dirname(path)
  unless File.directory?(dirname)
    FileUtils.mkdir_p(dirname)
  end 
end

####################################################################################################
def substitui_campos(conteudo, data_hash)
  conteudo = conteudo.gsub('##{table.camelize}',     data_hash['table'].camelize)
  conteudo = conteudo.gsub('##{plural.camelize}',    data_hash['plural'].camelize)
  conteudo = conteudo.gsub('##{table.capitalize}',   data_hash['table'].capitalize)
  conteudo = conteudo.gsub('##{plural.capitalize}',  data_hash['plural'].capitalize)
  conteudo = conteudo.gsub('##{table.downcase}',     data_hash['table'].downcase)
  conteudo = conteudo.gsub('##{plural.downcase}',    data_hash['plural'].downcase)
  return conteudo
end

####################################################################################################
def gera_controller(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/controllers/.")
  fileout = "#{@directory_output}/app/controllers/#{data_hash['plural'].downcase}_controller.rb"

  # Cria campo Permit para ser substituido no Controller
  permit = ""
  data_hash['fields'].each do |field|
    if permit == ""
      permit += ":#{field['name']}"
    else
      permit += ", :#{field['name']}"
    end
  end
  
  # Carrega modelo e substitui campos
  conteudo = File.read('models/controller.rb')
  conteudo = substitui_campos(conteudo, data_hash)
  conteudo = conteudo.gsub('##{permit}', permit)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_helper(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/helpers/.")
  fileout = "#{@directory_output}/app/helpers/#{data_hash['plural'].downcase}_helper.rb"

  
  # Carrega modelo e substitui campos
  conteudo = File.read('models/helper.rb')
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_model(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/models/.")
  fileout = "#{@directory_output}/app/models/#{data_hash['table'].downcase}.rb"


  # Cria campo Search para ser substituido no Model
  search = ""
  data_hash['fields'].each do |field|
    next if field['search'] == nil
    if field['search'].downcase == "y"
      search = field['name'] 
      break
    end
  end  
  
  # Carrega modelo e substitui campos
  conteudo = File.read('models/model.rb')
  conteudo = conteudo.gsub('##{search}', search) if search != ""
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_form(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/_form.html.erb"

  # Cria field_list para ser substituido no _form
  field_list = gera_field_list(data_hash['fields']) 
  datapicker_list = gera_datapicker_list(data_hash['fields'])
  summernote_list = gera_summernote_list(data_hash['fields'])
  children_table_list = gera_children_table_list(data_hash)
  
  # Carrega modelo e substitui campos
  conteudo = File.read('models/_form.html')
  conteudo = conteudo.gsub('##{field_list}', field_list)
  conteudo = conteudo.gsub('##{datapicker_list}', datapicker_list)
  conteudo = conteudo.gsub('##{summernote_list}', summernote_list)
  conteudo = conteudo.gsub('##{children_table_list}', children_table_list)
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_new(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/new.html.erb"

  # Carrega modelo e substitui campos
  conteudo = File.read('models/new.html')
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_show(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/show.html.erb"

  # Carrega modelo e substitui campos
  conteudo = File.read('models/show.html')
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_edit(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/edit.html.erb"

  # Carrega modelo e substitui campos
  conteudo = File.read('models/edit.html')
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_index(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/index.html.erb"

  # Cria field_list para ser substituido no _index
  header_field_list = gera_header_field_list(data_hash['fields']) 
  detail_field_list = gera_detail_field_list(data_hash['fields']) 

  # Carrega modelo e substitui campos
  conteudo = File.read('models/index.html')
  conteudo = conteudo.gsub('##{header_field_list}', header_field_list) 
  conteudo = conteudo.gsub('##{detail_field_list}', detail_field_list) 
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_index_partial(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/_index.html.erb"

  # Cria field_list para ser substituido no _index
  header_field_list = gera_header_field_list(data_hash['fields'], partial: true) 
  detail_field_list = gera_detail_field_list(data_hash['fields'], partial: true) 

  # Carrega modelo e substitui campos
  conteudo = File.read('models/_index.html')
  conteudo = conteudo.gsub('##{header_field_list}', header_field_list) 
  conteudo = conteudo.gsub('##{detail_field_list}', detail_field_list) 
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_table_json_builder(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/_#{data_hash['table'].downcase}.json.jbuilder"

  # Cria campo Permit para ser substituido no Controller
  permit = ""
  data_hash['fields'].each do |field|
    if permit == ""
      permit += ":#{field['name']}"
    else
      permit += ", :#{field['name']}"
    end
  end
  
  # Carrega modelo e substitui campos
  conteudo = File.read('models/_table.json.jbuilder')
  conteudo = substitui_campos(conteudo, data_hash)
  conteudo = conteudo.gsub('##{permit}', permit)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_index_json_builder(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/index.json.jbuilder"

  # Carrega modelo e substitui campos
  conteudo = File.read('models/index.json.jbuilder')
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_show_json_builder(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/show.json.jbuilder"

  # Carrega modelo e substitui campos
  conteudo = File.read('models/show.json.jbuilder')
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_field_list(fields)
  field_list = ""
  fields.each do |field|
    case field['type'].downcase
      when 'hidden'
        field_list += File.read('models/_form_field_hidden.html')
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_value}', field['value'])      
      when 'string'
        field_list += File.read('models/_form_field.html')
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_type}', 'text_field')
      when 'integer','float'
        field_list += File.read('models/_form_field.html')
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_type}', 'number_field')      
      when 'date','datetime'
        field_list += File.read('models/_form_field_date.html')
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_type}', 'text_field')
      when 'blob'
      else 
    end
  end
  return field_list
end

####################################################################################################
def gera_header_field_list(fields, partial: false)
  header_field_list = ""
  fields.each do |field|
    next if field['index'] != nil and field['index'].downcase == 'n'
    next if partial and (field['index_partial'] == nil or field['index_partial'].downcase != 'y')
    header_field_list += File.read('models/_index_header.html')
    header_field_list = header_field_list.gsub('##{field_name}', field['name'])
    header_field_list = header_field_list.gsub('##{field_name.camelize}', field['name'].camelize)
  end
  return header_field_list
end

####################################################################################################
def gera_detail_field_list(fields, partial: false)
  detail_field_list = ""
  fields.each do |field|
    next if field['index'] != nil and field['index'].downcase == 'n'
    next if partial and (field['index_partial'] == nil or field['index_partial'].downcase != 'y')
    case field['type'].downcase
      when 'hidden'   
      when 'string'
        detail_field_list += File.read('models/_index_field_string.html')      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read('models/_index_field_string_link.html') if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
      when 'integer'
        detail_field_list += File.read('models/_index_field_number.html')      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read('models/_index_field_number_link.html') if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
        precision = field['precision'] != '' ? field['precision'] : 0
        detail_field_list = detail_field_list.gsub('##{precision}', precision)       
      when 'float'
        detail_field_list += File.read('models/_index_field_number.html')      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read('models/_index_field_number_link.html') if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)   
        precision = field['precision'] != '' ? field['precision'] : 2
        detail_field_list = detail_field_list.gsub('##{precision}', precision)       
      when 'date','datetime'
        detail_field_list += File.read('models/_index_field_date.html')      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read('models/_index_field_date_link.html') if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
      when 'blob'
      else 
    end
  end
  return detail_field_list
end

####################################################################################################
def gera_datapicker_list(fields)
  datapicker_list = ""
  fields.each do |field|
    case field['type'].downcase
      when 'date','datetime'
        datapicker_list += File.read('models/jquery_datapicker_date')
        datapicker_list = datapicker_list.gsub('##{field_name}', field['name'])
      else 
    end
  end
  return datapicker_list
end

####################################################################################################
def gera_summernote_list(fields)
  summernote_list = ""
  fields.each do |field|
    case field['type'].downcase
      when 'blob'
        #summernote_list += File.read('models/jquery_summernote')
        #summernote_list = summernote_list.gsub('##{field_name}', field['name'])
      else 
    end
  end
  return summernote_list
end

####################################################################################################
def gera_children_table_list(data_hash)
  children_table_list = ""
  children_tables = data_hash['children'].split(',')
  children_tables.each do |children_table|
    children_table_list += File.read('models/index_partial.html')
    children_table_list = children_table_list.gsub('##{children_table}', children_table.gsub(/\s+/, ""))
  end
  return children_table_list
end

####################################################################################################
def gera_policy(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/policies/.")
  fileout = "#{@directory_output}/app/policies/#{data_hash['table'].downcase}_policy.rb"


  # Cria Policy Default
  linha_policy = ""
  policies = data_hash['policy'].split(',')
  policies.each do |policy|
    if linha_policy == ""
      linha_policy += "@current_user.#{policy.gsub(/\s+/, "")}?"
    else
      linha_policy += " or @current_user.#{policy.gsub(/\s+/, "")}?"
    end
  end
  
  # Carrega modelo e substitui campos
  conteudo = File.read('models/policy.rb')
  conteudo = substitui_campos(conteudo, data_hash)
  conteudo = conteudo.gsub('##{policy}', linha_policy)

  grava(fileout,conteudo)
end

def grava(fileout,conteudo)
  # Grava Controller
  FileUtils.rm(fileout) if File.exist?(fileout)
  File.open(fileout, "w+") do |f|
    f.write(conteudo)
  end  
  puts "created: #{fileout}"
end

####################################################################################################
class String
  def camelize
    self.split("_").each {|s| s.capitalize! }.join("")
  end
  def camelize!
    self.replace(self.split("_").each {|s| s.capitalize! }.join(""))
  end
  def underscore
    self.scan(/[A-Z][a-z]*/).join("_").downcase
  end
  def underscore!
    self.replace(self.scan(/[A-Z][a-z]*/).join("_").downcase)
  end
end

####################################################################################################
# Main
####################################################################################################
require 'json'
require 'fileutils'

file = File.read("#{ARGV[0]}.json")
data_hash = JSON.parse(file)

puts "Project=#{data_hash['project']}"
puts "Table=#{data_hash['table']}"
puts "Plural=#{data_hash['plural']}"
puts ""
puts "Fields:"

data_hash['fields'].each do |field|
  puts "#{field['name']}=[#{field['type']}]"
end
puts ""

# Pega nome do arquivo nos parametros de entrada da linha de comando
if data_hash['output'].downcase == 'local'
  @directory_output = "out/#{data_hash['project']}"
else
  @directory_output = "../#{data_hash['project']}"
end

gera_controller(data_hash)
gera_helper(data_hash)
gera_model(data_hash)
gera_policy(data_hash)
gera_form(data_hash)
gera_new(data_hash)
gera_show(data_hash)
gera_edit(data_hash)
gera_index(data_hash)
gera_index_partial(data_hash)
gera_table_json_builder(data_hash)
gera_index_json_builder(data_hash)
gera_show_json_builder(data_hash)
