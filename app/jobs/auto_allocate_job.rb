AutoAllocateJob = Struct.new(:current_user, :project, :allocation_config) do
  def perform
    allocation_job = AllocationJob.where(project: project, status: :pending).first
    allocation_job.status = :in_progress
    allocation_job.save

    allocator = Allocator.new(project, allocation_config)
    allocator.allocate
  end

  def queue_name
    'allocation_queue'
  end

  def max_attempts
    1
  end

  def enqueue(_job)
    AllocationJob.create!(author: current_user, project: project)
  end

  def error(_job, _exception)
    allocation_job = AllocationJob.where(project: project, status: :in_progress).first
    allocation_job.destroy
  end

  def success(_job)
    # puts "Allocation job successful"
    allocation_job = AllocationJob.where(project: project, status: :in_progress).first
    allocation_job.status = :completed
    allocation_job.save
  end
end
