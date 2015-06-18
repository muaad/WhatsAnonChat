require 'whatsapp'
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

	def self.send_message phone_number, message
		HTTParty.post("https://app.ongair.im/api/v1/base/send?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, text: message, thread: true})
		recipient = Contact.find_by(username: message_details(message).username)
		sender = Contact.find_by(phone_number: phone_number)
		if recipient.on_slack
			Slack.send("@#{sender.username} says:\n\n#{message}")
		end
	end

	def self.process sender, username="", message
		if !username.empty?
			recipient = Contact.find_by(username: username)
			if !recipient.nil?
				if recipient.opted_in && sender.opted_in
					chats = sender.chats_with(recipient)
					if chats.empty?
						sender.chats.update_all(active: false)
						recipient.chats.update_all(active: false)
						chat = Chat.find_or_create_by(contact_id: sender.id, friend_id: recipient.id)
						Message.create! chat: chat, body: message, from: sender.id, to: recipient.id
					else
						sender.chats.update_all(active: false)
						recipient.chats.update_all(active: false)
						chat = chats.first
						chat.active = true
						chat.save!
						Message.create! chat: chat, body: message, from: sender.id, to: recipient.id
					end
					self.send_message recipient.phone_number, "@#{sender.username} says:\n\n#{message}"					
				else
					if !recipient.opted_in
						self.send_message sender.phone_number, "@#{recipient.username} has chosen to be invisible. You won't be able to chat with #{recipient.male ? 'him' : 'her'} unless #{recipient.male ? 'he' : 'she'} is visible."
					elsif !sender.opted_in
						self.send_message sender.phone_number, "Hey @#{sender.username}, Remember you are invisible? If you want to be able to chat with people, make yourself visible by sending in /visible/on"
					end
				end
			else
				self.send_message sender.phone_number, "There is no user with the username @#{username}. Send /spin to get someone to talk to or /friends to get a list of the people you have chat with."
			end
		else
			active = sender.active_chats.first
			last_chat = sender.last_chat
			chat = active.nil?? last_chat : active
			if !chat.nil?
				recipient = chat.recipient(sender)
				if recipient.opted_in && sender.opted_in
					if !active.nil?
						self.send_message recipient.phone_number, "@#{sender.username} says:\n\n#{message}"
						Message.create! chat: chat, body: message, from: sender.id, to: recipient.id
					else
						self.send_message recipient.phone_number, "@#{sender.username} says:\n\n#{message}\n\nYou don't have an active chat with @#{sender.username}. To reply to @#{sender.username}, start your message with @#{sender.username}."
						Message.create! chat: sender.last_chat, body: message, from: sender.id, to: recipient.id
						self.send_message sender.phone_number, "Your last active chat was with @#{recipient.username} who has since started another chat with someone else. Don't worry. We have delivered your message to @#{recipient.username}. You can start your message with @#{recipient.username} just to be safe."
					end
				else
					if !recipient.opted_in
						self.send_message sender.phone_number, "@#{recipient.username} has chosen to be invisible. You won't be able to chat with #{recipient.male ? 'him' : 'her'} unless #{recipient.male ? 'he' : 'she'} is visible."
					elsif !sender.opted_in
						self.send_message sender.phone_number, "Hey @#{sender.username}, Remember you are invisible? If you want to be able to chat with people, make yourself visible by sending in /visible/on"
					end
				end
			else
				self.send_message sender.phone_number, "You are currently not chatting with anyone. Send /spin to find a random person to talk to. You can also search by gender. Send /search/male or /search/female. To find some help on how to chat on here, send /help/chat."
			end
		end
	end

	def self.message_details message
		msg = ""
		username = ""
		if message.include?(":") && message.split(":")[0].split(" ").length <= 2
			username = message.split(":")[0].gsub("@", "").strip
			msg = message.split(":")[1..message.length].join(" ")
		else
			username = message.split(" ")[0].gsub("@", "")
			msg = message.split(" ")[1..message.length].join(" ")
		end
		{message: msg, username: username}
	end
end
