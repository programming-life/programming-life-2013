# == Schema Information
#
# Table name: module_values
#
#  id         :integer          not null, primary key
#  value      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ModuleValue < ActiveRecord::Base
  attr_accessible :value
  
  belongs_to :module_parameter
  belongs_to :module_instance
end
