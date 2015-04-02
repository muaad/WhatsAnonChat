class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :phone_number
      t.string :gender
      t.integer :age
      t.string :country
      t.string :username
      t.boolean :opted_id

      t.timestamps null: false
    end
  end
end
