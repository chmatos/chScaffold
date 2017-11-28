class ##{table.camelize} < ActiveRecord::Base
  ##{belongs_to_list}
  ##{has_many_list}
  ##{has_many_destroy_list}
  ##{nested_list}
  ##{has_and_belongs_to_many_list}
  ##{enum_list}
  def self.search(search)
    search.present? ? where("lower(##{search}) LIKE ?", "%#{search.downcase}%") : all
  end
end