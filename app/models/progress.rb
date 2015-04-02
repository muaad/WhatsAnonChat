class Progress < ActiveRecord::Base
  belongs_to :contact
  belongs_to :step
end
