# == Schema Information
#
# Table name: module_templates
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string(255)
#  step       :text
#

class ModuleTemplate < ActiveRecord::Base
	attr_accessible :id, :name, :step, :file, :module_parameters_attributes, :javascript_model
  
	validates :name, :presence => true
  
	has_many :module_instances, :dependent => :destroy
	has_many :module_parameters, :dependent => :destroy
	has_many :cells, :through => :module_instances
  
	accepts_nested_attributes_for  :module_parameters, :allow_destroy => true
end
