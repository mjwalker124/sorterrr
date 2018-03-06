class TutorsController < ApplicationController
  before_action :set_tutor, only: [:show, :edit, :update, :destroy]

  # GET /tutors
  def index
    @current_nav_identifier = :admin
    @current_subnav_identifier = :tutors
    @tutors = Tutor.all.includes(:course_year)
    @tutor = Tutor.new
  end

  # GET /tutors/1
  def show
    respond_to do |format|
      format.json do
        render json: { tutor: @tutor }
      end
    end
  end

  # GET /tutors/1/edit
  def edit
  end

  # POST /tutors
  def create
    @tutor = Tutor.new(tutor_params)

    render json: { tutor: @tutor } if @tutor.save
  end

  # PATCH/PUT /tutors/1
  def update
    render json: { tutor: @tutor } if @tutor.update(tutor_params)
  end

  # DELETE /tutors/1
  def destroy
    @tutor.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tutor
    @tutor = Tutor.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def tutor_params
    params.require(:tutor).permit(:first_name, :last_name, :course_year_id)
  end
end
