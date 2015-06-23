class CreateBroadcastHashTags < ActiveRecord::Migration
  def change
    create_table :broadcast_hash_tags do |t|
    	t.references :broadcast, index: true
    	t.references :hash_tag, index: true
      t.timestamps null: false
    end
  end
end
