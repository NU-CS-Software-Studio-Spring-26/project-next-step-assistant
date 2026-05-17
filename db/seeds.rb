# Demo account:
# email: demo@example.com
# password: Password1!
#
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

demo_user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.password = "Password1!"
end

Job.where(user_id: nil).update_all(user_id: demo_user.id)
Project.where(user_id: nil).update_all(user_id: demo_user.id)
Resume.where(user_id: nil).update_all(user_id: demo_user.id)

Job.find_or_create_by!(
  title: "Software Engineer New Grad",
  organization_name: "Datadog",
  user: demo_user
) do |job|
  job.status = "saved"
  job.deadline = Date.parse("2026-05-05")
  job.start_date = Date.parse("2026-07-10")
  job.description = "Observability platform. Multiple teams hiring across backend, frontend, and infrastructure."
end

Job.find_or_create_by!(
  title: "Data Science Intern",
  organization_name: "Spotify",
  user: demo_user
) do |job|
  job.status = "applied"
  job.deadline = Date.parse("2026-05-10")
  job.start_date = Date.parse("2026-06-15")
  job.description = "Recommendations team. Python, SQL, experience with large-scale ML preferred."
end

Job.find_or_create_by!(
  title: "Software Engineer Intern",
  organization_name: "Google",
  user: demo_user
) do |job|
  job.status = "applied"
  job.deadline = Date.parse("2026-05-15")
  job.start_date = Date.parse("2026-06-22")
  job.description = "Summer internship on the Search Infrastructure team. Build distributed systems in Go and C++."
end

Job.find_or_create_by!(
  title: "Game Developer Intern",
  organization_name: "Riot Games",
  user: demo_user
) do |job|
  job.status = "applied"
  job.deadline = Date.parse("2026-05-15")
  job.start_date = Date.parse("2026-06-15")
  job.description = "Work on Valorant systems team. C++ experience required."
end

Job.find_or_create_by!(
  title: "Product Engineering Intern",
  organization_name: "Linear",
  user: demo_user
) do |job|
  job.status = "saved"
  job.deadline = Date.parse("2026-05-20")
  job.start_date = Date.parse("2026-07-01")
  job.description = "Small team, high ownership. Ship features end-to-end across the issue tracking product."
end

Job.find_or_create_by!(
  title: "iOS Developer Intern",
  organization_name: "Airbnb",
  user: demo_user
) do |job|
  job.status = "saved"
  job.deadline = Date.parse("2026-05-25")
  job.start_date = Date.parse("2026-06-22")
  job.description = "Native iOS development in Swift. Help build the host experience."
end

Job.find_or_create_by!(
  title: "DevOps Engineer Intern",
  organization_name: "GitHub",
  user: demo_user
) do |job|
  job.status = "saved"
  job.deadline = Date.parse("2026-05-30")
  job.start_date = Date.parse("2026-06-22")
  job.description = "CI/CD and platform reliability. Kubernetes, Terraform, Go."
end

Job.find_or_create_by!(
  title: "Full Stack Developer",
  organization_name: "Vercel",
  user: demo_user
) do |job|
  job.status = "applied"
  job.deadline = Date.parse("2026-06-01")
  job.start_date = Date.parse("2026-08-15")
  job.description = "New grad role on the Next.js team. Open source contribution experience a plus."
end

Job.find_or_create_by!(
  title: "ML Engineer",
  organization_name: "OpenAI",
  user: demo_user
) do |job|
  job.status = "interviewing"
  job.deadline = Date.parse("2026-04-28")
  job.start_date = Date.parse("2026-06-01")
  job.description = "Research engineering on large language model systems. Strong Python and ML fundamentals."
end

Project.find_or_create_by!(
  name: "Travel App",
  user: demo_user
) do |project|
  project.description = "AI-powered travel planner"
  project.github_link = "https://github.com/example/travel-app"
  project.skills = "React, Node.js, AI"
end

Project.find_or_create_by!(
  name: "Resume Optimizer",
  user: demo_user
) do |project|
  project.description = "Tailors resumes for job descriptions"
  project.github_link = "https://github.com/example/resume-optimizer"
  project.skills = "Ruby on Rails, OpenAI API, PostgreSQL"
end

if demo_user.resumes.empty?
  # No PDF attached; validations require a file on normal create — seed bypasses that for a demo placeholder row.
  resume = demo_user.resumes.build(name: "Software Resume")
  resume.save!(validate: false)
end

puts "Seed complete. Demo user: demo@example.com (#{demo_user.jobs.count} jobs, #{demo_user.projects.count} projects, #{demo_user.resumes.count} resumes)."
