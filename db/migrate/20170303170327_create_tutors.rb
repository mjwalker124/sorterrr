class CreateTutors < ActiveRecord::Migration[5.0]
  def change
    create_table :tutors do |t|
      t.string :first_name
      t.string :last_name
      t.references :course_year, foreign_key: true

      t.timestamps
    end
  end
end
