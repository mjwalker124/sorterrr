# == Schema Information
#
# Table name: tutors
#
#  id             :integer          not null, primary key
#  first_name     :string
#  last_name      :string
#  course_year_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tutors_on_course_year_id  (course_year_id)
#

class Tutor < ApplicationRecord
  belongs_to :course_year
  has_many :groups, dependent: :destroy
  has_many :review_groups, dependent: :destroy

  validates :first_name, :last_name, :course_year, presence: true
end
