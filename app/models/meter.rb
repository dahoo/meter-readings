class Meter < ActiveRecord::Base
  has_many :readings
  belongs_to :user
  
  before_save :default_values
  
  validates :name, :unit, :price, :presence => true
  
  def default_values
    self.basic_rate ||= 0
  end
end
