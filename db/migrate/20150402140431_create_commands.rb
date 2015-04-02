class CreateCommands < ActiveRecord::Migration
  def change
    create_table :commands do |t|
      t.string :name
      t.text :description
      t.string :action_path

      t.timestamps null: false
    end
  end
end
