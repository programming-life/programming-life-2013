class ModuleInstance < ActiveRecord::Base
	attr_accessible :id

	has_many :module_values, :dependent => :destroy
	has_many :module_parameters, :through => :module_template
	belongs_to :module_template
	belongs_to :cell

	accept_nested_attributes_for :module_values, :allow_destroy => true 
end
