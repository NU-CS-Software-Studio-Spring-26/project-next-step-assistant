module Seeds
  module RealUsers
    PASSWORD = "Password1!"

    USERS = [
      { email: "jinxi.zhang@u.northwestern.edu", name: "Jinxi Zhang", presenter: true },
      { email: "ian.evensen@u.northwestern.edu", name: "Ian Evensen" },
      { email: "hongming.tan@u.northwestern.edu", name: "Hong-ming Tan" },
      { email: "harrison.gillespie@u.northwestern.edu", name: "Harrison Gillespie" },
      { email: "alex.chen@u.northwestern.edu", name: "Alex Chen" },
      { email: "maria.santos@u.northwestern.edu", name: "Maria Santos" },
      { email: "jordan.kim@u.northwestern.edu", name: "Jordan Kim" },
      { email: "sam.patel@u.northwestern.edu", name: "Sam Patel" },
      { email: "taylor.nguyen@u.northwestern.edu", name: "Taylor Nguyen" },
      { email: "casey.morgan@u.northwestern.edu", name: "Casey Morgan" },
      { email: "riley.brooks@u.northwestern.edu", name: "Riley Brooks" },
      { email: "morgan.lee@u.northwestern.edu", name: "Morgan Lee" }
    ].freeze

    PRESENTER_JOBS = [
      {
        title: "Software Engineer New Grad",
        organization_name: "Datadog",
        status: "saved",
        deadline: "2026-05-05",
        start_date: "2026-07-10",
        description: "Observability platform. Multiple teams hiring across backend, frontend, and infrastructure. Experience with distributed systems and monitoring preferred.",
        source: "Company website"
      },
      {
        title: "Data Science Intern",
        organization_name: "Spotify",
        status: "applied",
        deadline: "2026-05-10",
        start_date: "2026-06-15",
        description: "Recommendations team. Python, SQL, and experience with large-scale ML preferred.",
        source: "LinkedIn"
      },
      {
        title: "Software Engineer Intern",
        organization_name: "Google",
        status: "applied",
        deadline: "2026-05-15",
        start_date: "2026-06-22",
        description: "Summer internship on the Search Infrastructure team. Build distributed systems in Go and C++.",
        source: "Handshake"
      },
      {
        title: "Game Developer Intern",
        organization_name: "Riot Games",
        status: "applied",
        deadline: "2026-05-15",
        start_date: "2026-06-15",
        description: "Work on Valorant systems team. C++ experience required.",
        source: "Referral"
      },
      {
        title: "Product Engineering Intern",
        organization_name: "Linear",
        status: "saved",
        deadline: "2026-05-20",
        start_date: "2026-07-01",
        description: "Small team, high ownership. Ship features end-to-end across the issue tracking product.",
        source: "Company website"
      },
      {
        title: "iOS Developer Intern",
        organization_name: "Airbnb",
        status: "saved",
        deadline: "2026-05-25",
        start_date: "2026-06-22",
        description: "Native iOS development in Swift. Help build the host experience.",
        source: "Indeed"
      },
      {
        title: "DevOps Engineer Intern",
        organization_name: "GitHub",
        status: "interviewing",
        deadline: "2026-05-30",
        start_date: "2026-06-22",
        description: "CI/CD and platform reliability. Kubernetes, Terraform, and Go.",
        source: "Career fair"
      },
      {
        title: "Full Stack Developer",
        organization_name: "Vercel",
        status: "applied",
        deadline: "2026-06-01",
        start_date: "2026-08-15",
        description: "New grad role on the Next.js team. Open source contribution experience is a plus.",
        source: "LinkedIn"
      },
      {
        title: "ML Engineer",
        organization_name: "OpenAI",
        status: "interviewing",
        deadline: "2026-04-28",
        start_date: "2026-06-01",
        description: "Research engineering on large language model systems. Strong Python and ML fundamentals.",
        source: "Referral"
      },
      {
        title: "Backend Engineer Intern",
        organization_name: "Stripe",
        status: "offer",
        deadline: "2026-06-10",
        start_date: "2026-06-15",
        description: "Payments infrastructure team. Ruby, Java, and API design experience.",
        source: "Handshake"
      },
      {
        title: "Security Engineer Intern",
        organization_name: "Cloudflare",
        status: "rejected",
        deadline: "2026-04-15",
        start_date: "2026-06-01",
        description: "Application security and threat detection. Networking fundamentals required.",
        source: "Company website"
      },
      {
        title: "Frontend Engineer Intern",
        organization_name: "Figma",
        status: "saved",
        deadline: "2026-06-20",
        start_date: "2026-07-01",
        description: "Design tooling in TypeScript and WebAssembly. Strong UI engineering skills.",
        source: "LinkedIn"
      }
    ].freeze

    PRESENTER_PROJECTS = [
      {
        name: "Next Step Assistant",
        description: "Job search tracker for students with deadlines, resumes, and portfolio projects.",
        github_link: "https://github.com/NU-CS-Software-Studio-Spring-26/project-next-step-assistant",
        skills: "Ruby on Rails, PostgreSQL, Hotwire, Bootstrap"
      },
      {
        name: "Travel Planner",
        description: "Trip planning app with collaborative itineraries and budget tracking.",
        github_link: "https://github.com/jinxi-zhang/travel-planner",
        skills: "React, Node.js, PostgreSQL"
      },
      {
        name: "Resume Optimizer",
        description: "Tailors resume bullet points to job descriptions using keyword analysis.",
        github_link: "https://github.com/jinxi-zhang/resume-optimizer",
        skills: "Ruby on Rails, NLP, PDF parsing"
      },
      {
        name: "Campus Events API",
        description: "REST API for Northwestern campus events with search and calendar export.",
        github_link: "https://github.com/jinxi-zhang/campus-events-api",
        skills: "Rails API, SQLite, iCalendar"
      },
      {
        name: "Interview Prep Tracker",
        description: "Logs practice problems, mock interviews, and study streaks.",
        github_link: "https://github.com/jinxi-zhang/interview-prep-tracker",
        skills: "JavaScript, Chart.js, localStorage"
      }
    ].freeze

    OTHER_USER_JOBS = [
      { title: "Software Engineer Intern", organization_name: "Microsoft", status: "applied" },
      { title: "Product Manager Intern", organization_name: "Adobe", status: "saved" },
      { title: "Data Analyst Intern", organization_name: "Netflix", status: "interviewing" }
    ].freeze

    OTHER_USER_PROJECTS = [
      { name: "Budget Tracker", skills: "React, Firebase" },
      { name: "Study Group Finder", skills: "Rails, PostgreSQL" }
    ].freeze

    module_function

    def seed!
      remove_legacy_demo_data
      users = create_users
      seed_presenter_account(users.fetch(:presenter))
      seed_other_users(users.fetch(:others))
      write_credentials_file
    end

    def remove_legacy_demo_data
      legacy = User.find_by(email: "demo@example.com")
      legacy&.destroy

      Job.where("organization_name LIKE ?", "Seed Company%").destroy_all
      Resume.where("name LIKE ?", "Demo Resume%").destroy_all
    end

    def create_users
      presenter = nil
      others = []

      USERS.each do |attrs|
        user = User.find_or_initialize_by(email: attrs[:email])
        user.password = PASSWORD
        user.password_confirmation = PASSWORD
        # Ensure seeded accounts skip the post-GitHub password-setup gate on re-seed.
        user.password_set_at = Time.current
        user.save!

        if attrs[:presenter]
          presenter = user
        else
          others << user
        end
      end

      { presenter: presenter, others: others }
    end

    def seed_presenter_account(user)
      resume = seed_presenter_resume(user)
      seed_presenter_jobs(user, resume)
      seed_presenter_projects(user)
    end

    def seed_presenter_resume(user)
      user.resumes.where(name: "Software Engineering Resume").destroy_all

      pdf_data = Seeds::PresenterResumePdf.render

      resume = user.resumes.build(name: "Software Engineering Resume")
      resume.file.attach(
        io: StringIO.new(pdf_data),
        filename: "jinxi_zhang_software_engineering_resume.pdf",
        content_type: "application/pdf",
        identify: false
      )
      resume.save!
      resume
    end

    def seed_presenter_jobs(user, resume)
      PRESENTER_JOBS.each_with_index do |attrs, index|
        job = Job.find_or_initialize_by(title: attrs[:title], user: user)
        deadline = Date.parse(attrs[:deadline])
        start_date = Date.parse(attrs[:start_date])
        # Keep home deadline tracker useful after the original fixed dates pass.
        if deadline < Date.current
          deadline = Date.current + (index + 1).weeks
          start_date = Date.current + (index + 10).weeks
        end

        job.assign_attributes(
          organization_name: attrs[:organization_name],
          status: attrs[:status],
          deadline: deadline,
          start_date: start_date,
          description: attrs[:description],
          source: attrs[:source],
          resume: index.zero? ? resume : job.resume
        )
        job.save!
      end
    end

    def seed_presenter_projects(user)
      PRESENTER_PROJECTS.each do |attrs|
        project = Project.find_or_initialize_by(name: attrs[:name], user: user)
        project.assign_attributes(
          description: attrs[:description],
          github_link: attrs[:github_link],
          skills: attrs[:skills]
        )
        project.save!
      end
    end

    def seed_other_users(users)
      users.each_with_index do |user, index|
        OTHER_USER_JOBS.each_with_index do |attrs, job_index|
          job = Job.find_or_initialize_by(title: "#{attrs[:title]} #{job_index + 1}", user: user)
          job.assign_attributes(
            organization_name: attrs[:organization_name],
            status: attrs[:status],
            deadline: Date.current + (index + job_index + 2).weeks,
            start_date: Date.current + (index + job_index + 10).weeks,
            description: "Application tracked in Next Step Assistant.",
            source: "Handshake"
          )
          job.save!
        end

        OTHER_USER_PROJECTS.each do |attrs|
          project = Project.find_or_initialize_by(name: "#{attrs[:name]} (#{user.email.split('@').first})", user: user)
          project.assign_attributes(
            description: "Portfolio project for internship applications.",
            github_link: "https://github.com/#{user.email.split('@').first}/#{attrs[:name].parameterize}",
            skills: attrs[:skills]
          )
          project.save!
        end
      end
    end

    def write_credentials_file
      path = Rails.root.join("db/real_user_credentials.txt")
      lines = [
        "Next Step Assistant — real user credentials",
        "Generated: #{Time.current}",
        "Login uses email + password (there is no separate username field).",
        "",
        "PRESENTATION ACCOUNT (full demo data: jobs, projects, PDF resume, dashboard):",
        "  Email:    jinxi.zhang@u.northwestern.edu",
        "  Password: #{PASSWORD}",
        "",
        "All other accounts use the same password:",
        ""
      ]

      USERS.each do |attrs|
        marker = attrs[:presenter] ? " [PRESENTER]" : ""
        lines << "  #{attrs[:name]}#{marker}"
        lines << "    Email:    #{attrs[:email]}"
        lines << "    Password: #{PASSWORD}"
        lines << ""
      end

      lines << "Run on Heroku: heroku run bin/rails db:seed -a next-step-assistant"
      File.write(path, lines.join("\n"))
      puts "Wrote credentials to #{path}"
    end
  end
end
