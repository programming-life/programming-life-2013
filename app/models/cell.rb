# == Schema Information
#
# Table name: cells
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Cell < ActiveRecord::Base
	attr_accessible :id, :name, :module_instances_attributes
  
	has_many :module_instances, :dependent => :destroy
	has_many :module_templates, :through => :module_instances
 
	accepts_nested_attributes_for :module_instances, :reject_if => proc { |attr| attr[:module_template_id].to_i == 0 }, :allow_destroy => true

end
