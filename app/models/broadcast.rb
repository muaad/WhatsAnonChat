class Broadcast < ActiveRecord::Base
	after_create :create_hash_tags
  belongs_to :contact
  has_many :broadcast_hash_tags
  has_many :hash_tags, through: :broadcast_hash_tags

  def create_hash_tags
  	hash_tags = text.split(" ").select{|w| w.start_with?('#')}
  	hash_tags.each do |h|
  		ht = HashTag.find_or_create_by! name: h
  		BroadcastHashTag.create! broadcast_id: id, hash_tag: ht
  	end
  end
end
