class ModuleTemplate < ActiveRecord::Base
  attr_accessible :id, :name
  
  validates :name, :presence => true
  
  has_many :module_instances
  has_many :module_parameters
  has_many :module_values, :through => :module_instances
  has_many :cells, :through => :module_instances
end
