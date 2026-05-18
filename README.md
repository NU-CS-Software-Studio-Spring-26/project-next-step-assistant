# Next Step Assistant

A web app that helps students manage the job search end-to-end: track applications and deadlines, maintain a portfolio project list, store PDF resumes, and get lightweight keyword-based fit feedback on each role.

**Live (Heroku):** <https://next-step-assistant-a4dab79f7e69.herokuapp.com/>

Supplementary docs: [wiki.md](wiki.md)

## Features

- **Jobs** — CRUD, status workflow, search, status filter (Turbo partial updates), Pagy pagination, resume attachment
- **Projects** — CRUD, search, pagination
- **Resumes** — PDF upload library (validated), link to jobs
- **Home** — Combined deadline tracker with date-range filter
- **Accounts** — Devise authentication (email/password); optional GitHub OAuth when `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` are set
- **Match assistant** — Local Ruby keyword overlap on job show pages (no external AI APIs)
- **Accessibility** — Skip link, visible focus styles, link underlines, ARIA on key UI
- **PWA** — Web manifest and minimal service worker for installable home-screen shortcut

## Tech stack

- Ruby on Rails 8.1, Hotwire (Turbo + Stimulus), Bootstrap 5.3
- SQLite (development), PostgreSQL (production)
- Devise, OmniAuth GitHub (optional), Pagy, Active Storage
- Minitest + GitHub Actions CI

## Team

- Ian Evensen
- Hong-ming Tan
- Harrison Gillespie
- Jinxi Zhang

## Communication

- **Primary channel:** Slack
- **Stand-ups:** check-ins in the team channel by 6:30pm Tuesday/Thursday/Sunday
- **Synchronous meetings:** Sunday afternoons
- **Decision making:** simple majority; 2-2 ties go to the area owner
- **Conflict resolution:** team channel first; escalate to professor/TA if unresolved within 48 hours

## Deployment

Production runs on **Heroku** with PostgreSQL. Deploys are triggered from the main branch (see `.github/workflows` and team runbook). Environment variables include database URL and, optionally, GitHub OAuth credentials.

Health check: `/up`

## Local development

### Requirements

- Ruby (see `.ruby-version`)
- Bundler
- SQLite (development) / PostgreSQL (production)

### Setup

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Open <http://localhost:3000>. Demo seed user password is documented in `db/seeds.rb`.

Optional GitHub sign-in (development):

```bash
export GITHUB_CLIENT_ID=your_client_id
export GITHUB_CLIENT_SECRET=your_client_secret
```

### Tests

```bash
bin/rails test
```

CI runs on every push and pull request (`.github/workflows/ci.yml`).
