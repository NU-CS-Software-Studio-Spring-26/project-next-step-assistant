class AddResumeToJobs < ActiveRecord::Migration[8.1]
  def change
    add_reference :jobs, :resume, null: true, foreign_key: true
  end
end
