# This is the course year controller,
class CourseYearsController < ApplicationController
  before_action :set_course_year, only: [:show, :edit, :update, :destroy]

  # GET /course_years
  def index
    @current_nav_identifier = :admin
    @current_subnav_identifier = :course_years
    @course_years = CourseYear.all
    @course_year = CourseYear.new
  end

  # This gets the data for the course year
  # GET /course_years/1
  def show
    respond_to do |format|
      format.json do
        render json: { course_year: @course_year }
      end
    end
  end

  # GET /course_years/1/edit
  def edit
  end

  # POST /course_years
  def create
    @course_year = CourseYear.new(course_year_params)

    render json: { course_year: @course_year } if @course_year.save
  end

  # PATCH/PUT /course_years/1
  def update
    return unless @course_year.update(course_year_params)
    render json: { course_year: @course_year }
  end

  # DELETE /course_years/1
  def destroy
    @course_year.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course_year
    @course_year = CourseYear.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def course_year_params
    params.require(:course_year).permit(:name)
  end
end
