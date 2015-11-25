class TelegramController < ApplicationController

    skip_before_action :verify_authenticity_token, only: [:handle_updates]

    def handle_updates
      logger.info "Received telegram update #{params}"

      update = Telegrammer::DataTypes::Update.new(
            update_id: params[:update_id],
            message: params[:message]
          )
      # p = {phone_number: update.message.from.id, text: update.message.text}
      message = update.message.text
      run_command(message)
      # eval("Command.#{command(message).action_path}(#{params})")

      # client = Konexta::Client.find(params[:id])
      # update = Telegrammer::DataTypes::Update.new(
      #   update_id: params[:update_id],
      #   message: params[:message]
      # )

      # message = Konexta::Message.find_by(external_id: params[:update_id], source: 'Telegram')
      # user = Konexta::User.find_or_create_by! external_id: update.message.from.id, user_type: 'Telegram', konexta_client_id: client.id
      # if message.nil?
      #   message = Konexta::Message.create! external_id: params[:update_id], text: update.message.text,
      #       konexta_user: user, source: 'Telegram', direction: 'IN', message_type: 'Text',
      #       konexta_client: client        

      #   user.update(name: get_display_name_for_telegram(update.message.from)) if user.name.blank?

      #   if client.is_zendesk?
      #     ZendeskWorker.perform_async(client.id, 'Telegram', user.id, message.text)
      #   else
      #     OngairWorker.perform_async(client.id, user.id, message.id)
      #   end
      # end

      render text: "ok"
    end

    def command message
      if is_command message
        return Command.enabled.find_by(name: message.split("/")[1].downcase.strip)
      end
    end

    def is_command message
      message.start_with?("/")
    end

    def run_command message
      # params = {phone_number: id, text: message}
      eval("Command.#{command(message).action_path}(#{params})")
    end

    private
      def get_display_name_for_telegram from        
        username = from.username
        name = [from.first_name, from.last_name].join(' ').strip

        username ||= name
      end

  end