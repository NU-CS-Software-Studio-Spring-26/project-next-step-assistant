# Next Step Assistant — Wiki

Supplementary documentation for the Next Step Assistant project.

## Problem

Students applying to internships and full-time roles juggle dozens of opportunities at once. Spreadsheets work but force you to maintain your own structure; full ATS-style products are heavy and built for established job seekers.

Next Step Assistant is a lightweight middle ground: structured jobs and projects, resume storage, a deadline dashboard, and simple keyword-based fit hints—without external AI services.

## Users

- **Primary:** undergraduate students in technical majors searching for summer internships.
- **Secondary:** seniors and recent grads who also need a place to reference portfolio projects during applications.

## Data model

| Model   | Key fields | Notes |
| ------- | ---------- | ----- |
| User    | `email`, Devise auth, optional `provider` / `uid` (GitHub) | Owns all records below |
| Job     | `title`, `organization_name`, `deadline`, `start_date`, `description`, `status`, `resume_id` | Status enum; belongs to user |
| Project | `name`, `github_link`, `skills`, `description` | Belongs to user |
| Resume  | `name`, PDF via Active Storage | Belongs to user; optional on jobs |

Database constraints include length limits and allowed job status values. Cross-user access returns 404.

## Authentication

- **Email/password** via Devise (password complexity validation on sign-up and password change).
- **GitHub OAuth** optional when `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` are set; links to existing accounts by email when possible.
- All resource controllers require sign-in; data is scoped with `current_user`.

## UI overview

- **Home (`/`)** — Hero, job deadline tracker with date filter and pagination.
- **Jobs** — Index with search, status filter (Turbo Frame), pagination; show/edit with resume picker and Match assistant.
- **Projects** — Index with search and pagination; standard CRUD.
- **Resumes** — PDF library with upload validation; paginated index.
- **About / Privacy** — Static pages linked from the footer.

## Pagination

[List pagination](https://ddnexus.github.io/pagy/) via **Pagy** (default 20 items per page) on jobs, projects, resumes, and the home deadline list.

## Accessibility

Documented improvements in `app/assets/stylesheets/app.css`:

- Skip-to-main-content link; main landmark focus target
- Visible `:focus-visible` rings on links, buttons, and form controls
- Links distinguished by underline, not color alone
- ARIA on navigation, alerts, filter regions, and decorative icons where applicable

## Match assistant (local “AI-style” feature)

`app/services/job_match_service.rb` compares job description keywords to project text/skills and resume metadata (names, filenames). Outputs overlap terms, gap terms, and High / Medium / Low compatibility. No OpenAI or external ML; no PDF text extraction.

## JavaScript UX

- Stimulus `flash_controller` — auto-dismiss alerts (pauses on hover/focus)
- `data-turbo-submits-with` on forms for submit feedback
- Turbo Frame on jobs index for filter/search without full page reload

## PWA

- Manifest: `app/views/pwa/manifest.json.erb`, linked in the layout
- Service worker: `app/views/pwa/service-worker.js.erb`, registered on load
- Installable on supported browsers; offline functionality is minimal

## Tech stack

- Ruby on Rails 8.1
- Bootstrap 5.3 (CDN in `app.css`)
- SQLite (development), PostgreSQL (Heroku production)
- Hotwire, Importmap, Active Storage, Pagy, Devise, OmniAuth GitHub
- Minitest + GitHub Actions

## Project structure highlights

- `app/controllers/` — `jobs`, `projects`, `resumes`, `home`, `pages`, Devise/OmniAuth callbacks
- `app/services/job_match_service.rb` — keyword match logic
- `app/javascript/controllers/` — Stimulus (e.g. flash)
- `app/helpers/jobs_helper.rb` — status and match-level badges
- `db/seeds.rb` — demo users, jobs, projects, resumes
- `.github/workflows/ci.yml` — CI (Brakeman, RuboCop, tests)

## Still out of scope / future

- Parsing resume PDF body text for matching
- Email deadline reminders or calendar sync
- Status-change history and analytics dashboards
- Public recruiter-facing portfolio pages
- Browser extension to clip job postings
- Many-to-many links between projects and specific applications

## Similar products

- [Huntr](https://huntr.co), [Teal](https://www.tealhq.com), [Simplify](https://simplify.jobs) — fuller-featured trackers and autofill
- Spreadsheets — baseline competitor

Differentiator: simplicity, portfolio + resume focus, and private per-user data without heavyweight ATS features.

## Repository

GitHub: <https://github.com/NU-CS-Software-Studio-Spring-26/project-next-step-assistant>
