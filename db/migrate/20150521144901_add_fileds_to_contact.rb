class AddFiledsToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :password, :string
    add_column :contacts, :password_confirmation, :string
  end
end
