class ChangeJobIdNullOnResumes < ActiveRecord::Migration[8.1]
  def change
    change_column_null :resumes, :job_id, true
  end
end
