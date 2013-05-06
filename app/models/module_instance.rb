# == Schema Information
#
# Table name: module_instances
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  module_template_id :integer
#  cell_id            :integer
#

class ModuleInstance < ActiveRecord::Base
	attr_accessible :id, :module_template_attributes

	has_many :module_values
	has_many :module_parameters, :through => :module_template
	belongs_to :module_template
	belongs_to :cell

	accepts_nested_attributes_for :module_values, :allow_destroy => true 
end
