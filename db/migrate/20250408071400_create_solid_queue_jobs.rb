class CreateSolidQueueJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :job_class
      t.text :arguments
      t.string :status, default: 'pending'
      t.datetime :enqueued_at
      t.datetime :performed_at
      t.datetime :failed_at

      t.timestamps
    end
  end
end
