# Next Step Assistant

A web app that helps students manage the job search end-to-end: track every application, deadline, and follow-up alongside the portfolio projects you'd point a recruiter to.

## MVP

The MVP supports two core entities:

- **Jobs** — opportunities you're tracking, with title, organization, deadline, start date, description, and a status (Saved → Applied → Interviewing → Offer → Accepted / Rejected / Withdrawn).
- **Projects** — portfolio work you'd reference in applications, with name, GitHub link, skills, and description.

For each entity, users can create, view, edit, and delete entries from a clean Bootstrap-styled list.

## Team

- Ian Evensen
- Hong-ming Tan
- Harrison Gillespie
- Jinxi Zhang

## Deployment

Live on Heroku: **https://next-step-assistant-a4dab79f7e69.herokuapp.com/**

## Communication

The team agrees to the following communication and decision-making rules for the remainder of the class:

- **Primary channel:** Slack
- **Stand-ups:** check-ins in the team channel by 6:30pm Tuesday/Thursday/Sunday
- **Synchronous meetings:** Sunday afternoons
- **Decision making:** decisions made by simple majority; if 2-2, the team member who owns the affected area breaks the tie
- **Conflict resolution:** disagreements are surfaced in the team channel first; if unresolved within 48 hours, escalate to the professor or TA.

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

The app is then available at <http://localhost:3000>.

### Running tests

```bash
bin/rails test
```

Tests also run automatically on every push and pull request via GitHub Actions (`.github/workflows/ci.yml`).
