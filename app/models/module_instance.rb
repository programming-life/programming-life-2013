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
	attr_accessible :id, :module_template_id, :cell_id, :module_values_attributes

	has_many :module_values, :dependent => :destroy
	has_many :module_parameters, :through => :module_template
	belongs_to :module_template
	belongs_to :cell

	accepts_nested_attributes_for :module_values, :allow_destroy => true 
	
	after_create :create_parameters
	
	private
		def create_parameters
			self.module_template.module_parameters.each { |param| 
				ModuleValue.create( {:value => nil, :module_instance_id => self.id, :module_parameter_id => param.id } )
			}
		end
end
