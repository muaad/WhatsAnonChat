class WhatsApp
	def self.send_message phone_number, message
		HTTParty.post("http://app.ongair.im/api/v1/base/send", body: {token: Rails.application.secrets.ongair_token, phone_number: phone_number, text: message, thread: true})
	end

	def self.send_image phone_number, image_url
		token = Rails.application.secrets.ongair_token
		url = "http://app.ongair.im/api/v1/base/send_image?token=#{token}"

		# image_url = "bottle.png"
		response = HTTParty.post(url, body: { phone_number: phone_number, image: image_url, thread: true }, debug_output: $stdout)
		sent = response.parsed_response["sent"]
	end
end