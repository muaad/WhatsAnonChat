require "whatsapp"
require "telegram"
class Message < ActiveRecord::Base
  belongs_to :chat
  # belongs_to :from, :class_name => "Contact"
  # belongs_to :to, :class_name => "Contact"

  def self.get_usernames text
  	text.split(" ").select{|t| t.start_with?("@")}
  end

  def self.send_text contact, message
  	if contact.network == "WhatsApp"
  		WhatsApp.send_message contact.phone_number, message
  	else
  		Telegram.send_message contact.phone_number, message
  	end
  end
end
