class AddSlackTokenToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :slack_token, :string
  end
end
