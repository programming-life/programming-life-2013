# == Schema Information
#
# Table name: module_values
#
#  id                  :integer          not null, primary key
#  value               :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  module_parameter_id :integer
#  module_instance_id  :integer
#

require 'test_helper'

class ModuleValueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
