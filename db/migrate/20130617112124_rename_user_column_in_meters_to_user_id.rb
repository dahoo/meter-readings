class RenameUserColumnInMetersToUserId < ActiveRecord::Migration
  def change
    rename_column :meters, :user, :user_id
  end
end
