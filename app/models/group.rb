# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  tutor_id   :integer
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_groups_on_project_id  (project_id)
#  index_groups_on_tutor_id    (tutor_id)
#

class Group < ApplicationRecord
  belongs_to :tutor
  belongs_to :project, touch: true # also bump updated_at timestamp for project when group is touched
  has_and_belongs_to_many :students, after_add: :touch_updated_at, after_remove: :touch_updated_at

  validates :tutor, :project, presence: true

  def touch_updated_at(_category)
    touch if persisted?
  end
end
