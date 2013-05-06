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

require 'test_helper'

class ModuleInstanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
