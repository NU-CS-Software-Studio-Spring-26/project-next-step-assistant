class AddScalabilityIndexesAndRequireUserId < ActiveRecord::Migration[8.1]
  def up
    default_user_id = User.order(:id).pick(:id)
    if default_user_id
      { jobs: Job, projects: Project, resumes: Resume }.each_value do |model|
        model.where(user_id: nil).update_all(user_id: default_user_id)
      end
    end

    change_column_null :jobs, :user_id, false
    change_column_null :projects, :user_id, false
    change_column_null :resumes, :user_id, false

    add_index :jobs, [ :user_id, :deadline ]
    add_index :jobs, [ :user_id, :status ]
  end

  def down
    remove_index :jobs, [ :user_id, :status ]
    remove_index :jobs, [ :user_id, :deadline ]

    change_column_null :jobs, :user_id, true
    change_column_null :projects, :user_id, true
    change_column_null :resumes, :user_id, true
  end
end
