class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :verification, :verify]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    # @contact = Contact.new(contact_params)
    # if @contact.save
    #   if @contact.verification_code.nil?
    #     @contact.update(verification_code: generate_verification_code)
    #   end

    #   if !@contact.verified
    #     Command.send_message @contact.phone_number, "Hi #{@contact.name},\n\nThanks for signing up for Spin. Just one last step. We need to verify that this is your number. Enter this verification code at spin.im #{@contact.verification_code} and you will be able to use this service.\n\nThanks."
    #   end
    #   cookies.permanent[:spin_auth_token] = @contact.auth_token
    #   redirect_to root_url, notice: "Thank you for signing up!"
    # else
    #   render "new"
    # end
    contact = Contact.last
    cookies.permanent[:spin_auth_token] = contact.auth_token if contact
    render json: {success: true}
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    cookies.delete(:spin_auth_token)
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def verification
    
  end

  def verify
    code = params[:verification_code]
    matched = @contact.verification_code == code

    if matched
      redirect_to root_url, notice: "You have now been verified! Thank you."
    else
      render 'verification'
    end
  end

  def friends
    contact = Contact.find_by(auth_token: params[:auth_token])
    render json: {friends: contact.buddies}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :phone_number, :gender, :age, :country, :opted_id, :password, :password_confirmation, :dob, :verification_code)
    end
end
