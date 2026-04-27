# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding jobs..."

jobs = [
  {
    title: "Software Engineer Intern",
    organization_name: "Google",
    deadline: Date.new(2026, 5, 15),
    start_date: Date.new(2026, 6, 22),
    description: "Summer internship on the Search Infrastructure team. Build distributed systems in Go and C++.",
    status: "applied"
  },
  {
    title: "Frontend Developer Intern",
    organization_name: "Meta",
    deadline: Date.new(2026, 5, 1),
    start_date: Date.new(2026, 6, 15),
    description: "Work on Instagram Web. React, TypeScript, GraphQL. Must be a rising junior or senior.",
    status: "interviewing"
  },
  {
    title: "Backend Engineer Intern",
    organization_name: "Stripe",
    deadline: Date.new(2026, 4, 30),
    start_date: Date.new(2026, 6, 8),
    description: "Payments infrastructure. Ruby on Rails and Scala. Strong systems background preferred.",
    status: "offer"
  },
  {
    title: "Product Engineering Intern",
    organization_name: "Linear",
    deadline: Date.new(2026, 5, 20),
    start_date: Date.new(2026, 7, 1),
    description: "Small team, high ownership. Ship features end-to-end across the issue tracking product.",
    status: "saved"
  },
  {
    title: "Data Science Intern",
    organization_name: "Spotify",
    deadline: Date.new(2026, 5, 10),
    start_date: Date.new(2026, 6, 15),
    description: "Recommendations team. Python, SQL, experience with large-scale ML preferred.",
    status: "applied"
  },
  {
    title: "iOS Developer Intern",
    organization_name: "Airbnb",
    deadline: Date.new(2026, 5, 25),
    start_date: Date.new(2026, 6, 22),
    description: "Native iOS development in Swift. Help build the host experience.",
    status: "saved"
  },
  {
    title: "Machine Learning Intern",
    organization_name: "Anthropic",
    deadline: Date.new(2026, 4, 28),
    start_date: Date.new(2026, 6, 1),
    description: "Research engineering on safety-focused LLM systems. Strong Python and ML fundamentals.",
    status: "interviewing"
  },
  {
    title: "Full Stack Developer",
    organization_name: "Vercel",
    deadline: Date.new(2026, 6, 1),
    start_date: Date.new(2026, 8, 15),
    description: "New grad role on the Next.js team. Open source contribution experience a plus.",
    status: "applied"
  },
  {
    title: "Software Engineer New Grad",
    organization_name: "Datadog",
    deadline: Date.new(2026, 5, 5),
    start_date: Date.new(2026, 7, 10),
    description: "Observability platform. Multiple teams hiring across backend, frontend, and infrastructure.",
    status: "rejected"
  },
  {
    title: "DevOps Engineer Intern",
    organization_name: "GitHub",
    deadline: Date.new(2026, 5, 30),
    start_date: Date.new(2026, 6, 22),
    description: "CI/CD and platform reliability. Kubernetes, Terraform, Go.",
    status: "saved"
  },
  {
    title: "Research Intern",
    organization_name: "Microsoft Research",
    deadline: Date.new(2026, 4, 25),
    start_date: Date.new(2026, 6, 1),
    description: "12-week paid research internship. Open to PhD and exceptional undergrad candidates.",
    status: "withdrawn"
  },
  {
    title: "Game Developer Intern",
    organization_name: "Riot Games",
    deadline: Date.new(2026, 5, 15),
    start_date: Date.new(2026, 6, 15),
    description: "Work on Valorant systems team. C++ experience required.",
    status: "applied"
  }
]

jobs.each do |attrs|
  Job.find_or_create_by!(title: attrs[:title], organization_name: attrs[:organization_name]) do |j|
    j.assign_attributes(attrs)
  end
end

puts "  Created #{Job.count} jobs"

puts "Seeding projects..."

projects = [
  {
    name: "Next Step Assistant",
    github_link: "https://github.com/NU-CS-Software-Studio-Spring-26/project-next-step-assistant",
    skills: "Ruby on Rails, Bootstrap, PostgreSQL, Heroku",
    description: "A job and project tracker for students searching for internships and full-time roles. Built with Rails 8 and Bootstrap 5."
  },
  {
    name: "Distributed Key-Value Store",
    github_link: "https://github.com/example/kv-store",
    skills: "Go, Raft, gRPC, Docker",
    description: "Implementation of a Raft-based distributed key-value store with linearizable reads and dynamic membership."
  },
  {
    name: "Real-time Chat App",
    github_link: "https://github.com/example/chat-app",
    skills: "TypeScript, React, Node.js, WebSockets, Redis",
    description: "Slack-style chat application with channels, threads, and presence indicators. Supports 10k concurrent users per server."
  },
  {
    name: "ML Image Classifier",
    github_link: "https://github.com/example/image-classifier",
    skills: "Python, PyTorch, FastAPI",
    description: "Fine-tuned ResNet-50 for plant disease classification. 94% accuracy on held-out test set across 38 classes."
  },
  {
    name: "Personal Portfolio Site",
    github_link: "https://github.com/example/portfolio",
    skills: "Next.js, Tailwind CSS, MDX",
    description: "Static portfolio with markdown-based blog and dark mode. Deployed on Vercel with automatic OG image generation."
  },
  {
    name: "Stock Price Predictor",
    github_link: "https://github.com/example/stock-predictor",
    skills: "Python, TensorFlow, Pandas, yfinance",
    description: "LSTM model for short-term price movement prediction with backtesting framework and risk-adjusted metrics."
  },
  {
    name: "iOS Habit Tracker",
    github_link: "https://github.com/example/habit-tracker",
    skills: "Swift, SwiftUI, Core Data, HealthKit",
    description: "Native iOS app for daily habit tracking with streak visualization and Apple Health integration."
  },
  {
    name: "REST API Boilerplate",
    github_link: "https://github.com/example/api-boilerplate",
    skills: "Node.js, Express, TypeScript, PostgreSQL, Jest",
    description: "Production-ready Express API template with auth, validation, structured logging, and CI/CD."
  },
  {
    name: "Compiler for Toy Language",
    github_link: "https://github.com/example/toylang",
    skills: "Rust, LLVM, Parsing",
    description: "End-to-end compiler for a small statically-typed language. Targets LLVM IR with basic optimizations."
  },
  {
    name: "Recipe Recommendation Engine",
    github_link: "https://github.com/example/recipe-rec",
    skills: "Python, Flask, scikit-learn, Postgres",
    description: "Collaborative-filtering recommender for recipes based on user ratings and ingredient preferences."
  }
]

projects.each do |attrs|
  Project.find_or_create_by!(name: attrs[:name]) do |p|
    p.assign_attributes(attrs)
  end
end

puts "  Created #{Project.count} projects"
puts "Done. Total entries: #{Job.count + Project.count}"
