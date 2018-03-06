class ModifyReviews2 < ActiveRecord::Migration[5.0]
  def change
    drop_table :reviews
    drop_table :holding_pen_reviews

    create_table :reviews do |t|
      t.references :project, foreign_key: true
    end

    create_table :review_groups do |t|
      t.references :tutor, foreign_key: true
      t.references :review, foreign_key: true

      t.timestamps
    end

    create_join_table :review_groups, :students do |t|
      # t.index [:review_group_id, :student_id]
      # t.index [:student_id, :review_group_id]
    end

    create_join_table :holding_pen_reviews, :students do |t|
      # t.index [:holding_pen_review_id, :student_id]
      # t.index [:student_id, :holding_pen_review_id]
    end

    create_table :holding_pen_reviews do |t|
      t.references :review, foreign_key: true
      t.timestamps
    end
  end
end
