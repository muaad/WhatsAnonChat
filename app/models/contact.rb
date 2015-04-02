class Contact < ActiveRecord::Base
	has_many :progress, dependent: :delete_all
  has_many :steps, through: :progress

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
end
