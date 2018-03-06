class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :print, :auto_allocate, :reset_groups, :randomize, :good_fit]

  # GET /projects/1
  def show
    # project = Project.first
    @groups = Group.where(project: @project).includes(:tutor, :students)
    @auto_allocate_blocked = AllocationJob.blocked_year @project.course_year.id
    @auto_allocate_queue_size = AllocationJob.queue_size
    @queue = false if @auto_allocate_queue_size == 0
    respond_to do |format|
      format.html
      format.csv { send_data @project.to_csv, filename: "project-groups-#{Date.today}.csv" }
    end
  end

  # POST /projects/1/auto_allocate
  def auto_allocate
    # Only allow one auto allocation per course year to be happening at any one time

    # TODO: Use SQL instead of this loop if possible
    allowed = true
    AllocationJob.all.each do |job|
      if job.project.course_year == @project.course_year && (job.status == :pending || job.status == :in_progress)
        allowed = false
        break
      end
    end

    if allowed
      # Save the user's allocation prefs
      @allocation_config = current_user.allocation_config
      @allocation_config.update(allocation_config_params)

      if @allocation_config.save
        render json: @allocation_config, status: 200
      else
        render json: @allocation_config.errors, status: :unprocessable_entity
      end

      @project.auto_allocate_student_groups(current_user, @allocation_config)
      head :ok
    else
      head :bad_request
    end
  end

  def reset_groups
    @project.groups.each do |group|
      @project.holding_pen.students += group.students
      group.students.clear
    end
    head :ok
  end

  # GET /projects/reviews/1
  def reviews
    set_project
    @reviews = @project.reviews.all
    @review = @reviews.empty?

    @review = if params[:review_id] != '' && !params[:review_id].nil?
                @reviews.find(params[:review_id])
              else
                @reviews.first!
              end
    @holding_pen = @review.holding_pen_review
    @groups = @review.review_groups

    respond_to do |format|
      format.html
      format.csv { send_data @review.to_csv, filename: "review-groups-#{Date.today}.csv" }
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects/randomize/1
  def randomize
    @project.randomise_student_groups
  end

  # POST /projects/good_fit/1
  def good_fit
    @project.greedy_student_allocation
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      render json: @project, status: 200
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # POST /projects/student_group
  def student_group
    # params[:student_id] params[:new_group_id] params[:old_group_id] params[:project_id]

    render json: Project.move_student_to_group(params[:student_id], params[:project_id], params[:old_group_id], params[:new_group_id])
  end

  # POST /projects/student_review_group
  def student_review_group
    # params[:student_id] params[:new_group_id] params[:old_group_id] params[:project_id]

    render json: Review.move_student_to_review_group(params[:student_id], params[:review_id], params[:old_group_id], params[:new_group_id])
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      if request.xhr?
        head :ok
      else
        redirect_to @project, notice: 'Project was successfully updated.'
      end
    else
      if request.xhr?
        head 500
      else
        render :edit
      end
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to :back, notice: 'Project was successfully destroyed.'
  end

  def print
    @membership_by_student = {}
    @students = []
    @project.groups.each_with_index do |group, i|
      group.students.each do |student|
        @students << student
        @membership_by_student[student.id] = i + 1
      end
    end

    # Sort the array of students by last name
    @students.sort! { |a, b| a.last_name.downcase <=> b.last_name.downcase }
    render layout: 'print'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
    @holding_pen = @project.holding_pen
  end

  # Only allow a trusted parameter "white list" through.
  def project_params
    params.require(:project).permit(:name, :course_year_id, :num_review_periods)
  end

  def allocation_config_params
    params.require(:allocation_config).permit(
      :alpha_ability_difference,
      :alpha_different_tutor,
      :hard_iterations_limit,
      :no_improvement_stop,
      :tabu_queue_size
    )
  end
end
