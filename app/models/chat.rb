class Chat < ActiveRecord::Base
	belongs_to :contact
	belongs_to :friend, :class_name => "Contact"
	has_many :messages, dependent: :delete_all
end
