class WizardsController < ApplicationController
  before_action :set_wizard, only: [:show, :edit, :update, :destroy]

  # GET /wizards
  # GET /wizards.json
  def index
    @wizards = Wizard.all
  end

  # GET /wizards/1
  # GET /wizards/1.json
  def show
  end

  # GET /wizards/new
  def new
    @wizard = Wizard.new
  end

  # GET /wizards/1/edit
  def edit
  end

  # POST /wizards
  # POST /wizards.json
  def create
    @wizard = Wizard.new(wizard_params)

    respond_to do |format|
      if @wizard.save
        format.html { redirect_to @wizard, notice: 'Wizard was successfully created.' }
        format.json { render :show, status: :created, location: @wizard }
      else
        format.html { render :new }
        format.json { render json: @wizard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wizards/1
  # PATCH/PUT /wizards/1.json
  def update
    respond_to do |format|
      if @wizard.update(wizard_params)
        format.html { redirect_to @wizard, notice: 'Wizard was successfully updated.' }
        format.json { render :show, status: :ok, location: @wizard }
      else
        format.html { render :edit }
        format.json { render json: @wizard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wizards/1
  # DELETE /wizards/1.json
  def destroy
    @wizard.destroy
    respond_to do |format|
      format.html { redirect_to wizards_url, notice: 'Wizard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wizard
      @wizard = Wizard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wizard_params
      params.require(:wizard).permit(:name, :account_id)
    end
end
