# == Schema Information
#
# Table name: module_templates
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string(255)
#

class ModuleTemplate < ActiveRecord::Base
	attr_accessible :id, :name
  
	validates :name, :presence => true
  
	has_many :module_instances
	has_many :module_parameters
	has_many :cells, :through => :module_instances
  
	accepts_nested_attributes_for  :module_parameters, :allow_destroy => true
end
