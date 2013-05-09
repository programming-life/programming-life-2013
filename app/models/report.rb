# == Schema Information
#
# Table name: reports
#
#  id                 :integer          not null, primary key
#  cell_id            :integer
#

class Report < ActiveRecord::Base
	attr_accessible :id, :cell_id

	has_one :cell

	validates :cell_id, :presence => true
end
