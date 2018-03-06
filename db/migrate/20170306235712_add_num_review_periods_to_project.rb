class AddNumReviewPeriodsToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :num_review_periods, :integer
  end
end
