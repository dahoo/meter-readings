class AddPriceToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :price, :float
  end
end
