class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.text :text
      t.references :contact, index: true

      t.timestamps null: false
    end
    add_foreign_key :broadcasts, :contacts
  end
end
