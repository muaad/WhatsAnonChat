require 'json'
class SMS

  def initialize
      @user = ENV['SMS_GATEWAY_USER']
      @password = ENV['SMS_GATEWAY_PASSWORD']
      @url = ENV['SMS_GATEWAY_URL']
      @shortcode = ENV['SMS_SHORTCODE']
      @campaign_id = ENV['SMS_CAMPAIGN_ID']
      @channel = ENV['SMS_CHANNEL']
    end

    def send to, message
      if Rails.env.production?
        `curl -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" -d "username=#{@user}&password=#{@password}&MSISDN=#{to}&content=#{message}&channel=#{@channel}&shortcode=#{@shortcode}&campaignid=#{@campaign_id}&premium=1&multitarget=1" #{@url}`
      else
        puts "<>>>>>> TARGET: INFO\nMSISDN: #{to}\nTEXT: #{message}"
      end
    end
end