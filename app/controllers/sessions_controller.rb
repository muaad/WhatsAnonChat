class SessionsController < ApplicationController
  def new
  end
  
  def create
    contact = Contact.find_by(phone_number: params[:email])
    if contact && contact.authenticate(params[:password])
      cookies.permanent[:auth_token] = contact.auth_token
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now.alert = "Phone number or password is invalid"
      render "new"
    end
  end
  
  def destroy
    cookies.delete(:auth_token)
    redirect_to root_url, notice: "Logged out!"
  end
end
