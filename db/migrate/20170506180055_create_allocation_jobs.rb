class CreateAllocationJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :allocation_jobs do |t|
      t.references :author, foreign_key: { to_table: :users }
      t.references :project, foreign_key: true
      t.integer :status, default: 0
      t.datetime :failed_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
