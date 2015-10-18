class Contact < ActiveRecord::Base
	reverse_geocoded_by :latitude, :longitude
	after_validation :reverse_geocode
	
	before_create { generate_token(:auth_token) }
	has_secure_password

	def generate_token(column)
	  begin
	    self[column] = SecureRandom.urlsafe_base64
	  end while Contact.exists?(column => self[column])
	end

	has_many :progress, dependent: :delete_all
	has_many :steps, through: :progress
	has_many :chats
	has_many :friends, :through => :chats

	scope :opted_in, -> { where(opted_in: true) }
	scope :male, -> { where("gender like 'male'") }
	scope :female, -> { where("gender like 'female'") }

	def complete_profile step, value
		begin
			if step.name.downcase == "username"
				value = value.downcase
			end
			update("#{step.name.downcase}" => value)
		rescue Exception => e
			
		end
	end

	def profile_incomplete
		username.nil? || gender.nil? || age.nil?
	end

	def self.check_format step, message
		error = nil
		if step == "Username"
			pattern = /^(?=.*\D)[-\w]+$/
			# Needs to be one word, cannot include anything except - and _, cannot be a number. Must also be unique
			if username_exists?(message)
				error = "The username you have chosen, #{message}, already exists. Please choose another."
			elsif (pattern =~ message).nil?
				if message.split(" ").length > 1
					error = "No spaces please. Usernames should be all one word. And, try to make it short, too, so, it will be easy for people to find you."
				elsif is_number?(message)
					error = "You sent #{message}. Usernames cannot be a number. It should be made up of letters or a combination of letters and digits."
				else
					error = "You sent #{message}. Your username can only contain letters, numbers or one of - and _"
				end
			end
		elsif step == "Age"
			# has to be number
			if !is_number?(message)
				error = "You sent #{message}. Age should be a number and cannot contain non digits. Please enter a valid age again."
			end
		elsif step == "Gender"
			# has to be either Male or Female
			if !["male", "female"].include?(message.downcase)
				error = "You entered #{message}. You can only be either Male or Female."
			end
		end
		error
	end

	def self.is_number?(object)
	  true if Float(object) rescue false
	end

	def male
		!gender.nil? && gender == "Male"
	end

	def female
		!gender.nil? && gender == "Female"
	end

	def chats
		Chat.where("contact_id = ? OR friend_id = ?", id, id)
	end

	def chats_with contact
		chats.where("contact_id = ? OR friend_id = ?", contact.id, contact.id)
	end

	def last_chat
		chats.order("updated_at desc").first
	end

	def active_chats
		# Chat.active.where("contact_id = ? OR friend_id = ?", id, id)
		chats.active
	end

	def buddies
		buds = []
		chats.each do |chat|
			recipient = chat.recipient(self)
			if !recipient.nil?
				buds << "@#{recipient.username}"
			end
		end
		buds
	end

	def self.username_exists? username
		!Contact.where("username like '#{username}'").empty?
	end
end
