# Next Step Assistant — Wiki

Supplementary documentation for the Next Step Assistant project.

## Problem

Students applying to internships and full-time roles juggle dozens of opportunities at once. Spreadsheets work but force you to maintain your own structure; full ATS-style products (Huntr, Teal) are heavy and built for established job seekers. Notes apps are too unstructured to surface what's due next.

Next Step Assistant is the lightweight middle ground: a structured list of jobs and projects with just enough fields to stay organized, sortable by deadline so you always know what's next.

## Users

- **Primary:** undergraduate students in technical majors searching for summer internships.
- **Secondary:** seniors and recent grads searching for full-time roles, who also need a place to point recruiters to portfolio projects.

## Design

### Object-oriented design

### Data model

Two independent ActiveRecord models, no associations in the MVP:

| Model   | Fields                                                                                  |
| ------- | --------------------------------------------------------------------------------------- |
| Job     | `title`, `organization_name`, `deadline`, `start_date`, `description`, `status`         |
| Project | `name`, `github_link`, `skills`, `description`                                          |

`status` on Job is a string field constrained at the form level by a dropdown of standard application stages (`Saved`, `Applied`, `Interviewing`, `Offer`, `Accepted`, `Rejected`, `Withdrawn`).

`skills` on Project is a comma-separated string rendered as pill badges in the UI.

### UI

- Home page (`/`): hero + cards summarizing the two areas.
- Jobs index (`/jobs`): card list ordered by deadline (nulls last), then most recently created.
- Projects index (`/projects`): card list of portfolio projects.
- Each entity has standard `new`, `edit`, and `show` views built on Bootstrap 5 cards and forms.

## Tech stack

- Ruby on Rails 8.1
- Bootstrap 5.3 (loaded via CDN in `app/assets/stylesheets/app.css`)
- SQLite (development), PostgreSQL (production on Heroku)
- Hotwire (Turbo + Stimulus)
- Importmap for JavaScript
- Minitest + GitHub Actions for CI

## Out of scope for MVP (future features)

- User accounts and authentication — multi-user with private data per account.
- Linking projects to specific job applications (many-to-many).
- File attachments (resume versions, cover letters per application).
- Calendar integration / deadline reminders via email.
- Status-change history and analytics ("how many days at each stage").
- Tags and full-text search across jobs and projects.
- Public profile / sharable portfolio view of projects for recruiters.
- Browser extension to clip job postings into the tracker.
- Mobile-friendly PWA install flow (the manifest is scaffolded but disabled).

## Similar products and inspiration

- [Huntr](https://huntr.co) — visual board-based job tracker, freemium.
- [Teal](https://www.tealhq.com) — job tracker + resume builder.
- [Simplify](https://simplify.jobs) — autofill applications and tracker.
- Generic spreadsheets — the baseline this product competes with.

The differentiator is simplicity and the dual focus on portfolio projects, which the others largely ignore.

## Project structure highlights

- `app/controllers/jobs_controller.rb`, `app/controllers/projects_controller.rb` — standard Rails resource controllers.
- `app/views/jobs/`, `app/views/projects/` — Bootstrap-card-styled CRUD views.
- `app/helpers/jobs_helper.rb` — `JOB_STATUSES` constant and `job_status_badge_class` helper for status pill colors.
- `app/assets/stylesheets/app.css` — custom home-page styling and Bootstrap import.
- `db/seeds.rb` — 12 sample jobs and 10 sample projects for demos.
- `.github/workflows/ci.yml` — CI pipeline (Brakeman, RuboCop, Minitest, system tests).

## Repository

GitHub: <https://github.com/NU-CS-Software-Studio-Spring-26/project-next-step-assistant>
