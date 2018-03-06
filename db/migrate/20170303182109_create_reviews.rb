class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.references :tutor, foreign_key: true
      t.references :student, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
