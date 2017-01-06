class ##{table.camelize} < ActiveRecord::Base
  def self.search(search)
    if search
      where("lower(##{search}) LIKE ?", "%#{search.downcase}%")
    else
      all
    end
  end
end