class GiveUserCourseYear < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :course_year, foreign_key: true
  end
end
