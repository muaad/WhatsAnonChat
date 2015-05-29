class AddOnSlackToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :on_slack, :boolean, default: false
  end
end
