class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.string :name
      t.string :unit

      t.timestamps
    end
  end
end
