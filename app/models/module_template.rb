class ModuleTemplate < ActiveRecord::Base
	attr_accessible :id, :name, :module_parameters_attributes
  
	validates :name, :presence => true
  
	has_many :module_instances, :dependent => :destroy
	has_many :module_parameters , :dependent => :destroy
	has_many :cells, :through => :module_instances
  
	accepts_nested_attributes_for :module_parameters, :allow_destroy => true
end
