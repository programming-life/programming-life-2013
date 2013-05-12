# == Schema Information
#
# Table name: module_templates
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  name             :string(255)
#  step             :text
#  file             :string(255)
#  javascript_model :string(255)
#

require 'test_helper'

class ModuleTemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
