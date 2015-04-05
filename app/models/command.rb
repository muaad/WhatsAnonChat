class Command < ActiveRecord::Base
	def self.help params
		commands = "This is a list of the available commands:\n\n"
		Command.all.each{|c| commands << "/#{c.name}\t-\t#{c.description}\n\n"}
		commands << "\nIf you want to start chatting with someone, add '@' before their username e.g. \n@muaad: Hi. How are you?."
		send_message params[:phone_number], commands
	end

	def self.invite params
		command_params(params[:text]).split(",").each do |phone_number|
			contact = Contact.find_by(phone_number: phone_number)
			if contact.nil?
				create_ongair_contact phone_number
				send_message phone_number.strip, "Hey there. You have been invited by @#{Contact.find_by(phone_number: params[:phone_number]).username.downcase} to try out this service which lets you
				chat on WhatsApp annonymously. Find interesting people outside your contacts and chat with them without revealing your number.
				 You can try it out by adding this number to your contacts and replying to this message with the word 'JOIN'. Don't worry. 
				 You can opt out any time and no one will bother you anymore. Just send the word 'LEAVE' if you want to remove yourself."
			else
				send_message params[:phone_number], "#{phone_number} is already registered. You can chat with #{contact.male ? 'him' : 'her'} at @#{contact.username.downcase}."
			end
		end
	end

	def self.search params
		# age:22-25,gender:Male,country:Kenya
		query = search_query command_params params[:text]
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
	end

	def self.friends params
		msg = "Here is a list of people you have chat with:\n\n"
		sender = Contact.find_by(phone_number: params[:phone_number])
		# chats = Chat.where("contact_id = ? OR friend_id = ?", sender.id, sender.id)
		sender.chats.each do |chat|
			recipient = nil
			if chat.contact == sender
				recipient = chat.friend
			else
				recipient = chat.contact
			end
			msg << "- @#{recipient.username} - #{recipient.age} | #{recipient.gender} | #{recipient.country} \n\n"
		end
		send_message params[:phone_number], msg
	end

	def self.spin params
		current_contact = Contact.find_by(phone_number: params[:phone_number])
		contact = Contact.where.not(id: current_contact.id).order("RANDOM()").first
		msg = "Here is your random match:\n\n- @#{contact.username} - #{contact.age} | #{contact.gender} | #{contact.country}"
		send_message params[:phone_number], msg
	end

	def self.search_query text
		query = ""
		q_age = ""
		q_others = ""
		text.split(",").each do |q|
			if q.split(":")[0].downcase == "age" && q.split(":")[1].split("-").count == 2
				q_age = "age >= #{q.split(":")[1].split("-")[0]} AND age <= #{q.split(":")[1].split("-")[1]}" 
			elsif q.split(":")[0].downcase == "age" && q.split(":")[1].split("-").count == 1
				q_age = "age == #{q.split(":")[1]}"
			# elsif q.split(":")[0].downcase == "age"
				
			end
			if q.split(":")[0].downcase != "age"
				q_others << " AND #{q.split(":")[0]} like '#{q.split(":")[1]}'"
			# else
			# 	query << " #{q.split(":")[0]} like '#{q.split(":")[1]}'"
			end
		end
		puts ">>>>>>>#{q_others}"
		if q_age.empty?
			query = q_others.sub!(" AND ", "")
			puts ">>>>>>>#{q_others}"
			puts ">>>>>>>#{query}"
		else
			query = q_age + q_others
		end
		query
	end

	def self.command_params message
		message.split("/")[2]
	end

	def self.send_message phone_number, message
		HTTParty.post("http://app.ongair.im/api/v1/base/send?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, text: message, thread: true})
	end

	def self.create_ongair_contact phone_number
		HTTParty.post("http://app.ongair.im/api/v1/base/create_contact?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, name: "anon"})
	end
end
