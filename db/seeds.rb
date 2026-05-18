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

# Extra records for pagination demos (Pagy default: 20 per page).
extra_job_titles = [
  "Platform Engineer Intern", "Security Engineer Intern", "QA Engineer Intern",
  "Mobile Engineer Intern", "Cloud Engineer Intern", "Site Reliability Intern",
  "Research Engineer Intern", "Robotics Software Intern", "AR/VR Engineer Intern",
  "Blockchain Developer Intern", "Embedded Systems Intern", "Database Engineer Intern",
  "Technical Program Manager Intern", "Solutions Engineer Intern", "Sales Engineer Intern",
  "Growth Engineer Intern", "Analytics Engineer Intern", "Computer Vision Intern",
  "NLP Engineer Intern", "Infrastructure Engineer Intern", "Frontend Engineer Intern",
  "Backend Engineer Intern", "Full Stack Intern", "Product Designer Intern",
  "UX Research Intern"
]

extra_job_titles.each_with_index do |title, index|
  Job.find_or_create_by!(title: title, user: demo_user) do |job|
    job.organization_name = "Seed Company #{index + 1}"
    job.status = Job::STATUSES.values[index % Job::STATUSES.size]
    job.deadline = Date.current + (index + 1).weeks
    job.start_date = Date.current + (index + 10).weeks
    job.description = "Seeded job for pagination and filter testing."
  end
end

extra_project_names = [
  "Budget Tracker", "Campus Events App", "Study Group Finder", "Recipe API",
  "Fitness Logger", "Portfolio CMS", "Hackathon Scheduler", "Open Source Dashboard",
  "Interview Prep Bot", "Course Review Site", "Parking Finder", "Club Management",
  "Volunteer Matcher", "Language Flashcards", "Music Collaboration", "Photo Organizer",
  "Task Automator", "Weather Widget", "Expense Splitter", "Reading List",
  "Habit Tracker", "Code Snippet Vault", "API Mock Server", "Markdown Notes",
  "Team Retro Tool"
]

extra_project_names.each_with_index do |name, index|
  Project.find_or_create_by!(name: name, user: demo_user) do |project|
    project.description = "Seeded project for list and search testing."
    project.github_link = "https://github.com/example/#{name.parameterize}"
    project.skills = "Ruby, Rails, PostgreSQL"
  end
end

25.times do |index|
  resume_name = "Demo Resume #{index + 1}"
  next if demo_user.resumes.exists?(name: resume_name)

  resume = demo_user.resumes.build(name: resume_name)
  resume.save!(validate: false)
end

puts "Seed complete. Demo user: demo@example.com (#{demo_user.jobs.count} jobs, #{demo_user.projects.count} projects, #{demo_user.resumes.count} resumes)."
