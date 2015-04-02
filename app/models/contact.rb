class Contact < ActiveRecord::Base
	has_many :progress, dependent: :delete_all
  has_many :steps, through: :progress

  # after_create :set_country

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

  def set_country phone_number
  	country_code = Phony.format(phone_number).split(" ")[0].gsub("+", "")
  	country = Country.find_all_by_country_code(country_code)[0][1]["name"]
  	short_name = Country.find_all_by_country_code(country_code)[0][1]["alpha2"].downcase
  	contact.country = country
  end
end
