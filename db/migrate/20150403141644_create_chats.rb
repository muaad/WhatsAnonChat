class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.integer :contact_id
      t.integer :friend_id
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
