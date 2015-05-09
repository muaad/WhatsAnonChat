class Mxit
	def self.send_message to, message
		connection = MxitApi.new(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], {grant_type: 'client_credentials', scope: 'message/send'})
		connection.send_message(to: to, from: ENV['MY_APP'], body: message)
	end
end