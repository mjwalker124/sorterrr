class CreateAllocationConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :allocation_configs do |t|
      t.float :alpha_ability_difference
      t.float :alpha_different_tutor
      t.integer :hard_iterations_limit
      t.integer :no_improvement_stop
      t.integer :tabu_queue_size
    end
  end
end
