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
  	Command.all.each{|c| commands << "#{c.name}\t-\t#{c.description}\n"}
  	commands << "\nIf you want to start chatting with someone, add '@' before their username e.g. \n@muaad: Hi. How are you?."
  	send_message params[:phone_number], commands
  	render json: {succes: true}
  end

  def invite
  	command_params(params[:text]).split(",").each do |phone_number|
  		contact = Contact.find_by(phone_number: phone_number)
  		if contact.nil?
  			create_ongair_contact phone_number
  			send_message phone_number.strip, "Hey there. You have been invited by @#{Contact.find_by(phone_number: params[:phone_number])} to try out this service which lets you
  			chat on WhatsApp annonymously. Find interesting people outside your contacts and chat with them without revealing your number.
  			 You can try it out by adding this number to your contacts and replying to this message with the word 'JOIN'. Don't worry. 
  			 You can opt out any time and no one will bother you anymore."
  		else
  			send_message params[:phone_number], "#{phone_number} is already registered. You can chat with #{contact.male ? 'him' : 'her'} at @#{contact.username.downcase}."
  		end
  	end
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
