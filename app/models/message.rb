class Message < ActiveRecord::Base
  belongs_to :chat
  # belongs_to :from, :class_name => "Contact"
  # belongs_to :to, :class_name => "Contact"

  def self.get_usernames text
  	text.split(" ").select{|t| t.start_with?("@")}
  end
end
