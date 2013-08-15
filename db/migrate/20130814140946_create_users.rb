class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name, limit: 30
      t.string :last_name, limit: 30
      t.string :email, limit: 30
      t.string :facebook_id, limit: 25
      t.string :facebook_access_token, limit: 255
      t.string :picture_url, limit: 255
      t.text   :vault
      t.timestamps
    end
    add_index :users, :facebook_id, :unique => true
  end
end
