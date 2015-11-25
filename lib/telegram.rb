require 'telegrammer'

class Telegram
	def self.bot
		Telegrammer::Bot.new(Rails.application.secrets.telegram_token)
	end

	def self.set_webhook url="https://telespin.herokuapp.com/bots/updates"
		bot.set_webhook(url)
	end

	def self.send_message phone_number, text
		bot.send_message(chat_id: phone_number, text: text)
	end
end