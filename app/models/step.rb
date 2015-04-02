class Step < ActiveRecord::Base
	has_many :progress
	has_many :contacts, through: :progress
end
