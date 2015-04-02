class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.string :name
      t.string :step_type
      t.integer :next_step_id
      t.text :prompt

      t.timestamps null: false
    end
  end
end
