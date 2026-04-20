json.extract! job, :id, :title, :organization_name, :deadline, :start_date, :description, :status, :created_at, :updated_at
json.url job_url(job, format: :json)
