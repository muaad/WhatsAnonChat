class CommandsController < ApplicationController
	def incoming
		if params[:notification_type] == "MessageReceived"
			message = params[:text]
			contact = Contact.find_by(phone_number: params[:phone_number])
			if contact.nil?
				if message.downcase == "join"
					contact = Contact.find_or_create_by!(phone_number: params[:phone_number])
					contact.update(name: params[:name])
					set_country params[:phone_number]
					send_message params[:phone_number], "Hi there, \nWelcome to this service. Now, all that is left for you to use this service is to complete your profile."
					current = Progress.create! contact: contact, step: Step.first
					send_message params[:phone_number], current.step.prompt
				else
					send_message(params[:phone_number], "Looks like you are new to us. Please send 'Join' if you want to be added to this service. Thanks.")
				end
			elsif contact.profile_incomplete
				update_profile message, params[:phone_number]
			elsif is_command message
				if command(message).nil?
					msg = "Sorry. We couldn't recognize that command. Send /help if in doubt."
					send_message(params[:phone_number], msg)
				else
					eval("Command.#{command(message).action_path}(params)")
				end
			elsif message.downcase == "leave"
				contact.chats.delete_all
				contact.delete
				send_message params[:phone_number], "All your details have been removed from the service. We shall miss you. If you miss us, send 'JOIN' again. You are welcome back anytime."
			else
				if message.start_with?("@")
					if message.include?(":") && message.split(":")[0].split(" ").length <= 2
						username = message.split(":")[0].gsub("@", "").strip
						msg = message.split(":")[1..message.length].join(" ")
					else
						username = message.split(" ")[0].gsub("@", "")
						msg = message.split(" ")[1..message.length].join(" ")
					end
					recipient = Contact.where("username ilike ?", username).first
					sender = Contact.find_by(phone_number: params[:phone_number])
					if recipient != sender
						if !sender.opted_in
							send_message sender.phone_number, "Hey @#{sender.username}, Remember you are invisible? If you want to be able to chat with people, make yourself visible by sending in /visible/on"
						else
							if !recipient.nil?
								chats = Chat.where("contact_id = ? AND friend_id = ? OR contact_id = ? AND friend_id = ?", 
									sender.id, recipient.id, recipient.id, sender.id)
								if chats.empty?
									sender.chats.update_all(active: false)
									recipient.chats.update_all(active: false)
									chat = Chat.find_or_create_by(contact_id: sender.id, friend_id: recipient.id)
									Message.create! chat: chat, body: message.split(":")[1], from: sender.id, to: recipient.id
								else
									sender.chats.update_all(active: false)
									recipient.chats.update_all(active: false)
									chat = chats.first
									chat.active = true
									chat.save!
									Message.create! chat: chat, body: message.split(":")[1], from: sender.id, to: recipient.id
								end
								if !msg.blank?
									send_message recipient.phone_number, "@#{sender.username} says:\n\n#{msg}"
								else
									send_message sender.phone_number, "A chat has been initiated with @#{recipient.username} but you haven't included a message. Send your message now."
								end
								# chat = Chat.find_or_create_by(contact_id: sender.id, friend_id: recipient.id)
								# Message.create! chat: chat, body: message.split(":")[1], from: sender.id, to: recipient.id
							elsif !recipient.opted_in
								send_message params[:phone_number], "@#{recipient.username} has chosen to be invisible. You won't be able to chat with #{recipient.male ? 'him' : 'her'} unless #{recipient.male ? 'he' : 'she'} is visible."
							else
								send_message params[:phone_number], "There is no user with the username @#{username}. Send /spin to get someone to talk to or /friends to get a list of the people you have chat with."
							end
						end
					else
						send_message params[:phone_number], "Looks like you are trying to chat with yourself. :) Send /spin to find someone to chat with or /friends to get a list of the people you have chat with. Send /help if you are not sure. Want some smart guy to talk to straight away, say hi to @smartie; for example, send @smartie hi."
					end
				else
					sender = Contact.find_by(phone_number: params[:phone_number])
					# chats = Chat.where("active = ? AND contact_id = ? OR friend_id = ?", true, sender.id, sender.id)
					if !sender.opted_in
						send_message sender.phone_number, "Hey @#{sender.username}, Remember you are invisible? If you want to be able to chat with people, make yourself visible by sending in /visible/on"
					else
						chats = sender.active_chats
						if !chats.empty?
							recipient = nil
							chat = chats.first
							if chat.contact == sender
								recipient = chat.friend
							else
								recipient = chat.contact
							end
							if !recipient.opted_in
								send_message params[:phone_number], "@#{recipient.username} has chosen to be invisible. You won't be able to chat with #{recipient.male ? 'him' : 'her'} unless #{recipient.male ? 'he' : 'she'} is visible."
							else
								send_message recipient.phone_number, "@#{sender.username} says:\n\n#{message}"
							end
							Message.create! chat: chat, body: message, from: sender.id, to: recipient.id
						else
							send_message params[:phone_number], "Looks like you don't have an active chat. To start a chat, 
							start your message with '@username:' and replace 'username' with the username of a friend. 
							To get a list of the people you have been chatting with, reply with '/friends'. 
							To get some help using this service, reply with '/help'."
						end
					end
				end
			end
			render json: {succes: true}
		else
			render json: {succes: true}
		end
	end

	def update_profile message, phone_number
		current = nil
		contact = Contact.find_by(phone_number: phone_number)
		if Progress.find_by(contact: contact).nil?
			current = Progress.create! contact: contact, step: Step.first
		else
			current = Progress.find_by(contact: contact)
		end
	
		if current.step
			error = Contact.check_format(current.step.name, message)
			if error.nil?
				contact.complete_profile(current.step, message)
				if !contact.profile_incomplete
					contact.update(opted_in: true)
					send_message "254722778438", "New sign up: \n#{contact.username} | #{contact.age} | #{contact.gender} | #{contact.country} | #{contact.name}"
				end
				current.update(step_id: current.step.next_step_id)
				send_message phone_number, current.step.prompt
			else
				send_message phone_number, error
			end
		end
	end

	def outgoing
	end

	def send_message phone_number, message
		HTTParty.post("https://app.ongair.im/api/v1/base/send?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, text: message, thread: true})
	end

	def create_ongair_contact phone_number
		HTTParty.post("https://app.ongair.im/api/v1/base/create_contact?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, name: "anon"})
	end

	def command message
		if is_command message
			return Command.enabled.find_by(name: message.split("/")[1].downcase.strip)
		end
	end

	def is_command message
		message.start_with?("/")
	end

	def set_country phone_number
		contact = Contact.find_by(phone_number: phone_number)
		country_code = Phony.split(phone_number)[0]
		country = Country.find_all_by_country_code(country_code)[0][1]["name"]
		# short_name = Country.find_all_by_country_code(country_code)[0][1]["alpha2"].downcase
		contact.country = country
		contact.save!
	end
end
