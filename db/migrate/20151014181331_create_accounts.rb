class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.boolean :setup
      t.string :account_type
      t.string :email

      t.timestamps null: false
    end
  end
end
