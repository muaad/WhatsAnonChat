require 'twitter_api'
class Command < ActiveRecord::Base
	scope :enabled, -> { where(enabled: true) }
	def self.help params
		# commands = "This is a list of the available commands:\n\n"
		# Command.enabled.each{|c| commands << "/#{c.name}\t-\t#{c.description}\n\n"}
		# commands << "\nIf you want to start chatting with someone, add '@' before their username e.g. \n@muaad: Hi. How are you?."
		# send_message params[:phone_number], commands
		contact = Contact.find_by(phone_number: params[:phone_number])
		msg = "Hi @#{contact.username},\n"
		msg << "Find a random person to chat with by sending /spin. You can then start a conversation with your random friend like this:\n\n@username: hi. \n\nOnce you have started the chat, you don't have to include the username again. Just send the message the way you normally do. But, if you want to chat with someone else, you will have to start with the username or your message will go to the wrong person. If you want to be very careful, you can always add the username to your message but most of the times, that is not neccessary.\n\nYou can get a list of the people you have chat with by sending /friends. This will also tell you the person you currently have an active chat with. This is the person to whom any message you send that doesn't start with @username goes to. This will help you in case you are not sure who you are talking to.\n\nYou can also find some content on here to keep you informed and entertained. To get a random joke, send /jokes, for quotes, /quotes and for news, you have a few options. /news gives you local news while the rest are self explanatory: /news/international, /news/tech, /news/sport.\n\nWhen you request for content, if you had not saved this number in your contacts, the links won't appear and you won't be able to click them. So, please make sure you save this number.\n\nYou can also share a joke or a quote with a friend. Just send /jokes/@username or /quotes/@username. Spread the love. :-)\n\nAnd, finally, you can invite your friends by sending /invite/254722111777. Phone number must be in that format. You can invite more than one friend like this: /invite/254722111777,254722888333,254711888222.\n\nEnjoy #{contact.male ? 'brother' : 'sister'}. :-)"
		send_message params[:phone_number], msg
	end

	def self.invite params
		command_params(params[:text]).split(",").each do |phone_number|
			phone_number = phone_number.strip
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
		# query = search_query command_params params[:text]
		# puts query
		# contacts = []
		# begin
		# 	contacts = Contact.where(query)
		# rescue Exception => e
		# 	# puts "><><><><><>< Error"
		# 	# contacts = []
		# 	# msg = "We couldn't understand your search query."
		# end
		# msg = ""
		# if contacts.empty?
		# 	msg = "Sorry. We could not find anyone matching your search query. Try again."
		# else
		# 	msg = "We have found #{contacts.count} results:\n\n"
		# 	contacts.each{|c| msg << "@#{c.username.downcase}\n#{c.age}\t|\t#{c.gender}\t|\t#{c.country}\n"}
		# end
		# send_message params[:phone_number], msg
		contacts = []
		msg = ""
		if command_params(params[:text]).downcase == "male"
			contacts = Contact.opted_in.male.where.not(phone_number: params[:phone_number])
		elsif command_params(params[:text]).downcase == "female"
			contacts = Contact.opted_in.female.where.not(phone_number: params[:phone_number])
		end
		if !contacts.empty?
			msg << "We have found #{contacts.count} matches:\n\n"
			contacts.each{|c| msg << "@#{c.username.downcase} - #{c.age}\n\n"}
		else
			msg = "Sorry. We could not find anuthing that matches your search parameters."
		end
		send_message params[:phone_number], msg
	end

	def self.friends params
		sender = Contact.find_by(phone_number: params[:phone_number])
		# chats = Chat.where("contact_id = ? OR friend_id = ?", sender.id, sender.id)
		active = ""
		msg = ""
		sender.chats.each do |chat|
			recipient = nil
			if chat.contact == sender
				recipient = chat.friend
			else
				recipient = chat.contact
			end
			if sender.active_chats.first == chat
				active = recipient.username
			end
			msg = "Here is a list of people you have chat with:\n\n"
			msg << "- @#{recipient.username} - #{recipient.age} | #{recipient.gender} | #{recipient.country} \n\n"
		end
		if !active.empty?
			msg << "Your currently active chat is with:\n\n@#{active}\n\nIf you want to talk to someone else, you must start the message with @username: or the message will go to @#{active}."
			if !Contact.find_by(username: active).opted_in
				msg << "\n\n@#{active} has set their profile to be invisible which means they are not available for chat. Please find someone else to chat with meanwhile."
			end
		else
			msg << "You are currently not chatting with anyone. If you would like to chat with someone, you can send /spin and start your chat in this format: @username: hi."
		end
		if !sender.opted_in
			msg << "\n\nJust a reminder: Your profile is set to invisible and you won't be able to chat with anyone. If you want to be able to chat with people, make yourself visible by sending in /visible/on"
		end
		send_message params[:phone_number], msg
	end

	def self.spin params
		current_contact = Contact.find_by(phone_number: params[:phone_number])
		contact = Contact.where.not(id: current_contact.id).sample
		if current_contact.opted_in
			msg = "Here is your random match:\n\n- @#{contact.username} - #{contact.age} | #{contact.gender} | #{contact.country}"
		else
			send_message params[:phone_number], "Sorry. Remember you are invisible? If people can't see you, it is only fair that you don't see them either, right? You can make yourself visible by sending in /visible/on"
		end
		send_message params[:phone_number], msg
	end

	def self.news params
		source = "dailynation"
		src = "Daily Nation"
		category = "local"
		if command_params(params[:text])
			if command_params(params[:text]) == "tech"
				source = "nytimestech"
				src = "New York Times"
				category = "technology"
			elsif command_params(params[:text]) == "sport" || command_params(params[:text]) == "sports"
				source = "bbcsport"
				src = "BBC"
				category = "sports"
			elsif command_params(params[:text]) == "international"
				source = "bbcnews"
				src = "BBC"
				category = "international news"
			end
		end
		twitter = TwitterApi.new
		tweets = "Here are the 5 latest #{category} stories making headlines on the #{src}:\n\n"
		twitter.tweets(source).take(5).each{|t| tweets << "#{t.text}\n\n"}
		send_message params[:phone_number], tweets
	end

	def self.jokes params
		twitter = TwitterApi.new
		joke = (twitter.tweets("best_jokes") + twitter.tweets("badjokecat")).sample.text
		if !command_params(params[:text]).blank?
			username = command_params(params[:text]).sub("@", "").strip
			if !Contact.find_by(username: username).nil?
				send_message Contact.find_by(username: username).phone_number, "@#{Contact.find_by(phone_number: params[:phone_number]).username} has shared a joke with you:\n\n #{joke}"
				send_message params[:phone_number], "You have shared this joke with @#{username}:\n\n #{joke}"
			else
				send_message params[:phone_number], "You tried to share a joke with @#{username} which doesn't exist."
			end
		else
			send_message params[:phone_number], joke
		end
	end

	de