class CreateJoinTableGroupStudent < ActiveRecord::Migration[5.0]
  def change
    create_join_table :groups, :students do |t|
      # t.index [:group_id, :student_id]
      # t.index [:student_id, :group_id]
    end
  end
end
