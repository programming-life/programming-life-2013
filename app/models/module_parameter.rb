# == Schema Information
#
# Table name: module_parameters
#
#  id         :integer          not null, primary key
#  key        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ModuleParameter < ActiveRecord::Base
  attr_accessible :id, :key
  
  belongs_to :module_template
  has_many :module_values, :dependent => :destroy
end
