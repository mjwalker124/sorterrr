class DashboardController < ApplicationController
  # GET /
  def index
    @course_years = CourseYear.all
    @projects = Project.includes(:course_year).order updated_at: :desc
    @project = Project.new
  end
end
