class Reading < ActiveRecord::Base
  belongs_to :meter
  
  validates :meter, :value, :presence => true
end
