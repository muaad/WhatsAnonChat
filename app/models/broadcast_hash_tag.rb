class BroadcastHashTag < ActiveRecord::Base
	belongs_to :broadcast
	belongs_to :hash_tag
end
