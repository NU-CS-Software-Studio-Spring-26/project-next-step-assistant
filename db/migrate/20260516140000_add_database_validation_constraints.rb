class AddDatabaseValidationConstraints < ActiveRecord::Migration[8.1]
  def up
    add_check_constraint :jobs, "#{str_length_sql('title')} <= 200", name: "jobs_title_max_length"
    add_check_constraint :jobs, "#{str_length_sql('organization_name')} <= 200",
      name: "jobs_organization_name_max_length"
    add_check_constraint :jobs, "description IS NULL OR #{str_length_sql('description')} <= 5000",
      name: "jobs_description_max_length"
    add_check_constraint :jobs,
      "status IN ('saved','applied','interviewing','offer','accepted','rejected','withdrawn')",
      name: "jobs_status_allowed"

    add_check_constraint :projects, "#{str_length_sql('name')} <= 200", name: "projects_name_max_length"
    add_check_constraint :projects, "skills IS NULL OR #{str_length_sql('skills')} <= 255",
      name: "projects_skills_max_length"
    add_check_constraint :projects, "github_link IS NULL OR #{str_length_sql('github_link')} <= 2048",
      name: "projects_github_link_max_length"
    add_check_constraint :projects, "description IS NULL OR #{str_length_sql('description')} <= 5000",
      name: "projects_description_max_length"

    add_check_constraint :resumes, "#{str_length_sql('name')} <= 200", name: "resumes_name_max_length"
  end

  def down
    remove_check_constraint :jobs, name: "jobs_title_max_length"
    remove_check_constraint :jobs, name: "jobs_organization_name_max_length"
    remove_check_constraint :jobs, name: "jobs_description_max_length"
    remove_check_constraint :jobs, name: "jobs_status_allowed"

    remove_check_constraint :projects, name: "projects_name_max_length"
    remove_check_constraint :projects, name: "projects_skills_max_length"
    remove_check_constraint :projects, name: "projects_github_link_max_length"
    remove_check_constraint :projects, name: "projects_description_max_length"

    remove_check_constraint :resumes, name: "resumes_name_max_length"
  end

  private

  def str_length_sql(column)
    if connection.adapter_name.match?(/PostgreSQL/i)
      "char_length(#{column})"
    else
      "length(#{column})"
    end
  end
end
