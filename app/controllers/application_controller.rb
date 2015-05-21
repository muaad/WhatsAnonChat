class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  private
  	def current_contact
  	  @current_contact ||= Contact.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  	end
end
