class ModuleParameter < ActiveRecord::Base
  attr_accessible :id, :key
  
  belongs_to :module_template
  has_many :module_values, :dependent => :destroy
end
