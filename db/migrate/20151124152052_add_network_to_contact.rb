class AddNetworkToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :network, :string, default: "WhatsApp"
  end
end
