class Contact < ActiveRecord::Base
	has_many :progress, dependent: :delete_all
  has_many :steps, through: :progress
end
