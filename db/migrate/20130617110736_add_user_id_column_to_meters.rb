class AddUserIdColumnToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :user, :integer
    add_index :meters, :user
  end
end
