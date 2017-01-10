class ##{table.camelize} < ActiveRecord::Base
  ##{belongs_to_list}
  ##{has_many_list}
  def self.search(search)
    if search
      where("lower(##{search}) LIKE ?", "%#{search.downcase}%")
    else
      all
    end
  end
end