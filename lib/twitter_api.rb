class TwitterApi
	def client
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = Rails.application.secrets.twitter_consumer_key
		  config.consumer_secret     = Rails.application.secrets.twitter_consumer_secret
		  config.access_token        = Rails.application.secrets.twitter_access_token
		  config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
		end
	end

	def tweets user
		client.user_timeline(user).reject{|t| t.retweet?}
	end

	def update msg, receipient
		if !receipient.nil?
			message = "@#{receipient} #{msg}"
		else
			message = msg
		end
		client.update(message)
	end
end