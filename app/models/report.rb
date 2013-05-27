# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  cell_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Report < ActiveRecord::Base
	validates_uniqueness_of :cell_id

	attr_accessible :id, :cell_id
	belongs_to :cell
	validates :cell_id, :presence => true
end
