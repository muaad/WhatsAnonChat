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
	  	elsif Contact.profile_incomplete(contact.id)
	  		update_profile message, params[:phone_number]
	  	else

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

  def outgoing
  end

  def send_message phone_number, message
  	HTTParty.post("http://app.ongair.im/api/v1/base/send?token=658b6fb4475bd2c58059f7dbd301f2b0", body: {phone_number: phone_number, text: message, thread: true})
  end

  def parse_message message
  	if is_command message
  		return Command.find_by(name: message.split("/")[1])
  	end
  end

  def is_command message
  	message.start_with?("/")
  end
end
