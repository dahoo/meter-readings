class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.references :meter
      t.float :value

      t.timestamps
    end
    add_index :readings, :meter_id
  end
end
