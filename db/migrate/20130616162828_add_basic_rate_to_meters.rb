class AddBasicRateToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :basic_rate, :float
  end
end
