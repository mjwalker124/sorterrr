class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string :first_name
      t.string :last_name
      t.integer :registration_number
      t.string :email
      t.integer :ability
      t.boolean :overseas
      t.references :course_year, foreign_key: true
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
