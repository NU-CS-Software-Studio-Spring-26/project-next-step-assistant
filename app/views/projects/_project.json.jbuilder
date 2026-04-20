json.extract! project, :id, :name, :github_link, :description, :skills, :created_at, :updated_at
json.url project_url(project, format: :json)
