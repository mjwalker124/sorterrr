# == Schema Information
#
# Table name: holding_pen_reviews
#
#  id         :integer          not null, primary key
#  review_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_holding_pen_reviews_on_review_id  (review_id)
#

class HoldingPenReview < ApplicationRecord
  belongs_to :review, touch: true # also bump updated_at timestamp for project when group is touched
  has_and_belongs_to_many :students

  validates :review, presence: true
end
