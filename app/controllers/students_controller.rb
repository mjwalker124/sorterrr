class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  # GET /students
  def index
    @current_nav_identifier = :admin
    @current_subnav_identifier = :students
    @students = Student.all.includes(:course_year, :course)
    @student = Student.new
  end

  def import
    course_year = CourseYear.find params[:student][:course_year_id]
    Student.import_from_file params[:student][:file].path, course_year
    redirect_to students_path, notice: 'Students have been imported'
  end

  def import_pictures
    Student.import_pictures_from_file params[:student][:file].path
    redirect_to students_path, notice: 'Student pictures have been imported'
  end

  # GET /students/1
  def show
    respond_to do |format|
      format.html
      format.json do
        if params[:project_id]
          current_project_id = params[:project_id]
          current_group_id = params[:current_group]

          review_groups = @student.reload.review_groups
          project_groups = @student.reload.groups
          current_project = Project.find(current_project_id)
          if params[:review] == 'true'
            review_id = params[:review_id]
            review = Review.find(review_id)
            reviewers, reviewer_ids = Review.review_groups_excluding_current_group(review_groups.order('created_at desc'), current_group_id, current_project, review)
            tutors, tutor_ids = Project.project_groups(project_groups, current_project_id)
          else
            reviewers, reviewer_ids = Review.non_current_reviewers review_groups, current_project_id
            tutors, tutor_ids = Project.project_groups_excluding_current_group(project_groups.order('created_at desc'), current_group_id, current_project)
          end
          json_response = {
            student: @student,
            course_name: @student.course.name,
            image_url: @student.image_url,
            reviewers: reviewers,
            reviewer_ids: reviewer_ids,
            tutors: tutors,
            tutor_ids: tutor_ids
          }
          render json: json_response
        else
          render json: { student: @student }
        end
      end
      format.png { send_file "uploads/images/students/#{@student.registration_number}.png", type: 'image/png', disposition: 'inline' }
    end
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  def create
    @student = Student.new(student_params)

    render json: { student: @student } if @student.save
  end

  # PATCH/PUT /students/1
  def update
    render json: { student: @student } if @student.update(student_params)
  end

  # DELETE /students/1
  def destroy
    @student.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def student_params
    params.require(:student).permit(:first_name, :last_name, :registration_number, :email, :ability, :overseas, :course_year_id, :course_id)
  end
end
