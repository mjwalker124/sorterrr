# This handles the AllocationJobsController
class AllocationJobsController < ApplicationController
  include ActionController::Live

  # GET /allocation_job/1
  def show
    # project = Project.first
  end

  # GET /allocation_job/project_info/1
  # This is the stream to show the number of project in the allocation queue
  def project_info
    # @auto_allocate_blocked = AllocationJob.blocked_year @project.course_year.id
    project = Project.find(params[:project_id])
    # @auto_allocate_queue_size = AllocationJob.queue_size
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, retry: 3000, event: "message")

    sse.write(auto_allocate_blocked: AllocationJob.blocked_year(project.course_year.id), auto_allocate_queue_size: AllocationJob.queue_size)
  rescue IOError
    puts 'SSE Error'
  ensure
    response.stream.close
  end

  # GET /allocation_job/queue_size
  def queue_size
    @queue_size = AllocationJob.queue_size
    render json: { queue_size: @queue_size }
  end
end
