class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :chat, index: true
      t.text :body

      t.timestamps null: false
    end
    add_foreign_key :messages, :chats
  end
end
