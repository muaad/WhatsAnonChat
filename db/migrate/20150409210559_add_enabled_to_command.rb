class AddEnabledToCommand < ActiveRecord::Migration
  def change
    add_column :commands, :enabled, :boolean, default: false
  end
end
