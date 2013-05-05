class ModuleInstance < ActiveRecord::Base
  attr_accessible :id
  
  validates :id, :presence => true
  
  has_many :module_values
  has_many :module_parameters, :through => :module_template
  belongs_to :module_template
  belongs_to :cell
end
