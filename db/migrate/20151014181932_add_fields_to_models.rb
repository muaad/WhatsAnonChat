class AddFieldsToModels < ActiveRecord::Migration
  def change
  	add_reference :users, :account, index: true
  	add_column :users, :latitude, :float
  	add_column :users, :longitude, :float
  	add_column :contacts, :latitude, :float
  	add_column :contacts, :longitude, :float
  end
end
