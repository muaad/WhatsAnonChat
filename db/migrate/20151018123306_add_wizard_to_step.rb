class AddWizardToStep < ActiveRecord::Migration
  def change
    add_reference :steps, :wizard, index: true
    add_foreign_key :steps, :wizards
  end
end
