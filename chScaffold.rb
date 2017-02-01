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
  conteudo = conteudo.gsub('##{table.camelize}',    data_hash['table'].camelize)
  conteudo = conteudo.gsub('##{plural.camelize}',   data_hash['plural'].camelize)
  conteudo = conteudo.gsub('##{table.capitalize}',  data_hash['table'].capitalize)
  conteudo = conteudo.gsub('##{plural.capitalize}', data_hash['plural'].capitalize)
  conteudo = conteudo.gsub('##{table.downcase}',    data_hash['table'].downcase)
  conteudo = conteudo.gsub('##{plural.downcase}',   data_hash['plural'].downcase)
  #conteudo = conteudo.gsub('##{belongs_to}',        data_hash['belongs_to'].downcase) if data_hash['belongs_to'] != nil  
  return conteudo
end

####################################################################################################
def gera_controller(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/controllers/.")
  fileout = "#{@directory_output}/app/controllers/#{data_hash['plural'].downcase}_controller.rb"

  return if data_hash['files'] != nil and data_hash['files'][0]['controller'] != nil and data_hash['files'][0]['controller'] == 'skip_if_exist' and File.exist?(fileout)

  # Cria campo Permit para ser substituido no Controller
  permit = gera_permit(data_hash)
  nested_build_children = gera_nested_build_children(data_hash)
  
  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/controller.rb")
  conteudo = substitui_campos(conteudo, data_hash)
  conteudo = conteudo.gsub('##{permit}', permit)
  conteudo = conteudo.gsub('##{nested_build_children}', nested_build_children)
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_helper(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/helpers/.")
  fileout = "#{@directory_output}/app/helpers/#{data_hash['plural'].downcase}_helper.rb"

  return if data_hash['files'] != nil and data_hash['files'][0]['helper'] != nil and data_hash['files'][0]['helper'] == 'skip_if_exist' and File.exist?(fileout)

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/helper.rb")
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_model(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/models/.")
  fileout = "#{@directory_output}/app/models/#{data_hash['table'].downcase}.rb"

  return if data_hash['files'] != nil and data_hash['files'][0]['model'] != nil and data_hash['files'][0]['model'] == 'skip_if_exist' and File.exist?(fileout)

  # Gera listas para substituicao
  has_many_list                 = gera_has_many_list(data_hash)
  has_many_destroy_list         = gera_has_many_destroy_list(data_hash)
  belongs_to_list               = gera_belongs_to_list(data_hash)
  has_and_belongs_to_many_list  = gera_has_and_belongs_to_many_list(data_hash)
  enum_list                     = gera_enum_list(data_hash)
  nested_list                   = gera_nested_model(data_hash)

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
  conteudo = File.read("models/#{@model}/model.rb")
  conteudo = conteudo.gsub('##{search}', search) if search != ""
  conteudo = conteudo.gsub('##{has_many_list}', has_many_list) 
  conteudo = conteudo.gsub('##{has_many_destroy_list}', has_many_destroy_list) 
  conteudo = conteudo.gsub('##{nested_list}', nested_list) 
  conteudo = conteudo.gsub('##{belongs_to_list}', belongs_to_list) 
  conteudo = conteudo.gsub('##{has_and_belongs_to_many_list}', has_and_belongs_to_many_list) 
  conteudo = conteudo.gsub('##{enum_list}', enum_list) 
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_form(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/_form.html.erb"

  return if data_hash['files'] != nil and data_hash['files'][0]['form'] != nil and data_hash['files'][0]['form'] == 'skip_if_exist' and File.exist?(fileout)

  # Cria field_list para ser substituido no _form
  field_list = gera_field_list(data_hash['fields']) 
  datapicker_list = gera_datapicker_list(data_hash['fields'])
  summernote_list = gera_summernote_list(data_hash['fields'])
  dual_select = gera_dual_select(data_hash['fields'])
  render_list = gera_render_index(data_hash)
  render_list = gera_render_nested(data_hash, render_list)

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/_form.html")
  conteudo = conteudo.gsub('##{field_list}', field_list)
  conteudo = conteudo.gsub('##{datapicker_list}', datapicker_list)
  conteudo = conteudo.gsub('##{summernote_list}', summernote_list)
  conteudo = conteudo.gsub('##{dual_select}', dual_select)
  conteudo = conteudo.gsub('##{render_index_list}', render_list)
  conteudo = substitui_campos(conteudo, data_hash)

  add_summernote_files(data_hash)  if summernote_list != ''
  add_dual_select_files(data_hash) if dual_select != ''

  grava(fileout,conteudo)
end

####################################################################################################
def gera_new(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/new.html.erb"

  return if data_hash['files'] != nil and data_hash['files'][0]['new'] != nil and data_hash['files'][0]['new'] == 'skip_if_exist' and File.exist?(fileout)

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/new.html")
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_show(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/show.html.erb"

  return if data_hash['files'] != nil and data_hash['files'][0]['show'] != nil and data_hash['files'][0]['show'] == 'skip_if_exist' and File.exist?(fileout)

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/show.html")
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_edit(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/edit.html.erb"

  return if data_hash['files'] != nil and data_hash['files'][0]['edit'] != nil and data_hash['files'][0]['edit'] == 'skip_if_exist' and File.exist?(fileout)

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/edit.html")
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_index(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/index.html.erb"

  return if data_hash['files'] != nil and data_hash['files'][0]['index'] != nil and data_hash['files'][0]['index'] == 'skip_if_exist' and File.exist?(fileout)

  # Cria field_list para ser substituido no _index
  header_field_list = gera_header_field_list(data_hash['fields']) 
  detail_field_list = gera_detail_field_list(data_hash['fields']) 

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/index.html")
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

  return if data_hash['files'] != nil and data_hash['files'][0]['_index'] != nil and data_hash['files'][0]['_index'] == 'skip_if_exist' and File.exist?(fileout)

  # Cria field_list para ser substituido no _index
  header_field_list = gera_header_field_list(data_hash['fields'], partial: true) 
  detail_field_list = gera_detail_field_list(data_hash['fields'], partial: true) 

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/_index.html")
  conteudo = conteudo.gsub('##{header_field_list}', header_field_list) 
  conteudo = conteudo.gsub('##{detail_field_list}', detail_field_list) 
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_nested(data_hash)
  # Gera diretorio
  return if data_hash['nested_form'] == nil 
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/_#{data_hash['nested_form']['table_singular'].downcase}_fields.html.erb"

  return if data_hash['files'] != nil and data_hash['files'][0]['index'] != nil and data_hash['files'][0]['nested'] == 'skip_if_exist' and File.exist?(fileout)

  # Cria field_list para ser substituido no _index
  header_field_list = gera_header_field_list       (data_hash['nested_form']['fields']) 
  nested_field_list = gera_nested_detail_field_list(data_hash['nested_form']['fields']) 


  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/_nested.html")
  conteudo = conteudo.gsub('##{header_field_list}', header_field_list) 
  conteudo = conteudo.gsub('##{nested_field_list}', nested_field_list) 
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_table_json_builder(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/_#{data_hash['table'].downcase}.json.jbuilder"

  # Cria campo Permit para ser substituido no Controller
  permit = gera_permit(data_hash)
  
  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/_table.json.jbuilder")
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
  conteudo = File.read("models/#{@model}/index.json.jbuilder")
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_show_json_builder(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/views/#{data_hash['plural'].downcase}/.")
  fileout = "#{@directory_output}/app/views/#{data_hash['plural'].downcase}/show.json.jbuilder"

  # Carrega modelo e substitui campos
  conteudo = File.read("models/#{@model}/show.json.jbuilder")
  conteudo = substitui_campos(conteudo, data_hash)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_field_list(fields)
  field_list = ""
  fields.each do |field|
    case field['type'].downcase
      when 'hidden'
        field_list += File.read("models/#{@model}/_form_field_hidden.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_value}', field['value'])            
      when 'parent'
        field_list += File.read("models/#{@model}/_form_field_parent.html")    
        field_list = field_list.gsub('##{field_name_hidden}', field['name'])
        field_list = field_list.gsub('##{select_show}', ".#{field['parent_show']}") if field['parent_show'] != nil
        field_list = field_list.gsub('##{field_name}',  "#{field['name'].split('_')[0]}")
        if field['show'] != nil and field['show'] == 'y'
          field_list = field_list.gsub('##{show}', 'true') 
        else
          field_list = field_list.gsub('##{show}', 'false')
        end
      when 'string'
        field_list += File.read("models/#{@model}/_form_field.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_type}', 'text_field')
      when 'enum'
        field_list += File.read("models/#{@model}/_form_field_enum.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_name_plural}', field['name_plural'])
      when 'integer'
        field_list += File.read("models/#{@model}/_form_field.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_type}', 'number_field')           
      when 'select'
        field_list += File.read("models/#{@model}/_form_field_collect_select.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{select_table}', field['select_table']) if field['select_table'] != nil        
        field_list = field_list.gsub('##{select_id}', field['select_id'])       if field['select_id'] != nil        
        field_list = field_list.gsub('##{select_show}', field['select_show'])   if field['select_show'] != nil     
        include_blank = (field['include_blank'] != nil and field['include_blank'].downcase == 'y') ? ', include_blank: true' : ''
        p include_blank
        field_list = field_list.gsub('##{include_blank}', include_blank)
      when 'multselect'
        field_list += File.read("models/#{@model}/_form_field_multselect.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{select_table}', field['select_table'])     if field['select_table'] != nil        
        field_list = field_list.gsub('##{select_id}', field['select_id'])           if field['select_id'] != nil        
        field_list = field_list.gsub('##{select_show}', field['select_show'])       if field['select_show'] != nil      
        field_list = field_list.gsub('##{field_name_plural}', field['name_plural'])
      when 'float'
        field_list += File.read("models/#{@model}/_form_field.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_type}', 'number_field')      
      when 'date','datetime'
        field_list += File.read("models/#{@model}/_form_field_date.html")
        field_list = field_list.gsub('##{field_name}', field['name'])
        field_list = field_list.gsub('##{field_type}', 'text_field')
      when 'blob'
        field_list += File.read("models/#{@model}/_form_field_blob.html")
        field_list = field_list.gsub('##{field_name}', field['name'])    
      else 
    end
  end
  return field_list
end

####################################################################################################
def gera_nested_detail_field_list(fields)
  saida = ""
  fields.each do |field|
    case field['type'].downcase
      #when 'hidden'
      #  saida += File.read("models/#{@model}/_form_field_hidden.html")
      #  saida = saida.gsub('##{field_name}', field['name'])
      #  saida = saida.gsub('##{field_value}', field['value'])            
      #when 'parent'
      #  saida += File.read("models/#{@model}/_form_field_parent.html")    
      #  saida = saida.gsub('##{field_name}', field['name'])
      when 'string'
        saida += File.read("models/#{@model}/_nested_field.html")
        saida = saida.gsub('##{field_name}', field['name'])
        saida = saida.gsub('##{field_type}', 'text_field')
      when 'enum'
        saida += File.read("models/#{@model}/_nested_field_enum.html")
        saida = saida.gsub('##{field_name}', field['name'])
        saida = saida.gsub('##{field_name_plural}', field['name_plural'])
      when 'integer'
        saida += File.read("models/#{@model}/_nested_field.html")
        saida = saida.gsub('##{field_name}', field['name'])
        saida = saida.gsub('##{field_type}', 'number_field')           
      when 'select'
        saida += File.read("models/#{@model}/_nested_field_collect_select.html")
        saida = saida.gsub('##{field_name}', field['name'])
        saida = saida.gsub('##{select_table}', field['select_table']) if field['select_table'] != nil        
        saida = saida.gsub('##{select_id}', field['select_id'])       if field['select_id'] != nil        
        saida = saida.gsub('##{select_show}', field['select_show'])   if field['select_show'] != nil      
      #when 'multselect'
      #  saida += File.read("models/#{@model}_nested_field_multselect.html")
      #  saida = saida.gsub('##{field_name}', field['name'])
      #  saida = saida.gsub('##{select_table}', field['select_table'])     if field['select_table'] != nil        
      #  saida = saida.gsub('##{select_id}', field['select_id'])           if field['select_id'] != nil        
      #  saida = saida.gsub('##{select_show}', field['select_show'])       if field['select_show'] != nil      
      #  saida = saida.gsub('##{field_name_plural}', field['name_plural'])
      when 'float'
        saida += File.read("models/#{@model}/_nested_field.html")
        saida = saida.gsub('##{field_name}', field['name'])
        saida = saida.gsub('##{field_type}', 'number_field')      
      when 'date','datetime'
        saida += File.read("models/#{@model}/_nested_field_date.html")
        saida = saida.gsub('##{field_name}', field['name'])
        saida = saida.gsub('##{field_type}', 'text_field')
      when 'blob'
        saida += File.read("models/#{@model}/_nested_field_blob.html")
        saida = saida.gsub('##{field_name}', field['name'])    
      else 
    end
  end
  return saida
end

####################################################################################################
def gera_header_field_list(fields, partial: false)
  header_field_list = ""
  fields.each do |field|
    next if field['index'] != nil and field['index'].downcase == 'n'
    next if partial and (field['index_partial'] == nil or field['index_partial'].downcase != 'y')
    next if field['type'] == 'hidden'
    header_field_list += File.read("models/#{@model}/_index_header.html")
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
      when 'string','enum'
        detail_field_list += File.read("models/#{@model}/_index_field_string.html")      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read("models/#{@model}/_index_field_string_link.html") if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
      when 'integer'
        detail_field_list += File.read("models/#{@model}/_index_field_number.html")      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read("models/#{@model}/_index_field_number_link.html") if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
        precision = 0 
        precision = field['precision'] if field['precision'] != nil
        detail_field_list = detail_field_list.gsub('##{precision}', precision.to_s)       
      when 'float'
        detail_field_list += File.read("models/#{@model}/_index_field_number.html")      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read("models/#{@model}/_index_field_number_link.html") if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)   
        precision = 2 
        precision = field['precision'] if field['precision'] != nil
        detail_field_list = detail_field_list.gsub('##{precision}', precision)       
      when 'date','datetime'
        detail_field_list += File.read("models/#{@model}/_index_field_date.html")      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read("models/#{@model}/_index_field_date_link.html") if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
      when 'select'
        detail_field_list += File.read("models/#{@model}/_index_field_select.html")      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read("models/#{@model}/_index_field_select_link.html") if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}',  "#{field['name'].split('_')[0]}")
        detail_field_list = detail_field_list.gsub('##{select_show}', ".#{field['select_show']}")
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
      when 'parent'
        detail_field_list += File.read("models/#{@model}/_index_field_select.html")      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read("models/#{@model}/_index_field_select_link.html") if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}',  "#{field['name'].split('_')[0]}")
        detail_field_list = detail_field_list.gsub('##{select_show}', ".#{field['parent_show']}")  if field['parent_show'] != nil
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)
      when 'blob'
        detail_field_list += File.read("models/#{@model}/_index_field_blob.html")      if field['index_link'] == nil or  field['index_link'].downcase != 'y'
        detail_field_list += File.read("models/#{@model}/_index_field_blob_link.html") if field['index_link'] != nil and field['index_link'].downcase == 'y'
        detail_field_list = detail_field_list.gsub('##{field_name}', field['name'])
        align = field['align'] != nil ? field['align'] : 'left'
        detail_field_list = detail_field_list.gsub('##{align}', align)        
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
        datapicker_list += File.read("models/#{@model}/jquery_datapicker_date")
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
        summernote_list += File.read("models/#{@model}/jquery_summernote")
        summernote_list = summernote_list.gsub('##{field_name}', field['name'])
      else 
    end
  end
  return summernote_list
end

####################################################################################################
def gera_dual_select(fields)
  dual_select = ""
  fields.each do |field|
    case field['type'].downcase
      when 'multselect'
        dual_select += File.read("models/#{@model}/jquery_dual_select")
        break
        #dual_select = dual_select.gsub('##{field_name}', field['name'])
      else 
    end
  end
  return dual_select
end

####################################################################################################
def gera_has_many_list(data_hash)
  has_many_list = ""
  return has_many_list if data_hash['has_many'] == nil 

  has_manies = data_hash['has_many'].split(',')
  has_manies.each do |has_many|
    has_many_list += File.read("models/#{@model}/model_has_many.rb")
    has_many_list = has_many_list.gsub('##{has_many}', has_many.gsub(/\s+/, ""))
  end
  return has_many_list
end

####################################################################################################
def gera_has_many_destroy_list(data_hash)
  has_many_destroy_list = ""
  return has_many_destroy_list if data_hash['has_many_destroy'] == nil 

  has_manies = data_hash['has_many_destroy'].split(',')
  has_manies.each do |has_many|
    has_many_destroy_list += File.read("models/#{@model}/model_has_many_destroy.rb")
    has_many_destroy_list = has_many_destroy_list.gsub('##{has_many}', has_many.gsub(/\s+/, ""))
  end
  return has_many_destroy_list
end

####################################################################################################
def gera_nested_model(data_hash)
  nested_list = ""
  return nested_list if data_hash['nested_form'] == nil 

  nested_noblank = gera_nested_noblank(data_hash)

  #has_manies = data_hash['nested_form'].split(',')
  #has_manies.each do |has_many|
    nested_list += File.read("models/#{@model}/model_nested.rb")
    nested_list = nested_list.gsub('##{nested_table_plural}', data_hash['nested_form']['table_plural'])
    nested_list = nested_list.gsub('##{nested_noblank}', nested_noblank)
    #nested_list = nested_list.gsub('##{nested_table_plural}', has_many.gsub(/\s+/, ""))
  #end
  return nested_list
end

####################################################################################################
def gera_has_and_belongs_to_many_list(data_hash)
  has_and_belongs_to_many_list = ""
  return has_and_belongs_to_many_list if data_hash['has_and_belongs_to_many'] == nil 

  has_manies = data_hash['has_and_belongs_to_many'].split(',')
  has_manies.each do |has_and_belongs_to_many|
    puts has_and_belongs_to_many
    has_and_belongs_to_many_list += File.read("models/#{@model}/model_has_and_belongs_to_many.rb")
    has_and_belongs_to_many_list = has_and_belongs_to_many_list.gsub('##{has_and_belongs_to_many}', has_and_belongs_to_many.gsub(/\s+/, ""))
  end
  return has_and_belongs_to_many_list
end

####################################################################################################
def gera_belongs_to_list(data_hash)
  belongs_to_list = ""
  return belongs_to_list if data_hash['belongs_to'] == nil 

  belongs_tos = data_hash['belongs_to'].split(',')
  belongs_tos.each do |belongs_to|
    belongs_to_list += File.read("models/#{@model}/model_belongs_to.rb")
    belongs_to_list = belongs_to_list.gsub('##{belongs_to}', belongs_to.gsub(/\s+/, ""))
  end
  return belongs_to_list
end

####################################################################################################
def gera_enum_list(data_hash)
  enum_list = ""

  data_hash['fields'].each do |field|
    next if field['type'] != 'enum'
    enum_list += File.read("models/#{@model}/model_enum.rb")
    enum_list = enum_list.gsub('##{field_name}', field['name'])
    enum_list = enum_list.gsub('##{enum_list}',  field['enum_list'])
  end
  return enum_list
end

####################################################################################################
def gera_render_index(data_hash)
  render_index_list = ""
  return render_index_list if data_hash['has_many'] == nil and data_hash['has_many_destroy'] == nil
  return render_index_list if data_hash['nested_form'] != nil

  has_many_tables = data_hash['has_many'].split(',') if data_hash['has_many'] != nil
  has_many_tables = data_hash['has_many_destroy'].split(',') if data_hash['has_many_destroy'] != nil
  has_many_tables.each do |has_many_table|
    render_index_list += File.read("models/#{@model}/render_index.html")
    render_index_list = render_index_list.gsub('##{has_many_table}', has_many_table.gsub(/\s+/, ""))
  end
  return render_index_list
end

####################################################################################################
def gera_render_nested(data_hash, entrada)
  return entrada if data_hash['nested_form'] == nil

  header_field_list = gera_header_field_list(data_hash['nested_form']['fields'])  

  saida = File.read("models/#{@model}/render_nested.html")
  saida = saida.gsub('##{nested_form.table_singular}', data_hash['nested_form']['table_singular'])  if data_hash['nested_form']['table_singular'] != nil
  saida = saida.gsub('##{nested_form.table_plural}',   data_hash['nested_form']['table_plural'])    if data_hash['nested_form']['table_plural']   != nil
  saida = saida.gsub('##{nested_form.qty}',            data_hash['nested_form']['qty'])             if data_hash['nested_form']['qty']            != nil
  saida = saida.gsub('##{header_field_list}',          header_field_list)   

  return saida
end

####################################################################################################
def gera_policy(data_hash)
  # Gera diretorio
  mkdir("#{@directory_output}/app/policies/.")
  fileout = "#{@directory_output}/app/policies/#{data_hash['table'].downcase}_policy.rb"

  return if data_hash['files'] != nil and data_hash['files'][0]['policy'] != nil and data_hash['files'][0]['policy'] == 'skip_if_exist' and File.exist?(fileout)

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
  conteudo = File.read("models/#{@model}/policy.rb")
  conteudo = substitui_campos(conteudo, data_hash)
  conteudo = conteudo.gsub('##{policy}', linha_policy)

  grava(fileout,conteudo)
end

####################################################################################################
def gera_permit(data_hash)
  permit = ""
  data_hash['fields'].each do |field|
    permit += ", " if permit != ""
    permit += field['type'].downcase == 'multselect' ? "#{field['name']}_ids: []" : ":#{field['name']}"
  end  

  if data_hash['nested_form'] != nil
    permit += ", #{data_hash['nested_form']['table_plural']}_attributes: [:id"
    data_hash['nested_form']['fields'].each do |field|
      permit += ", " if permit != ""
      permit += ":#{field['name']}"
    end     
    permit += ", :_destroy]"
  end

  return permit
end

####################################################################################################
def gera_nested_noblank(data_hash)
  saida = ""
  data_hash['nested_form']['fields'].each do |field|
    next if field['noblank'] == nil or field['noblank'].downcase != 'y'
    saida += saida == '' ? ":reject_if => lambda { |a| a[:#{field['name']}].blank? " : "|| a[:#{field['name']}].blank? "
  end  

  saida += '},' if saida != ''
  return saida
end

####################################################################################################
def gera_nested_build_children(data_hash)
  nested_build_children = ""
  return nested_build_children if data_hash['nested_form'] == nil 

  #itens = data_hash['nested_form'].split(',')
  #itens.each do |item|
    nested_build_children += File.read("models/#{@model}/controller_nested.rb")
    nested_build_children = nested_build_children.gsub('##{nested_form.table_singular}', data_hash['nested_form']['table_singular'])  if data_hash['nested_form']['table_singular'] != nil
    nested_build_children = nested_build_children.gsub('##{nested_form.table_plural}',   data_hash['nested_form']['table_plural'])    if data_hash['nested_form']['table_plural']   != nil
    nested_build_children = nested_build_children.gsub('##{nested_form.qty}',            data_hash['nested_form']['qty'])             if data_hash['nested_form']['qty']            != nil
    #nested_build_children = nested_build_children.gsub('##{belongs_to}', item.gsub(/\s+/, ""))
  #end
  return nested_build_children
end

####################################################################################################
def grava(fileout,conteudo)
  FileUtils.rm(fileout) if File.exist?(fileout)
  File.open(fileout, "w+") do |f|
    f.write(conteudo)
  end  
  puts "created: #{fileout}"
end

####################################################################################################
def add_summernote_files(data_hash)
  add_gem(data_hash,'summernote-rails')
  add_in_file(data_hash, 'app/assets/javascripts/application.js', '//= require summernote/summernote.min.js', 'end')
  add_in_file(data_hash, 'app/assets/stylesheets/application.css', '//= require summernote/summernote-bs3.css', 'end')
  add_in_file(data_hash, 'app/assets/stylesheets/application.css', '//= require summernote/summernote.css', 'end')
end

####################################################################################################
def add_dual_select_files(data_hash)
  add_in_file(data_hash, 'app/assets/javascripts/application.js',  '//= require dualListbox/jquery.bootstrap-duallistbox.js', 'end')
  add_in_file(data_hash, 'app/assets/stylesheets/application.css', '//= require dualListbox/bootstrap-duallistbox.min.css', 'end')
end

####################################################################################################
def add_table_in_routes(data_hash)
  add_in_file(data_hash, 'config/routes.rb',"  resources :#{data_hash['plural']}", 2)
end

####################################################################################################
def add_gem(data_hash,gem)
  add_in_file(data_hash, 'Gemfile',"gem '" + gem + "'", 3)
end

####################################################################################################
def add_helpers_in_apllication_helper(data_hash)
  conteudo = File.read("models/#{@model}/number_format_helper.rb")
  add_in_file(data_hash, 'app/helpers/application_helper.rb',conteudo, 2)

  conteudo = File.read("models/#{@model}/is_show_helper.rb")
  add_in_file(data_hash, 'app/helpers/application_helper.rb',conteudo, 2)
end

####################################################################################################
def add_in_file(data_hash,file,campo,where)
  mkdir("#{@directory_output}/#{file}")
  fileout = "#{@directory_output}/#{file}"  

  conteudo = File.read(fileout) if File.exist?(fileout)
  if !conteudo.gsub(/\s+/, "").include? campo.to_s.gsub(/\s+/, "")
    case 
      when where == 'top'
        conteudo = "#{campo}\n#{conteudo}"
      when (where == 'end' or where == 'botton')
        conteudo = "#{conteudo}\n#{campo}" 
      #when (where.is_a? Integer)
      when where > 0
        #puts "where=#{where}"
        saida = ""
        line_count = 1
        conteudo = File.readlines(fileout) if File.exist?(fileout)
        #puts conteudo.count
        where_aux = where
        if where < 0
          counteudo = conteudo.reverse
          where_aux *= (-1)
        end
        conteudo.each do |line|
          #puts "where_aux=#{where_aux}"
          if line_count == where_aux.to_i
            saida += "#{campo}\n"
            line_count += 1
          end  
          saida += "#{line}"
          #puts line if line.gsub(/\s+/, "") != ""
          line_count += 1 if line.gsub(/\s+/, "") != ""
          #puts line_count
        end
        if where > 0
          #puts "where > 0"
          conteudo = saida
        else
          #puts "where < 0"
          counteudo = saida.reverse
        end
      else
    end
  end

  grava(fileout,conteudo)
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

# Monta o nome do Modelo a ser usado
if data_hash['model'] == nil
  @model = 'default'
else
  @model = data_hash['model']
end

gera_controller(data_hash)    if data_hash['files'] == nil        or data_hash['files'][0]['controller']  == nil or (data_hash['files'][0]['controller']  != nil and data_hash['files'][0]['controller']  != 'skip')
gera_helper(data_hash)        if data_hash['files'] == nil        or data_hash['files'][0]['helper']      == nil or (data_hash['files'][0]['helper']      != nil and data_hash['files'][0]['helper']      != 'skip')
gera_model(data_hash)         if data_hash['files'] == nil        or data_hash['files'][0]['model']       == nil or (data_hash['files'][0]['model']       != nil and data_hash['files'][0]['model']       != 'skip')
gera_policy(data_hash)        if data_hash['files'] == nil        or data_hash['files'][0]['policy']      == nil or (data_hash['files'][0]['policy']      != nil and data_hash['files'][0]['policy']      != 'skip')
gera_form(data_hash)          if data_hash['files'] == nil        or data_hash['files'][0]['_form']       == nil or (data_hash['files'][0]['_form']       != nil and data_hash['files'][0]['_form']       != 'skip')
gera_new(data_hash)           if data_hash['files'] == nil        or data_hash['files'][0]['new']         == nil or (data_hash['files'][0]['new']         != nil and data_hash['files'][0]['new']         != 'skip')
gera_show(data_hash)          if data_hash['files'] == nil        or data_hash['files'][0]['show']        == nil or (data_hash['files'][0]['show']        != nil and data_hash['files'][0]['show']        != 'skip')
gera_edit(data_hash)          if data_hash['files'] == nil        or data_hash['files'][0]['edit']        == nil or (data_hash['files'][0]['edit']        != nil and data_hash['files'][0]['edit']        != 'skip')
gera_index(data_hash)         if data_hash['files'] == nil        or data_hash['files'][0]['index']       == nil or (data_hash['files'][0]['index']       != nil and data_hash['files'][0]['index']       != 'skip')
gera_index_partial(data_hash) if data_hash['files'] == nil        or data_hash['files'][0]['_index']      == nil or (data_hash['files'][0]['_index']      != nil and data_hash['files'][0]['_index']      != 'skip')
gera_nested(data_hash)        if data_hash['nested_form'] == nil  or data_hash['files'][0]['nested']      == nil or (data_hash['files'][0]['nested']      != nil and data_hash['files'][0]['nested']      != 'skip')
gera_table_json_builder(data_hash)
gera_index_json_builder(data_hash)
gera_show_json_builder(data_hash)
add_table_in_routes(data_hash)
add_helpers_in_apllication_helper(data_hash)
