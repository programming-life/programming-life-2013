class ModuleParameter < ActiveRecord::Base
  attr_accessible :id, :key
  
  belongs_to :module_template
end
