# == Schema Information
#
# Table name: module_parameters
#
#  id                 :integer          not null, primary key
#  key                :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  module_template_id :integer
#

class ModuleParameter < ActiveRecord::Base
  attr_accessible :id, :key, :module_template_id
  
  belongs_to :module_template
  has_many :module_values, :dependent => :destroy
end
