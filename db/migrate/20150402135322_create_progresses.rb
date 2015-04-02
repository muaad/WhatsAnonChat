class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
      t.references :contact, index: true
      t.references :step, index: true

      t.timestamps null: false
    end
    add_foreign_key :progresses, :contacts
    add_foreign_key :progresses, :steps
  end
end
