# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# personal-website

The owner's personal website at **www.adhyaanilkumar.com**. Repo created 2026-11-22; the name follows the lowercase, hyphenated convention (`<username>.github.io` isn't needed for a custom domain).

Status: V0 in progress (spec approved 2026-11-24; tasks in `sdlc/v0/tasks.md`). Stack (D12): Astro 7 static output, TypeScript strict, React islands, Tailwind 4, Node 22 (`.nvmrc`, 22.23.4 or newer) with npm. Hosting (D11): S3 + CloudFront.

**Commands** (GNU make from MSYS2 bash, like social-grid; after a fresh clone run `npm ci` and `npx playwright install chromium` once):
- `make build`: static site into `dist/`.
- `make lint`: ESLint (warnings fail), Prettier check, `astro check`.
- `make test`: Vitest unit tests (`tests/unit`), then Playwright on real Chromium at 1440x900 and 390x844 (`tests/e2e`; it builds and serves the site itself).
- `make preview`: serves `dist/` at http://127.0.0.1:4321 (run `make build` first).
- CI (`.github/workflows/ci.yml`, job `ci`) runs lint, test and build on pull requests; actions are pinned to commit SHAs.

## Hard rules
- **Facts come from the resume.** The source is `C:\git\jarvis\resume\adhya_resume.tex` (master copy on Overleaf). Never invent skills, roles, dates or numbers.
- **It's public.** Never put a phone number, home address, ID, bank or account numbers, OTPs or passwords on the site or in the repo. Ask the owner before publishing any other personal detail, such as an email address, photo or employer detail.
- **Email exception (owner, 2026-11-24):** the owner's email may stay in `resume/adhya_resume.tex` and `sdlc/v0/intent.md`. It never appears on the site or in the resume PDF; contact goes through the form.
- **Budget:** ₹4,300 a month across all personal projects. The domain is registered at Cloudflare (the same account as `social-grid.dev`). Prefer free hosting. State the monthly INR cost and stop for approval before adding anything paid.
- **Gmail is drafts only.** Never send anything for the owner.

## How we work: the AI-native SDLC
This is the same method as `C:\git\friday` and `C:\git\social-grid`: Anthropic's *AI-Native SDLC Playbook* (PDF in `C:\git\ultron`). Use those repos as references. Every stage commits an artifact that the next stage reads, and the owner approves each one. Cycles live in `sdlc/v<n>/`.
1. **Plan:** propose the version (big feature 1→2, small feature 1→1.1, tweak or fix 1.1→1.1.1); the owner confirms. Write `intent.md` with an Author/Status line and these sections: Problem, Proposed outcome, Affected users and systems, Constraints, Open questions.
2. **Design:** write `spec.md` from the approved intent. Resolve every open question with the owner, flag concerns, and record each decision with its date. It includes an **MCP plan**: which MCP servers to use (e.g. playwright for browser checks), which agent uses each, and why. **Stop for review.**
3. **Tasks:** split the spec into `tasks.md`. Each task gets an id, title, description, acceptance criteria (each with a `verify_with` line), depends-on and ships-independently. A visual criterion is checked in a real browser, never by a unit test alone. **Stop for review.**
4. **Build:** a task starts in plan mode and commits its `plan.md` (files that change, order of work, risks, proof, MCPs used) before any code. If the code departs from the plan, update `plan.md` in the same commit. Build one **wave** at a time (owner, 2026-11-24): a wave is every task whose dependencies are in earlier waves (table in `tasks.md`). Its tasks run in parallel, each with its own subagent, branch, worktree and `plan.md`. Stop for review after each wave.
5. **Test:** use TDD. For a bug, first commit a test that fails for the expected reason, then fix the code, never the test. After at most 3 attempts, escalate.
6. **Deploy:** work on a branch and never push to `main`. The PR is the gate: the owner reviews and merges, and approves each release to the live domain.
7. **Maintain:** anything found becomes the next cycle's `intent.md`.

Terms: a **requirement** is one `intent.md` and everything derived from it. A **task** is one unit split from it, with its own plan and tests. A **ticket** is only a Jira issue, created when a task fails.

**Agent rungs:** every subagent runs on ultron's rung ladder, from R0 (Haiku, medium effort) to R6 (Fable, high effort), and climbs one rung per counted failure. See `C:\git\friday\sdlc\rungs.md`; copy it to `sdlc/rungs.md` at V0 start. Pass `model` and `effort` on every Agent call and state the rung.

**The main session only talks with the owner.** All stage work (research, spec, tasks, plans, code, tests, reviews) is done by subagents on the rung ladder.

**Any UI work:** use the `design-taste-frontend` skill (installed user-wide) and its browser checks. Check the result at desktop and mobile widths. Record the options considered, the pick and why in `plan.md`.

When Claude makes the same mistake twice, add the correction under "Things Claude gets wrong". Keep this file to about a page.

## Verifying your work
Run build, lint and test before reporting anything done, and paste the result lines. Never skip, weaken or delete a failing test.

## Jira
Only escalations reach Jira; dev work is never planned there. Site `adhyasworkspace-45421657.atlassian.net`, project **ESC** "Dev Escalations" (kanban, board 36, no sprints).
- File a failed or rejected task as a Story, Feature or Bug under the epic named exactly `personal-website V<N>`, matching `sdlc/v<N>`. Look the epic up at the version's first escalation, and create it if it's missing. Never rename it.
- Statuses: Backlog → Selected for development → In Progress → Done. The In Progress limit is 1, and a project has at most 3 open escalations.
- Put the Jira key next to its task in `tasks.md`, and attach each attempt's rung and logs.

## Talking to the owner
Keep replies within 280 characters unless more is needed. Explain terms for a new grad. Lead with the answer and end with the next action.

## Things Claude gets wrong
- PowerShell 5.1 breaks quoted arguments to git. Write the commit message to a file and use `git commit -F <file>`.
- The owner's user folder has spaces (`C:\Users\Anil Kumar ML`). Tools that break on that need a work directory without spaces.
