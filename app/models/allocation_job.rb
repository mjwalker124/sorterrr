# == Schema Information
#
# Table name: allocation_jobs
#
#  id           :integer          not null, primary key
#  author_id    :integer
#  project_id   :integer
#  status       :integer          default("pending")
#  failed_at    :datetime
#  completed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_allocation_jobs_on_author_id   (author_id)
#  index_allocation_jobs_on_project_id  (project_id)
#

class AllocationJob < ApplicationRecord
  belongs_to :project
  belongs_to :author, class_name: 'User'

  validates :author, :project, presence: true
  enum status: [:pending, :in_progress, :completed, :failed]

  def self.queue_size
    AllocationJob.where(status: [:pending, :in_progress]).size
  end

  def self.blocked_year(year)
    AllocationJob.joins(project: :course_year).where('course_years.id = ?', year.to_s).where(status: [:pending, :in_progress]).exists?
  end
end
