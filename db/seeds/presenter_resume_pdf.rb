# frozen_string_literal: true

require "prawn"

Prawn::Fonts::AFM.hide_m17n_warning = true

module Seeds
  module PresenterResumePdf
    module_function

    def render
      Prawn::Document.new(page_size: "LETTER", margin: 48) do |pdf|
        pdf.font "Helvetica"

        pdf.text "Jinxi Zhang", size: 22, style: :bold
        pdf.move_down 4
        pdf.text "jinxi.zhang@u.northwestern.edu  |  GitHub: github.com/jinxi-zhang  |  Evanston, IL",
          size: 10, color: "333333"
        pdf.move_down 16

        section pdf, "Education" do
          pdf.text "Northwestern University", style: :bold, size: 11
          pdf.text "B.S. Computer Science — Expected June 2026", size: 10
          pdf.text "Relevant coursework: Software Studio, Data Structures, Systems Programming, Databases",
            size: 10, color: "444444"
        end

        section pdf, "Experience" do
          bullet pdf, "Software Studio — Team Developer, Next Step Assistant (Rails 8)"
          pdf.indent(12) do
            pdf.text "Built a job-search tracker with Devise auth, Active Storage resumes, dashboard analytics, " \
                     "and keyword-based match assistant for internship applications.",
              size: 10, color: "444444"
          end
          pdf.move_down 8
          bullet pdf, "Teaching Assistant — Introductory Programming Lab"
          pdf.indent(12) do
            pdf.text "Mentored students on debugging, Git workflows, and test-driven development in weekly labs.",
              size: 10, color: "444444"
          end
        end

        section pdf, "Projects" do
          bullet pdf, "Next Step Assistant — Ruby on Rails, PostgreSQL, Hotwire, Bootstrap"
          bullet pdf, "Travel Planner — React, Node.js, PostgreSQL"
          bullet pdf, "Resume Optimizer — Ruby on Rails, PDF parsing, keyword analysis"
          bullet pdf, "Campus Events API — Rails API, SQLite, iCalendar export"
        end

        section pdf, "Technical Skills" do
          pdf.text "Languages: Ruby, JavaScript, Python, SQL, HTML/CSS", size: 10
          pdf.text "Frameworks: Ruby on Rails, React, Hotwire (Turbo/Stimulus), Bootstrap", size: 10
          pdf.text "Tools: Git, GitHub Actions, Heroku, PostgreSQL, Active Storage, RSpec/Minitest", size: 10
        end
      end.render
    end

    def section(pdf, title)
      pdf.text title.upcase, size: 11, style: :bold, color: "1a1a1a"
      pdf.stroke_horizontal_rule
      pdf.move_down 6
      yield
      pdf.move_down 10
    end
    module_function :section

    def bullet(pdf, text)
      pdf.text "• #{text}", size: 10
      pdf.move_down 4
    end
    module_function :bullet
  end
end
