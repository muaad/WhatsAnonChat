class CreateWizards < ActiveRecord::Migration
  def change
    create_table :wizards do |t|
      t.string :name
      t.references :account, index: true

      t.timestamps null: false
    end
    add_foreign_key :wizards, :accounts
  end
end
