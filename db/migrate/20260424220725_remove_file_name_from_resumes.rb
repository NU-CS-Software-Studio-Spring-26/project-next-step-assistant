class RemoveFileNameFromResumes < ActiveRecord::Migration[8.1]
  def change
    remove_column :resumes, :file_name, :string
  end
end
