class ModifyReviews < ActiveRecord::Migration[5.0]
  def change
    change_table :reviews do |t|
      t.remove_references :student, foreign_key: true
    end

    create_join_table :reviews, :students do |t|
      # t.index [:review_id, :student_id]
      # t.index [:student_id, :review_id]
    end
  end
end
