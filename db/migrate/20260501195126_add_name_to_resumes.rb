class AddNameToResumes < ActiveRecord::Migration[8.1]
  def change
    add_column :resumes, :name, :string, null: false, default: "Resume"
  end
end
