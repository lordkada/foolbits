class MakeLongerFieldsInUsers < ActiveRecord::Migration
  def change
    change_column :users, :first_name, :string, limit: 255  
    change_column :users, :last_name, :string, limit: 255 
    change_column :users, :facebook_id, :string, limit: 255 
    change_column :users, :email, :string, limit: 255 
  end
end