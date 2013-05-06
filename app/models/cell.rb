class Cell < ActiveRecord::Base
	attr_accessible :id, :name
  
	has_many :module_instances, :dependent => :destroy
	has_many :module_templates, :through => :module_instances
 
	accepts_nested_attributes_for :module_instances, :allow_destroy => true

end
