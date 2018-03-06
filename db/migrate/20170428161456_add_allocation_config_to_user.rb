class AddAllocationConfigToUser < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :allocation_config, foreign_key: true
  end
end
