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
	  			send_message params[:phone_number], "Hi #{contact.name}, \nWelcome to this service. Now, all that is left for you to use this service is to complete your profile."
	  			current = Progress.create! contact: contact, step: Step.first
	  			send_message params[:phone_number], current.step.prompt
	  		else
	  			send_message(params[:phone_number], "Looks like you are new to us. Please send 'Join' if you want to be added to this service. Thanks.")
	  		end
	  	elsif contact.profile_incomplete
	  		update_profile message, params[:phone_number]
	  	elsif is_command message
	  		if command(message).nil?
	  			msg = "Sorry. We couldn't recognize that command. Here is a list of the commands we support:\n\n"
	  			Command.all.each{|c| msg << "#{c.name}\t-\t#{c.description}\n"}
	  			send_message(params[:phone_number], msg)
	  		else
	  			HTTParty.post("http://localhost:3000/#{command(message).action_path}", body: params)
	  		end
	  	else
	  		if message.start_with?("@")
	  			username = message.split(":")[0].gsub("@", "")
	  			recipient = Contact.where("username like ?", username).first
	  			sender = Contact.find_by(phone_number: params[:phone_number])
	  			if !recipient.nil?
	  				chats = Chat.where("contact_id = ? AND friend_id = ? OR contact_id = ? AND friend_id = ?", 
	  					sender.id, recipient.id, recipient.id, sender.id)
	  				if chats.empty?
	  					Chat.where("contact_id = ? OR friend_id = ?", sender.id, sender.id).update_all(active: false)
	  					chat = Chat.find_or_create_by(contact_id: sender.id, friend_id: recipient.id)
	  					Message.create! chat: chat, body: message.split(":")[1]
	  				else
	  					chat = chats.first
	  					chat.update(active: true)
	  					Message.create! chat: chat, body: message.split(":")[1]
	  				end
	  				send_message recipient.phone_number, "@#{sender.username}: #{message.split(":")[1]}"
	  				# chat = Chat.find_or_create_by(contact_id: sender.id, friend_id: recipient.id)
	  				# Message.create! chat: chat, body: message.split(":")[1]
	  			else
	  				send_message params[:phone_number], "There is no user with the username @#{username}."
	  			end
	  		else
	  			sender = Contact.find_by(phone_number: params[:phone_number])
	  			chats = Chat.where("active = ? AND contact_id = ? OR friend_id = ?", true, sender.id, sender.id)
	  			if !chats.empty?
	  				sender = Contact.find_by(phone_number: params[:phone_number])
	  				recipient = nil
	  				chat = chats.first
	  				if chat.contact == sender
	  					recipient = chat.friend
	  				else
	  					recipient = chat.contact
	  				end
	  				send_message recipient.phone_number, "@#{sender.username}: #{message}"
	  				Message.create! chat: chat, body: message.split(":")[1]
	  			else
	  				send_message params[:phone_number], "Looks like you don't have an active chat. To start a chat, 
	  				start your message with '@username:' and replace 'username' with the username of a friend. 
	  				To get a list of the people you have been chatting with, reply with '/friends'. 
	  				To get some help using this service, reply with '/help'."
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
  		# if current.step.nil?
  		# 	current.update(step: Step.first)
  		# end
  	end
	
  	if current.step
  		contact.complete_profile(current.step, message)
  		current.update(step_id: current.step.next_step_id)
  		send_message phone_number, current.step.prompt
  	end
  end

  def help
  	commands = "This is a list of the available commands:\n\n"
  	Command.all.each{|c| commands << "/#{c.name}\t-\t#{c.description}\n\n"}
  	commands << "\nIf you want to start chatting with someone, add '@' before their username e.g. \n@muaad: Hi. How are you?."
  	send_message params[:phone_number], commands
  	render json: {succes: true}
  end

  def invite
  	command_params(params[:text]).split(",").each do |phone_number|
  		contact = Contact.find_by(phone_number: phone_number)
  		if contact.nil?
  			create_ongair_contact phone_number
  			send_message phone_number.strip, "Hey there. You have been invited by @#{Contact.find_by(phone_number: params[:phone_number]).username} to try out this service which lets you
  			chat on WhatsApp annonymously. Find interesting people outside your contacts and chat with them without revealing your number.
  			 You can try it out by adding this number to your contacts and replying to this message with the word 'JOIN'. Don't worry. 
  			 You can opt out any time and no one will bother you anymore."
  		else
  			send_message params[:phone_number], "#{phone_number} is already registered. You can chat with #{contact.male ? 'him' : 'her'} at @#{contact.username.downcase}."
  		end
  	end
  	render json: {succes: true}
  end

  def search
  	# age:22-25,gender:Male,country:Kenya
  	query = ""
  	command_params(params[:text]).split(",").each do |q|
  		if q.split(":")[0].downcase == "age" && q.split(":")[1].split("-").count == 2
  			query << "age >= #{q.split(":")[1].split("-")[0]} AND age <= #{q.split(":")[1].split("-")[1]}" 
  		elsif q.split(":")[0].downcase == "age" && q.split(":")[1].split("-").count == 1
  			query << "age == #{q.split(":")[1]}"
  		# elsif q.split(":")[0].downcase == "age"
  			
  		end
  		if q.split(":")[0].downcase != "age"
  			query << " AND #{q.split(":")[0]} like '#{q.split(":")[1]}'"
  		end
  	end
  	puts query
  	contacts = []
  	begin
  		contacts = Contact.where(query)
  	rescue Exception => e
  		# puts "><><><><><>< Error"
  		# contacts = []
  		# msg = "We couldn't understand your search query."
  	end
  	msg = ""
  	if contacts.empty?
  		msg = "Sorry. We could not find anyone matching your search query. Try again."
  	else
  		msg = "We have found #{contacts.count} results:\n\n"
  		contacts.each{|c| msg << "@#{c.username.downcase}\n#{c.age}\t|\t#{c.gender}\t|\t#{c.country}\n"}
  	end
  	send_message params[:phone_number], msg
  	render json: {succes: true}
  end

  def friends
  	msg = "Here is a list of people you have chat with:\n\n"
  	sender = Contact.find_by(phone_number: params[:phone_number])
  	chats = Chat.where("contact_id = ? OR friend_id = ?", sender.id, sender.id)
  	chats.each do |chat|
  		recipient = nil
  		if chat.contact == sender
  			recipient = chat.friend
  		else
  			recipient = chat.contact
  		end
  		msg << "- @#{recipient.username} - #{recipient.age} | #{recipient.gender} | #{recipient.country} \n\n"
  	end
  	send_message params[:phone_number], msg
  	render json: {succes: true}
  end

  def outgoing
  end

  def send_message phone_number, message
  	HTTParty.post("http://app.ongair.im/api/v1/base/send?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, text: message, thread: true})
  end

  def create_ongair_contact phone_number
  	HTTParty.post("http://app.ongair.im/api/v1/base/create_contact?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, name: "anon"})
  end

  def command message
  	if is_command message
  		return Command.find_by(name: message.split("/")[1].downcase.strip)
  	end
  end

  def command_params message
  	message.split("/")[2]
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
