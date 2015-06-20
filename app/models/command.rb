require 'twitter_api'
class Command < ActiveRecord::Base
	scope :enabled, -> { where(enabled: true) }
	def self.help params
		# commands = "This is a list of the available commands:\n\n"
		# Command.enabled.each{|c| commands << "/#{c.name}\t-\t#{c.description}\n\n"}
		# commands << "\nIf you want to start chatting with someone, add '@' before their username e.g. \n@muaad: Hi. How are you?."
		# send_message params[:phone_number], commands

		# Break up help menu into commands ie /help/command

		contact = Contact.find_by(phone_number: params[:phone_number])
		msg = "Hi @#{contact.username},\n\n"
		chat_msg = "Find a random person to chat with by sending /spin. You can then start a conversation with your random friend like this:\n\n@username: hi. \n\nOnce you have started the chat, you don't have to include the username again. Just send the message the way you normally do. But, if you want to chat with someone else, you will have to start with the username or your message will go to the wrong person. If you want to be very careful, you can always add the username to your message but most of the times, that is not neccessary."
		friends_msg = "You can get a list of the people you have chat with by sending /friends. This will also tell you the person you currently have an active chat with. This is the person to whom any message you send that doesn't start with @username goes to. This will help you in case you are not sure who you are talking to."
		content_msg = "You can find some content on here to keep you informed and entertained. To get a random joke, send /jokes, for quotes, /quotes and for news, you have a few options. /news gives you local news while the rest are self explanatory: /news/international, /news/tech, /news/sport.\n\nWhen you request for content, if you had not saved this number in your contacts, the links won't appear and you won't be able to click them. So, please make sure you save this number.\n\nYou can also share a joke or a quote with a friend. Just send /jokes/@username or /quotes/@username. Spread the love. :-)"
		invite_msg = "You can invite your friends by sending /invite/254722111777. Phone number must be in that format. You can invite more than one friend like this: /invite/254722111777,254722888333,254711888222."
		visible_msg = "Say you don't want to chat with anyone on this platform and you are here only for the wonderful content we provide i.e. the news, jokes, quotes and so on, you can make yourself invisible by sending in /visible/no. Once you are invisible, you won't appear when someone runs /spin or in search results. No one will be able to chat with you nor will you be able to chat with anyone. On the other hand, you will be able to get NEWS, JOKES, QUOTES and any other content we may provide. You can make yourself visible again by sending in /visible/yes. Now, you will be able to take advantage of all the awesome features we offer."
		asl_msg = "This command is used to find out more about a person. ASL stands for Age, Sex(Gender), Location. This is the format: /asl/@username\nReplace @username with the username of the person whose details you want to know."
		traffic_msg = "This lets you report some traffic situation. Your report is then tweeted at @ma3route who normally track traffic information on Twitter.\n\nIt take this format:\n\n/traffic/your_traffic_update\n\nFor example, you could send:\n\n/traffic/Crazy traffic jam on Mombasa Road. Barely moving."

		cmd = command_params(params[:text])
		if cmd
			if cmd.downcase == "chat"
				msg = chat_msg
			elsif cmd.downcase == "friends"
				msg = friends_msg
			elsif cmd.downcase == "content"
				msg = content_msg
			elsif cmd.downcase == "invite"
				msg = invite_msg
			elsif cmd.downcase == "visible"
				msg = visible_msg
			else
				msg = "Send either /help/chat, /help/friends, /help/content, /help/visible or /help/invite."
			end
		else
			msg << "Here are the commands you can use:\n\n/spin - Find a random person to chat with. For more help on how to chat, send /help/chat\n\n/friends - Gives you a list of the people you have chat with and also tells you the person you currently have an active chat with. To find out more, send /help/friends\n\n/profile - Lets you update your profile details. Send /profile to find out how to use it.\n\n/visible - Lets you change the visibility of your profile. Send /visible/yes or /visible/no. For more, send /help/visible.\n\n/search - Lets you search through the users. For now you can only search by gender. Send in exactly /search/male or /search/female.\n\n/asl - #{asl_msg}\n\n/traffic - #{traffic_msg}\n\n/news - Get the latest news.\n\n /jokes - Get a random joke.\n\n/quotes - Get a random quote.\n\nYou can also share jokes and quotes with a friend. To get more on how to get content like news, jokes and quotes, send /help/content\n\n/invite - Lets you invite people to this service. Format is like this: /invite/254722111777. For more, send /help/invite.\n\nEnjoy #{contact.male ? 'brother' : 'sister'}. :-)"
		end
		send_message params[:phone_number], msg
	end

	def self.invite params
		# Create record for the inivited person and associated it with the person who had invited them. Build a points based reward system.
		command_params(params[:text]).split(",").each do |phone_number|
			phone_number = phone_number.strip
			contact = Contact.find_by(phone_number: phone_number)
			if contact.nil?
				create_ongair_contact phone_number
				send_message phone_number.strip, "Hey there. You have been invited by @#{Contact.find_by(phone_number: params[:phone_number]).username.downcase} to try out this service which lets you chat on WhatsApp annonymously. Find interesting people outside your contacts and chat with them without revealing your number. You can also get NEWS, JOKES and QUOTES to keep you informed and entertained. You can try it out by adding this number to your contacts and replying to this message with the word 'JOIN'."# Don't worry.  You can opt out any time and no one will bother you anymore. Just send the word 'LEAVE' if you want to remove yourself."
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
		if !sender.chats.empty?
			msg = "Here is a list of people you have chat with:\n\n"
		end
		sender.chats.each do |chat|
			recipient = chat.recipient(sender)
			if !recipient.nil?
				if sender.active_chats.first == chat
					active = recipient.username
				end
				msg << "- @#{recipient.username} - #{recipient.age} | #{recipient.gender} | #{recipient.country} \n\n"
			end
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
		contact = nil
		msg = ""
		if command_params(params[:text])
			if command_params(params[:text]).downcase == "male"
				contact = Contact.male.where.not(id: current_contact.id).sample
			elsif command_params(params[:text]).downcase == "female"
				contact = Contact.female.where.not(id: current_contact.id).sample
			else
				msg = "Sorry. We couldn't understand you. Please send /spin to get any random person, /spin/male to get a random male or /spin/female to get a random female."
			end
		else
			contact = Contact.where.not(id: current_contact.id).sample
		end
		if current_contact.opted_in && !contact.nil?
			msg = "Here is your random match:\n\n- @#{contact.username} - #{contact.age} | #{contact.gender} | #{contact.country}"
		else
			send_message params[:phone_number], "Sorry. Remember you are invisible? If people can't see you, it is only fair that you don't see them either, right? You can make yourself visible by sending in /visible/on"
		end
		send_message params[:phone_number], msg
	end

	def self.asl params
		msg = ""
		if command_params(params[:text])
			username = command_params(params[:text]).gsub("@", "").strip
			contact = Contact.find_by(username: username)
			if !contact.nil?
				msg = "Here are the details for @#{contact.username}:\n\n Age: #{contact.age} \n\nGender: #{contact.gender} \n\nLocation: #{contact.country}"
			else
				msg = "Sorry! We don't have a user called @#{username}. Try again."
			end
		else
			msg = "This command is used to find out more about a person. ASL stands for Age, Sex(Gender), Location. This is the format: /asl/@username\nReplace @username with the username of the person whose details you want to know."
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
				source = "AJEnglish"
				src = "Al Jazeera"
				category = "international news"
			elsif command_params(params[:text]).downcase == "somali" || command_params(params[:text]).downcase == "somalia"
				source = "BBCSomali"
				src = "BBC Somali"
				category = "Somali news"
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

	def self.quotes params
		twitter = TwitterApi.new
		quote = (twitter.tweets("quotes4ursoul") + twitter.tweets("inspowerminds")).sample.text
		if !command_params(params[:text]).blank?
			username = command_params(params[:text]).sub("@", "").strip
			if !Contact.find_by(username: username).nil?
				send_message Contact.find_by(username: username).phone_number, "@#{Contact.find_by(phone_number: params[:phone_number]).username} has shared a quote with you:\n\n #{quote}"
				send_message params[:phone_number], "You have shared this quote with @#{username}:\n\n #{quote}"
			else
				send_message params[:phone_number], "You tried to share a quote with @#{username} which doesn't exist."
			end
		else
			send_message params[:phone_number], quote
		end
	end

	def self.stats params
		twitter = TwitterApi.new
		stat = twitter.tweets("optajoe").sample.text
		if !command_params(params[:text]).blank?
			username = command_params(params[:text]).sub("@", "").strip
			if !Contact.find_by(username: username).nil?
				send_message Contact.find_by(username: username).phone_number, "@#{Contact.find_by(phone_number: params[:phone_number]).username} has shared a football stat with you:\n\n #{stat}"
				send_message params[:phone_number], "You have shared this football stat with @#{username}:\n\n #{stat}"
			else
				send_message params[:phone_number], "You tried to share a stat with @#{username} which doesn't exist."
			end
		else
			send_message params[:phone_number], stat
		end
	end

	def self.traffic params
		twitter = TwitterApi.new
		tweet = command_params params[:text]
		# credits = " - by @#{Contact.find_by(phone_number: params[:phone_number]).username}"
		if !tweet.nil?
			if tweet.length <= 140 #(140 - credits.length)
				twitter.update(tweet, "ma3route")
			else
				send_message params[:phone_number], "Your message is too long. Try not to exceed 140 characters. Don't know the rationale behind it but that is what Twitter insists on."
			end
		else
			send_message params[:phone_number], "This lets you report some traffic situation. Your report is then tweeted at @ma3route who normally track traffic information on Twitter.\n\nIt take this format:\n\n/traffic/your_traffic_update\n\nFor example, you could send:\n\n/traffic/Crazy traffic jam on Mombasa Road. Barely moving."
		end
	end

	def self.games params
		send_message params[:phone_number], "Sorry. We are still working on that. Coming soon. Watch this space...."
	end

	def self.visible params
		text = command_params(params[:text]).downcase if !command_params(params[:text]).blank?
		msg = ""
		if text == "yes" || text == "on"
			Contact.find_by(phone_number: params[:phone_number]).update(opted_in: true)
			msg = "Your profile is now visible."
		elsif text == "no" || text == "off"
			Contact.find_by(phone_number: params[:phone_number]).update(opted_in: false)
			msg = "Your profile is now invisible."
		else
			msg = "Please send in /visible/yes or visible/no. Thanks."
		end
		send_message params[:phone_number], msg
	end

	def self.profile params
		msg = ""
		contact = Contact.find_by(phone_number: params[:phone_number])
		if command_params(params[:text]) && command_params(params[:text]).include?(":")
			field = command_params(params[:text]).split(":")[0].downcase.strip
			value = command_params(params[:text]).split(":")[1].downcase.strip
			if ["username", "age", "gender"].include?(field.downcase)
				if field.downcase == "username"
					if !Contact.username_exists?(value)
						contact.update(username: value)
						msg = "Profile update successful. Your new username is: #{value}."
					else
						if value == contact.username.downcase
							msg = "You have provided your current username (@#{value}). If you want to change it, provide a different value."
						else
							msg = "The username you have chosen (@#{value}) already exists. Please choose another."
						end
					end
				else
					contact.update("#{field}" => value)
					msg = "Profile update successful. Your new #{field} is: #{value}."
				end
			else
				msg = "You can only update username, age or gender. Try again."
			end
		else
			msg = "Send /profile/username:your_new_username to update your username or /profile/gender:your_new_gender to update your gender (Male or Female) or /profile/age:your_new_age to update your age."
		end
		send_message params[:phone_number], msg
	end

	def self.search_query text
		query = ""
		q_age = ""
		q_others = ""
		if text.include?(":")
			text.split(",").each do |q|
				if q.split(":")[0].downcase == "age" && q.split(":")[1].split("-").count == 2
					from = q.split(":")[1].split("-")[0]
					to = q.split(":")[1].split("-")[1]
					# q_age = "age >= #{q.split(":")[1].split("-")[0]} AND age <= #{q.split(":")[1].split("-")[1]}" 
					q_age = "age between #{from} AND #{to}" 
				elsif q.split(":")[0].downcase == "age" && q.split(":")[1].split("-").count == 1
					q_age = "age = #{q.split(":")[1]}"
				# elsif q.split(":")[0].downcase == "age"
					
				end
				if q.split(":")[0].downcase != "age"
					q_others << " AND #{q.split(":")[0]} ilike '#{q.split(":")[1]}'"
				# else
				# 	query << " #{q.split(":")[0]} ilike '#{q.split(":")[1]}'"
				end
			end
			if q_age.empty?
				query = q_others.sub!(" AND ", "")
			else
				query = q_age + q_others
			end
		else
			# a,s,l
			age = text.split(",")[0]
			gender = text.split(",")[1]
			location = text.split(",")[2]
			if age.include?("-")
				from = age.split("-")[0]
				to = age.split("-")[1]
				q_age = "age between #{from} AND #{to}"
			else
				q_age = "age = #{age}"
			end
			query = "#{q_age} AND gender ilike '#{gender}' AND country ilike '#{location}'"
		end
		query
	end

	def self.command_params message
		message.split("/")[2].strip if !message.split("/")[2].nil?
	end

	def self.send_message phone_number, message
		HTTParty.post("https://app.ongair.im/api/v1/base/send?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, text: message, thread: true})
	end

	def self.create_ongair_contact phone_number
		HTTParty.post("https://app.ongair.im/api/v1/base/create_contact?token=#{Rails.application.secrets.ongair_token}", body: {phone_number: phone_number, name: "anon"})
	end
end
