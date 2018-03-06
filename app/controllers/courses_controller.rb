class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  def index
    @current_nav_identifier = :admin
    @current_subnav_identifier = :courses
    @courses = Course.all
    @course = Course.new
  end

  # GET /courses/1
  def show
    respond_to do |format|
      format.json do
        render json: { course: @course }
      end
    end
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  def create
    @course = Course.new(course_params)

    render json: { course: @course } if @course.save
  end

  # PATCH/PUT /courses/1
  def update
    render json: { course: @course } if @course.update(course_params)
  end

  # DELETE /courses/1
  def destroy
    @course.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def course_params
    params.require(:course).permit(:name, :code)
  end
end
