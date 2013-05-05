class Cell < ActiveRecord::Base
  attr_accessible :id, :name
  
  has_many :module_instances
  has_many :module_templates, :through => :module_instances
  
  validates :id, :presence => true
end
