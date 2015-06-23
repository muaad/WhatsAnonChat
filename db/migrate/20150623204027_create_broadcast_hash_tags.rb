class CreateBroadcastHashTags < ActiveRecord::Migration
  def change
    create_table :broadcast_hash_tags do |t|

      t.timestamps null: false
    end
  end
end
