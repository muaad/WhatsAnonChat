class Chat < ActiveRecord::Base
	belongs_to :contact
	belongs_to :friend, :class_name => "Contact"
	has_many :messages, dependent: :delete_all

	scope :active, -> { where(active: true) }

	def recipient sender
		receiver = nil
		if contact == sender
			receiver = friend
		else
			receiver = contact
		end
		receiver
	end
end
