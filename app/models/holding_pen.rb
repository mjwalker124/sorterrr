# == Schema Information
#
# Table name: holding_pens
#
#  id         :integer          not null, primary key
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_holding_pens_on_project_id  (project_id)
#

class HoldingPen < ApplicationRecord
  belongs_to :project, touch: true # also bump updated_at timestamp for project when group is touched
  has_and_belongs_to_many :students

  validates :project, presence: true
end
