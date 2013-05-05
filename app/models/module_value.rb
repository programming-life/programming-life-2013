class ModuleValue < ActiveRecord::Base
  attr_accessible :value
  
  belongs_to :module_parameter
  belongs_to :module_instance
end
