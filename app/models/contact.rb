class Contact < ActiveRecord::Base
	has_many :progress, dependent: :delete_all
  has_many :steps, through: :progress
  has_many :chats
  has_many :friends, :through => :chats

  # scope	:profile_incomplete, -> { where("username = NULL OR gender = NULL OR age = NULL") }
  scope :profile_incomplete, (lambda do |id|
    where("username = NULL OR gender = NULL OR age = NULL AND id = #{id}")
  end )
  scope	:opted_in, -> { where(opted_in: true) }

  def complete_profile step, value
  	begin
  		update("#{step.name.downcase}" => value)
  	rescue Exception => e
  		
  	end
  end

  def profile_incomplete
  	username.nil? || gender.nil? || age.nil?
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

  def active_chats
    Chat.where("active = ? AND contact_id = ? OR friend_id = ?", true, id, id)
  end
end
