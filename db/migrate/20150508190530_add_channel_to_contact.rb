class AddChannelToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :channel, :string
  end
end
