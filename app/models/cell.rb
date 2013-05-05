class Cell < ActiveRecord::Base
  attr_accessible :id, :name
  
  validates :id, :presence => true
end
