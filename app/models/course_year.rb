# == Schema Information
#
# Table name: course_years
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CourseYear < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :tutors, dependent: :destroy

  validates :name, presence: true
end
