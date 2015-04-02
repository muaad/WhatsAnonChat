class CommandsController < ApplicationController
  def incoming
  	if params[:notification_type] == "MessageReceived"
	  	message = params[:text]
	  	contact = Contact.find_by(phone_number: params[:phone_number])
	  	if contact.nil?
	  		if message.downcase == "join"
	  			contact = Contact.find_or_create_by!(phone_number: params[:phone_number])
	  			contact.update(name: params[:name])
	  			send_message params[:phone_number], "Hi #{contact.name}, \nWelcome to this service. Now, all that is left for you to use this service is to complete your profile."
	  			current = Progress.create! contact: contact, step: Step.first
	  			send_message params[:phone_number], current.step.prompt
	  	# 		contact.complete_profile(current.step, message)
				# current.update(step_id: current.step.next_step_id)
	  			# update_profile message, params[:phone_number]
	  		else
	  			send_message(params[:phone_number], "Looks like you are new to us. Please send 'Join' if you want to be added to this service. Thanks.")
	  		end
	  	elsif contact.profile_incomplete
	  		update_profile message, params[:phone_number]
	  	elsif is_command message
	  		if parse_message(message).nil?
	  			msg = "Sorry. We couldn't recognize that command. Here is a list of the commands we support:\n\n"
	  			Command.all.each{|c| msg << "#{c.name}\t-\t#{c.description}\n"}
	  			send_message(params[:phone_number], msg)
	  		else
	  			HTTParty.post("http://localhost:3000#{parse_message(message).action_path}", body: params)
	  		end
	  	end
	  	# if is_command message
	  	# 	contact = Contact.find_by!(phone_number: params[:phone_number])
	  	# 	if contact.nil?
	  	# 		# Looks like you are new to us. Please send "Join" if you want to be added to this service. Thanks.
	  	# 	else
	  	# 		HTTParty.post(parse_message(message).action_path, body: params)
	  	# 	end
	  	# else#if message.downcase == "join"
	  	# 	contact = Contact.find_or_create_by!(phone_number: params[:phone_number])
	  	# 	contact.update(name: params[:name])
	  	# end
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

  def outgoing
  end

  def send_message phone_number, message
  	HTTParty.post("http://app.ongair.im/api/v1/base/send?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, text: message, thread: true})
  end

  def parse_message message
  	if is_command message
  		return Command.find_by(name: message)
  	end
  end

  def is_command message
  	message.start_with?("/")
  end
end
