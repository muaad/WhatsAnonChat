class Slack
	def self.send channel="#customerservice", username="Spin", text
		payload = {channel: channel, username: username, text: text, icon_emoji: ":ghost:"}.to_json
		HTTParty.post(ENV['SLACK_URL'], body: payload)
	end
end