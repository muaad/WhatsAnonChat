class AddFiledsToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :password, :string
    add_column :contacts, :password_confirmation, :string
    add_column :contacts, :auth_token, :string
  end
end
