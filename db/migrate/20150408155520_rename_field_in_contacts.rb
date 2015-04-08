class RenameFieldInContacts < ActiveRecord::Migration
  def change
  	rename_column :contacts, :opted_id, :opted_in
  	change_column :contacts, :opted_in, :boolean, default: false
  end
end
