class AddReviewHoldingPen < ActiveRecord::Migration[5.0]
  def change
    create_table :holding_pen_groups do |t|
      t.references :project, foreign_key: true
      t.timestamps
    end
    create_table :holding_pen_reviews do |t|
      t.references :project, foreign_key: true
      t.timestamps
    end
  end
end
