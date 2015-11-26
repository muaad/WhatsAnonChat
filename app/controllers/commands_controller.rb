require "telegram"
class CommandsController < ApplicationController
	def incoming
		if params[:notification_type] == "MessageReceived"
			message = params[:text]
			contact = Contact.find_by(phone_number: params[:phone_number])
			if contact.nil?
				if message.downcase == "join"
					contact = Contact.find_or_initialize_by(phone_number: params[:phone_number])
					contact.password = SecureRandom.urlsafe_base64 if contact.new_record?
					contact.name = params[:name]
					contact.network = params[:network] if !params[:network].blank?
					contact.save!
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
					msg = Chat.message_details(message)[:message]
					username = Chat.message_details(message)[:username]
					recipient = Contact.where("username like ?", username).first
					sender = Contact.find_by(phone_number: params[:phone_number])
					if recipient != sender
						if !msg.blank?
							Chat.process sender, username, msg
						else
							send_message sender.phone_number, "A chat has been initiated with @#{recipient.username} but you haven't included a message. Send your message now."
						end
					else
						send_message params[:phone_number], "Looks like you are trying to chat with yourself. :) Send /spin to find someone to chat with or /friends to get a list of the people you have chat with. Send /help if you are not sure. Want some smart guy to talk to straight away, say hi to @smartie; for example, send @smartie hi."
					end
				else
					sender = Contact.find_by(phone_number: params[:phone_number])
					Chat.process sender, message
				end
			end
			render json: {succes: true}
		elsif params[:notification_type] == "GroupMessageReceived"
			contact = Contact.find_by(phone_number: params[:phone_number])
			if contact.nil?
				contact = Contact.find_or_initialize_by(phone_number: params[:phone_number])
				contact.password = SecureRandom.urlsafe_base64 if contact.new_record?
				contact.name = params[:name]
				contact.age = "UNKNOWN"
				contact.gender = "UNKNOWN"
				contact.save!
				set_country params[:phone_number]
			end
			message = params[:text]
			create_ongair_contact params[:phone_number]
			if message.start_with?("/profile")
				# if command_params(message) && command_params(message).include?(":")
				# 	field = command_params(message).split(":")[0].downcase.strip
				# 	value = command_params(message).split(":")[1].downcase.strip
				# 	if field.downcase == "username"
				# 		if !Contact.username_exists?(value)
				# 			contact.update(username: value)
				# 		end
				# 	end
				# end
				Command.profile(params)
				p = Progress.find_or_create_by! contact_id: contact.id
				p.update(step: Step.last)
			else
				usernames = message.split(" ").collect{|s| s.sub!(/[?.!,;:]?$/, '') if s.start_with?("@")}.compact
				usernames.each do |username|
					username = username.gsub!("@", "")
					recipient = Contact.find_by username: username
					if !recipient.nil?
						send_message recipient.phone_number, "You have a new message from  on the group: {{group_name}}\n\n#{message}"
					end
				end
				if contact.username.empty?
					if !Contact.find_by(username: usernames.first).nil?
						send_message contact.phone_number, "Hi #{params[:name]},\n\nWe have notified #{usernames.to_sentence} of your message in the group. You can set up your Spin username by replying with:\n\n /profile/username:your_username.\n\n Replace your_username with the username you want to use. To find out more on how to setup your profile, send:\n\n/profile\n\nThank you."
					end
				end
			end
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
					WhatsApp.send_message "254722778438", "New sign up: \n#{contact.username} | #{contact.age} | #{contact.gender} | #{contact.country} | #{contact.name}"
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
		Message.send_text(Contact.find_by(phone_number: phone_number), message)
	end

	def create_ongair_contact phone_number
		HTTParty.post("https://ongair.im/api/v1/base/create_contact?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, name: "anon"})
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
		if contact.network == "WhatsApp"
			country_code = Phony.split(phone_number)[0]
			country = Country.find_all_by_country_code(country_code)[0][1]["name"]
			# short_name = Country.find_all_by_country_code(country_code)[0][1]["alpha2"].downcase
			contact.country = country
			contact.save!
		end
	end
end
