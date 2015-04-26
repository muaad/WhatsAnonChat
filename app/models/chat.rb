class Chat < ActiveRecord::Base
	belongs_to :contact
	belongs_to :friend, :class_name => "Contact"
	has_many :messages, dependent: :delete_all

	scope :active, -> { where(active: true) }

	def recipient sender
		recipient
		if contact == sender
			recipient = chat.friend
		else
			recipient = chat.contact
		end
		recipient
	end
end
