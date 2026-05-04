class AddUserToResumes < ActiveRecord::Migration[8.1]
  def change
    add_reference :resumes, :user, null: true, foreign_key: true
  end
end
