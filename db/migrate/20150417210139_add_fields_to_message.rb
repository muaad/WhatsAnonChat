class AddFieldsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :from, :integer
    add_column :messages, :to, :integer
  end
end
