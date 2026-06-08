# Real user accounts for demos and production (12 users = 3 x team size).
# Credentials are written to db/real_user_credentials.txt (gitignored).
#
# Presentation account:
#   Email:    jinxi.zhang@u.northwestern.edu
#   Password: Password1!

require_relative "seeds/real_users"
require_relative "seeds/presenter_resume_pdf"

# Avoid Solid Queue on hosts (e.g. Heroku) where queue tables are not provisioned.
ActiveJob::Base.queue_adapter = :inline

Seeds::RealUsers.seed!

presenter = User.find_by!(email: "jinxi.zhang@u.northwestern.edu")
puts "Seed complete. #{User.count} users."
puts "Presenter: #{presenter.email} (#{presenter.jobs.count} jobs, #{presenter.projects.count} projects, #{presenter.resumes.count} resumes)."
