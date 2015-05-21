class AddFiledsToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :password_digest, :string
    add_column :contacts, :auth_token, :string
    add_column :contacts, :verification_code, :string
    add_column :contacts, :verified, :boolean, default: false
    add_column :contacts, :dob, :datetime
  end
end
