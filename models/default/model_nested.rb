
  accepts_nested_attributes_for :##{nested_table_plural}, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true