class CreateJoinTableHoldingPenStudent < ActiveRecord::Migration[5.0]
  def change
    create_join_table :holding_pens, :students do |t|
      # t.index [:holding_pen_id, :student_id]
      # t.index [:student_id, :holding_pen_id]
    end
  end
end
