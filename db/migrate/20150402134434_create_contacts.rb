class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :phone_number, unique: true
      t.string :gender
      t.integer :age
      t.string :country
      t.string :username, unique: true
      t.boolean :opted_id, default: false

      t.timestamps null: false
    end
  end
end
