# tasks.md: personal-website V0
Author: Claude (R2 tasks subagent, Sonnet 5.5 high), for adhyaanilkumar. Cycle: V0. Date: 2026-11-24.
Source: `sdlc/v0/spec.md` (approved by the owner 2026-11-24; D8 look and feel is resolved by T6). Status: **Approved by owner, 2026-11-24.**

**Decisions (owner answers to the ambiguities found while splitting the spec, 2026-11-24)**
1. **`.mcp.json`:** remove it from git and gitignore it, like Social Grid. T2 keeps its untrack step and commits `.mcp.example.json`.
2. **Later Lambda code updates:** the plans of T12 and T17 decide and propose an option (for example a narrowly scoped second role or a manual step) for the owner to review. The OIDC role stays limited to S3 and CloudFront until the owner approves an option.
3. **Turnstile:** an agent creates the free widget through the Cloudflare MCP, after the owner's OK on that task's `plan.md` (T16). The public site key and the contact URL go in committed build config (public values). The secret key is stored only in AWS (the Lambda configuration), never in a file, log, CI variable or report.
4. **Design gate:** `design-taste-frontend`'s `gate.mjs` and `perf.mjs` run **locally before each PR** (output pasted in the PR). CI runs lint, test and build only (plus the resume PDF, privacy scan and screenshots) and does not run the gate.

**Summary**
- **Tasks:** 21 (T1 to T21). Types: Feature 15, Story 6, Bug 0.
- **Starting rungs:** R1 x3, R2 x8, R3 x10. Every R3 comes from a total of 7 or more or from "Risk 2 forces at least R3" (personal data, third-party faces, contact form, AWS or Cloudflare writes, DNS).
- **Order:** tooling and MCP setup, then the non-visual pipeline (privacy scan, resume data, PDF), then the design pass (owner picks), then UI tasks, then the form, CI, infra, deploy, and last the live cutover.
- **Critical path:** T1 > T3 > T4 > T9 > T10 > T11 > T14 > T17 > T20 > T21. T6 (design pass) needs the owner's pick before T8. T12, T15 and T7 can run in parallel with the UI tasks.
- **Stops for the owner (not just review):** T6 (pick a look), T7 (approve the photo preview), T9 (approve the fact sheet and intro copy), T16 (cost and plan approval before any AWS or Cloudflare write), T21 (approve the live `www` cutover).

## Waves (owner, 2026-11-24)
Build runs one wave at a time; a wave's tasks run in parallel, each on its own branch and worktree. The owner reviews after each wave.

| Wave | Tasks |
|---|---|
| 1 | T1 |
| 2 | T2, T3, T7, T12 |
| 3 | T4, T6, T15 |
| 4 | T5, T8, T16 |
| 5 | T9, T10, T13, T18 |
| 6 | T11 |
| 7 | T14 |
| 8 | T17, T19, T20 |
| 9 | T21 |

## Conventions used below
- **AC0 (every task):** `make build`, `make lint` and `make test` run and their result lines are pasted into the task report. Until T1 lands, T1's own AC0 is the stack's first run. Not repeated per task.
- **One task at a time.** Each task starts in plan mode and commits `sdlc/v0/tasks/T<n>/plan.md` (files that change, order of work, risks, proof, MCPs used) before any code, then stops for review after the work (CLAUDE.md, Build). Work on a branch; never push to `main`.
- **TDD:** the test comes first. For a bug, a failing test is committed before the fix. At most 3 attempts, then escalate (Jira ESC, epic `personal-website V0`; put the key next to the task).
- **verify_with** names how a criterion is proven, as `method` and detail. Methods: `vitest` (unit tests), `playwright` (the Playwright test runner on real Chromium, projects 1440x900 and 390x844), `screenshot-browser` (the Playwright MCP opens the built site at 1440x900 and 390x844 and takes screenshots to look at), `gate` (the `design-taste-frontend` `gate.mjs` on `dist` until `GATE: PASS`, widths 1440, 1024, 820, 768, 390; **run locally before the PR and its output pasted in the PR, not in CI**, owner decision 4), `command` (exit code or an exact output line), `owner` (only the owner can check it).
- **A visual criterion never relies on a unit test alone:** it carries `playwright` and/or `screenshot-browser` plus `gate`, desktop and mobile.
- **Hard rules in every task (CLAUDE.md and spec D3, D15):** no phone number anywhere; the owner's email only in `resume/adhya_resume.tex` and `sdlc/v0/intent.md`; no email on the site, in scripts or in the PDF; facts only from the resume; the original photo is never committed; no secret in any committed file; nothing paid and no deploy or DNS change without the owner's approval.
- **MCP permission (D23, standing):** subagents may use Playwright, 21st.dev, AWS, Cloudflare and Atlassian MCPs without asking per call. Guards: no paid resource without its INR cost and the owner's approval; no live deploy or live DNS change without approval; Gmail drafts only (no task here uses Gmail). Pass this in every subagent prompt. 21st.dev queries stay generic, never resume text.
- **Rubric** (`sdlc/rungs.md`): Files (0: 1 to 2, 1: 3 to 5, 2: 6+), Change type (0 new, 1 edits existing, 2 cross-module refactor), Risk (0 none, 1 moderate, 2 security, personal data, auth, public or hard to undo), Ambiguity, Algorithmic difficulty, Test surface (0 to 2 each). Total 0 to 2 R0, 3 to 4 R1, 5 to 6 R2, 7 to 8 R3, 9+ R4. Any Risk 2 forces at least R3. `plan.md` may propose another rung with a reason for the owner to approve. A testing agent never runs below R1.
- **Test names** are suggestions; the plan may rename them, but each criterion must stay checkable.
- **Fresh clone note:** `sdlc/rungs.md` is already in the repo (copied at V0 start); no task needs to copy it.

---

### T1 · Stack and tooling setup
- type: Story
- depends_on: none
- ships_independently: yes. It adds a working empty Astro site and the commands; nothing public changes.
- jira:
- rung: R2 (total 5)
- scores:
  - Files 2: `package.json`, lockfile, `astro.config`, `tsconfig`, `tailwind` config, `components.json`, ESLint, Prettier, Vitest and Playwright configs, `Makefile`, `.github/workflows/ci.yml`, `.nvmrc`, `.gitignore`, `CLAUDE.md`.
  - Change 0: new project files; only `CLAUDE.md` and `.gitignore` are edited.
  - Risk 1: CI and dependency choices are hard to untangle later, but no data or secret is involved.
  - Ambiguity 1: the spec names the stack (D12) and Makefile targets; the exact lint rules and versions are left to the plan.
  - Algorithmic difficulty 0: setup only.
  - Test surface 1: one placeholder unit test, one placeholder browser test, a CI run.
- mcp: playwright (check the empty page at both widths); none else.

Sets up spec D12 and section 6.1: Astro (static output), TypeScript strict, React integration, Tailwind CSS, a shadcn-style `components.json`, Node 22 with npm, ESLint and Prettier, `astro check`, Vitest, the Playwright test runner, and Makefile wrappers `make build`, `make lint`, `make test`, `make preview` (`make resume` arrives in T5). A first workflow `ci.yml`, job named `ci`, runs lint, test and build on pull requests; pinned action versions, lockfile committed (NFR7). Adds the real commands to CLAUDE.md in place of "Add build, lint and test commands here".

**Acceptance criteria**
- AC1: `make build` produces `dist/` from a placeholder page; `make lint` and `make test` pass with at least one unit test and one browser test each.
  - verify_with: `command` - `make build`, `make lint`, `make test` exit 0 and the result lines are pasted
- AC2: The placeholder page renders in real Chromium at 1440x900 and 390x844 with no console errors and no horizontal scroll.
  - verify_with: `playwright` - `smoke.spec.ts` on both projects · `screenshot-browser` - both widths
- AC3: CLAUDE.md lists the build, lint, test, preview commands and the Node version; `.gitignore` still covers `node_modules`, `dist`, `private/`, `assets/photo.jpeg` and `.taste-skill/chrome-*`.
  - verify_with: `command` - `git diff` of `CLAUDE.md` and `.gitignore` reviewed; `git check-ignore -v assets/photo.jpeg private/x` prints a match for both
- AC4: A pull request runs the `ci` job (lint, test, build) and it goes green; versions of every action are pinned and `package-lock.json` is committed.
  - verify_with: `command` - `gh run list` shows `ci` success on the task's PR; `grep -E "uses: .*@(main|master|v[0-9]+$)"` flags any unpinned action
- AC5: `components.json` exists so the 21st plugin's skills activate, and Tailwind is configured so T6 can map the chosen look's tokens onto it (no design values hard-coded yet).
  - verify_with: `command` - file present and `npx tailwindcss --help` resolves; `owner` - reviews the config choices in the PR

---

### T2 · MCP setup (AWS, Cloudflare, 21st.dev) in this repo
- type: Story
- depends_on: T1
- ships_independently: yes. Tooling only.
- jira:
- rung: R1 (total 3)
- scores:
  - Files 1: `.mcp.example.json`, `.gitignore`, `CLAUDE.md` (the AWS and Cloudflare entries live in `~/.claude.json`, outside the repo).
  - Change 0: new config.
  - Risk 1: a secret must never reach a committed file; no write access is granted by this task.
  - Ambiguity 1: see the `.mcp.json` note below.
  - Algorithmic difficulty 0.
  - Test surface 0: a few read-only calls and a grep.
- mcp: aws-mcp, cloudflare, 21st (each one read-only call to prove it is connected).

Implements D31 and spec section 12's MCP setup task. **Found while writing these tasks:** a `.mcp.json` is already present and is **tracked by git** (not ignored). It holds the `${API_KEY_21ST}` placeholder only (checked by counting the placeholder, not by reading any key), so nothing secret is out yet. D27 says it should be gitignored like Social Grid's. Owner decision 1 (2026-11-24): untrack it with `git rm --cached`, gitignore it like Social Grid, and commit `.mcp.example.json`.

**Acceptance criteria**
- AC1: `.mcp.json` is untracked and gitignored; `.mcp.example.json` is committed with `"x-api-key": "${API_KEY_21ST}"` and no real key; no tracked file contains an `x-api-key` value that is not a `${...}` placeholder.
  - verify_with: `command` - `git ls-files .mcp.json` prints nothing; `git check-ignore -v .mcp.json` matches; `git grep -n "x-api-key"` shows only the placeholder
- AC2: The `aws-mcp` (`https://aws-mcp.ap-southeast-1.api.aws/mcp`) and `cloudflare` (`https://mcp.cloudflare.com/mcp`) servers are available in this folder (local scope, OAuth, no key in a repo file), and `/mcp` shows both and `21st` connected.
  - verify_with: `command` - `claude mcp list` shows all three connected; `owner` - signs in to AWS and Cloudflare (OAuth) if prompted
- AC3: One read-only call per server works: AWS `ListBuckets` (or `list_regions`), Cloudflare `whoami`, 21st `search` with a generic query ("timeline component"). No write is attempted.
  - verify_with: `command` - the three call results pasted in the task report (account ids and token values redacted)
- AC4: The owner checks the Cloudflare token's scope (only the `adhyaanilkumar.com` zone's DNS and Web Analytics) and that `API_KEY_21ST` is set in the Windows user environment.
  - verify_with: `owner` - confirms both in the PR, or states the scope found so T16 can plan around it
- AC5: CLAUDE.md gets one line pointing to the MCP setup; no secret appears in any committed file or in the task report.
  - verify_with: `command` - `git grep -nE "(sk|key|token)[-_a-z]*[\"': =]+[A-Za-z0-9]{20,}"` finds nothing

---

### T3 · Privacy scan (phone and email rules, API-key rule)
- type: Feature
- depends_on: T1
- ships_independently: yes. It runs as a command; T14 wires it into CI.
- jira:
- rung: R3 (total 6, forced to R3 by Risk 2)
- scores:
  - Files 1: scan script, its config, its tests, a Makefile target.
  - Change 0: new.
  - Risk 2: it is the fail-closed guard against publishing a phone number or the owner's email; a miss is a public, hard-to-undo leak.
  - Ambiguity 1: phone patterns for Indian and international forms need choosing; the rule set itself is in spec section 5, item 4.
  - Algorithmic difficulty 1: regexes, binary-safe file walking, PDF text input.
  - Test surface 1: planted-value fixtures for each rule.
- mcp: none.

`scripts/privacy-scan.mjs` and `make scan`. Spec section 5 item 4: **phone rule** (any phone-number pattern in any tracked file, `dist/`, `resume.json` or PDF text fails, including in the two allowed files); **email rule** (any email address in `dist/`, `resume.json`, PDF text or any tracked file other than `resume/adhya_resume.tex` and `sdlc/v0/intent.md` fails); **key rule** (any `x-api-key` value that is not a `${...}` placeholder fails). The two allowed files are named by path in the scan's config, and the owner's address is **not** copied into the scan, its config or its tests (the tests use fake addresses).

**Acceptance criteria**
- AC1: A planted fake phone number (10 digits, `+91` form, spaced and dashed forms) in a tracked file, in a built page, in `resume.json` and in PDF text each make the scan exit non-zero and name the file; the same plant inside an allowed file also fails.
  - verify_with: `vitest` - `privacy-scan.phone.test.ts` with fixtures in a temp directory
- AC2: A fake email in any file other than the two allowed ones, in a built page and in PDF text fails; the same fake email inside `resume/adhya_resume.tex` or `sdlc/v0/intent.md` passes the email rule.
  - verify_with: `vitest` - `privacy-scan.email.test.ts`
- AC3: A literal `x-api-key` value fails; `"${API_KEY_21ST}"` passes.
  - verify_with: `vitest` - `privacy-scan.key.test.ts`
- AC4: The scan fails closed: an unreadable file, a missing `dist/` when `--dist` is asked for, a missing PDF when `--pdf` is asked for, or a config that lists no allowed files makes it exit non-zero, never silently pass.
  - verify_with: `vitest` - `privacy-scan.failclosed.test.ts`
- AC5: Run on the repo as it stands today, the scan passes; the owner's real address does not appear in the scan's source, config, tests or output (output masks matches).
  - verify_with: `command` - `make scan` exit 0; `git grep -n` for the address's domain part finds it only in the two allowed files
- AC6: The scan takes PDF text from `pdftotext` (or equivalent in the pinned container) and has a `--text-file` mode so tests need no PDF tool.
  - verify_with: `vitest` - text-file mode tests; real PDF covered in T5

---

### T4 · Resume sanitiser, parser and `resume-sync`
- type: Feature
- depends_on: T1, T3
- ships_independently: yes. It produces `resume.json`; no page uses it yet.
- jira:
- rung: R3 (total 6, forced to R3 by Risk 2)
- scores:
  - Files 1: sanitiser, parser, `resume-sync`, fixtures, tests.
  - Change 0: new.
  - Risk 2: it is the step that removes the owner's email before anything is built, and its output feeds every page; a bad sanitiser leaks the email.
  - Ambiguity 1: the macro list is known (spec section 5) but must be checked against the real `.tex`.
  - Algorithmic difficulty 1: a small LaTeX macro parser with fail-closed errors.
  - Test surface 1: the real resume as a fixture, broken variants, a changed heading.
- mcp: none.

Spec section 5 items 1, 2, 5 and D14, D19, D29. Makes the sanitised copy (heading email token and its separator removed by a pattern that matches any `\texttt{...@...}` heading entry, the address never written into a script), fails if the pattern matches nothing or any `@` is left, then parses `\resumeSubheading`, `\resumeItem`, `\resumeProjectHeading` and the Skills lines into `resume.json` (`\href`, `\textbf`, `\emph`, `--`, `\&`, `\_` turned into text). Unknown macros or unreadable sections fail the build. `make resume-sync SRC=<path>` copies a new `.tex` into `resume/`, checks it parses and fails on a phone number (using T3's phone rule). `resume.json` also carries the last-commit date of the `.tex` for "Resume updated <date>".

**Acceptance criteria**
- AC1: Run on the real `resume/adhya_resume.tex`, the parser outputs the three dated entries (VIT 2022 to 2026, BluBridge May to Jul 2026, Apple | Adecco Sep 2026 to present, newest first), the five skill groups as written and the three projects (Ultron, Social Grid, Sentinel-RAG) each with a stack line, three bullets and links, matching the `.tex` text.
  - verify_with: `vitest` - `parse-resume.test.ts` with the real file as fixture, asserting entry count, order and bullet text
- AC2: The sanitised copy contains no `@`; `resume.json` contains no email and no phone.
  - verify_with: `vitest` - `sanitise.test.ts` · `command` - `make scan --dist --json resume.json` passes (T3)
- AC3: A `.tex` whose heading has no email token, or whose heading email is in a form the pattern misses, fails the build with a clear message (never passes with the address left in).
  - verify_with: `vitest` - `sanitise.failclosed.test.ts` with two broken fixtures that use a fake address
- AC4: A `.tex` with an unknown macro or an unreadable section fails; the error names the macro and line.
  - verify_with: `vitest` - `parse-resume.broken.test.ts` (FR9)
- AC5: Project pages' Ultron link is the resume's `tree/v0-design` link and Sentinel-RAG keeps the exact result line "GraphRAG beat traditional RAG on 2 of 8 evaluation metrics: Faithfulness and Context Recall".
  - verify_with: `vitest` - assertions on `resume.json` strings
- AC6: `make resume-sync SRC=<file>` copies the file, runs the parse check and the phone rule; a source with a phone number is refused and `resume/` is left unchanged.
  - verify_with: `vitest` - `resume-sync.test.ts` using a temp directory and a fake phone
- AC7: `resume.json` records the date of the `.tex`'s last commit (git log), used later for "Resume updated".
  - verify_with: `vitest` - date field is an ISO date and matches `git log -1 --format=%cs -- resume/adhya_resume.tex`

---

### T5 · Resume PDF build in a pinned TeX Live container
- type: Feature
- depends_on: T4
- ships_independently: yes. Produces `adhya-anil-kumar-resume.pdf` locally; the site does not link it yet.
- jira:
- rung: R3 (total 6, forced to R3 by Risk 2)
- scores:
  - Files 1: Dockerfile or container invocation, `make resume`, a script, tests.
  - Change 0: new.
  - Risk 2: the PDF is a public file built from personal data; it must carry no email, phone or author metadata.
  - Ambiguity 1: the exact TeX Live tag is chosen in the task and must include FiraMono and tgheros.
  - Algorithmic difficulty 1: pdflatex in a container, Windows path handling (user folder has spaces; use a work directory without them).
  - Test surface 1: a compile test, metadata and text checks.
- mcp: none (Docker locally).

Spec section 5 item 3 and D14, R8. `make resume` compiles the **sanitised** copy with pdflatex in a pinned TeX Live image, the same container locally and in CI, and writes the PDF to `dist/` (built, not committed). PDF has no author or contact metadata.

**Acceptance criteria**
- AC1: `make resume` builds the PDF from the real resume with the pinned image tag recorded in the Makefile; the tag includes FiraMono and tgheros and the build exits 0.
  - verify_with: `command` - `make resume` exit 0, `pdffonts` or `pdfinfo` output pasted
- AC2: `pdftotext` of the PDF contains the resume's key lines (name, "Apple | Adecco", a project title) and no `@` and no phone-number pattern.
  - verify_with: `command` - `pdftotext` run in the container piped to `make scan --pdf` (T3), exit 0 · `vitest` - `resume-pdf.test.ts` compares key lines to `resume.json`
- AC3: PDF metadata has no author, no email and no creator path (`pdfinfo` shows empty or generic Author, no local paths).
  - verify_with: `command` - `pdfinfo` output pasted and checked by a test
- AC4: Building a deliberately broken `.tex` fails `make resume` with a non-zero exit (no stale PDF is left in `dist/`).
  - verify_with: `vitest` - `resume-pdf.failure.test.ts` using a temp broken file
- AC5: The build works from a path with no spaces and the plan records the Windows workaround (the owner's user folder has spaces).
  - verify_with: `command` - run from `C:\git\personal-website`; the plan notes any `docker` volume-path handling

---

### T6 · Design pass (look and feel options and owner's pick)
- type: Story
- depends_on: T1, T2
- ships_independently: yes. It adds a decision record and option mock-ups; the site is unchanged.
- jira:
- rung: R2 (total 5)
- scores:
  - Files 1: `sdlc/v0/tasks/T6/plan.md`, the options write-up, option mock-ups (static HTML under a non-published folder), Tailwind token mapping.
  - Change 0: new.
  - Risk 0: no data or infra.
  - Ambiguity 2: taste is subjective; the owner's pick is the acceptance criterion.
  - Algorithmic difficulty 1: mapping the skill's tokens onto Tailwind (spec R9).
  - Test surface 1: gate and screenshot checks per option.
- mcp: playwright (screenshots of each option at 1440x900 and 390x844), 21st (generic inspiration queries only), `design-taste-frontend` skill (not an MCP).

Resolves D8 and spec section 14's one open item. Uses the `design-taste-frontend` skill with the site kind **software** (D21): proposes **2 to 3 distinct looks** for the main page's hero and one other section, with palette, type, hero treatment and the one dealt moment for each. Uses only resume facts for copy and **no stock photos or live photo search** (spec 6.3 override); the owner's photo may appear as a placeholder block. The owner picks. The pick and the reasons are recorded in `plan.md` and in a decision line with the date. Then maps the chosen look's CSS tokens onto the Tailwind config.

**Acceptance criteria**
- AC1: 2 or 3 options exist as browsable mock-ups (not published; kept out of `public/` and `dist/`), each with palette, type, hero and moment described in a few lines, and each seen at 1440x900 and 390x844.
  - verify_with: `screenshot-browser` - screenshots of each option at both widths attached to the PR · `gate` - each mock-up passes `gate.mjs` or its waivers are listed
- AC2: The owner picks one option; the choice, the options considered and why are recorded in `plan.md` with the date, and the decision table in `spec.md` D8 gets a line pointing to it.
  - verify_with: `owner` - states the pick in the PR; `command` - `grep -n "D8" sdlc/v0/spec.md` shows the new reference
- AC3: The chosen look's tokens (colours, type scale, spacing, radii) are defined once and mapped into the Tailwind config, so there is one visual system (spec R9); no component hard-codes a colour.
  - verify_with: `command` - `make build` passes; `grep` for raw hex colours in components finds none outside the token file · `vitest` - token file test (the Tailwind config exposes each token)
- AC4: No stand-in photograph, stock image or invented imagery is used in any option; any copy used is traceable to a resume line.
  - verify_with: `owner` - reviews the options; `command` - no image file other than the owner's placeholder is added
- AC5: Fonts chosen are self-hostable (NFR4), with their licences noted in the plan.
  - verify_with: `command` - licence line per font in `plan.md`; no Google Fonts or CDN URL in the mock-ups' source

---

### T7 · Photo processing script and outputs
- type: Feature
- depends_on: T1
- ships_independently: yes. Produces committed web images; no page shows them yet.
- jira:
- rung: R3 (total 6, forced to R3 by Risk 2)
- scores:
  - Files 1: `scripts/process-photo.mjs`, tests, outputs under `public/images/`.
  - Change 0: new.
  - Risk 2: the source shows many other people; publishing the wrong crop is a hard-to-undo privacy failure.
  - Ambiguity 1: crop box is estimated (about x 630 to 2920, y 530 to 3390) and confirmed on the real image; the owner approves the preview.
  - Algorithmic difficulty 1: sharp pipeline, EXIF orientation 2 handling.
  - Test surface 1: size budgets, metadata test, preview.
- mcp: playwright (view the processed image in a real browser at both widths); none else.

Spec section 8 and D4, D16. The original `assets/photo.jpeg` is never committed, moved, modified or published (it is already in `.gitignore`; the script reads it from `private/` or `assets/`). The script auto-orients, crops tight to head and shoulders (4:5), resizes to 640x800 and 1280x1600 (never upscaling), and writes AVIF (about q55), WebP (about q78) and mozjpeg JPEG (about q80), stripping all metadata. No background removal; a sliver of a neighbour may stay (owner accepts).

**Acceptance criteria**
- AC1: Running the script on the real photo writes the 3 formats at 2 sizes into `public/images/`; the 640 file is under 100 KB and the 1280 file under 350 KB (each format checked, or the smaller of the three per size if the plan records why).
  - verify_with: `vitest` - `process-photo.test.ts` asserts dimensions and byte budgets
- AC2: No EXIF, GPS, camera or date metadata remains in any output.
  - verify_with: `vitest` - `photo-metadata.test.ts` reads each output with sharp and asserts empty metadata
- AC3: The crop is tight head and shoulders (cap top to upper chest, centred on the face), not cutting the owner's cap or shoulders, and left-right orientation is correct after the EXIF fix.
  - verify_with: `screenshot-browser` - the 1280 output opened in the browser; `owner` - approves the preview image before the PR can merge (D4, section 8)
- AC4: The original is not in the commit: `git status` and the PR diff list only the script, tests and `public/images/*` outputs; the tests run from a small synthetic fixture so they pass on a fresh clone that lacks the original.
  - verify_with: `command` - `git diff --stat main` lists no `assets/` or `private/` path; `git check-ignore -v assets/photo.jpeg` matches · `vitest` - tests skip nothing when the original is missing (they use a generated fixture)
- AC5: The script is repeatable: running it twice gives byte-identical outputs.
  - verify_with: `command` - sha256 of the outputs from two runs match
- AC6: The original file is untouched (hash before and after the run is the same).
  - verify_with: `command` - sha256 of `assets/photo.jpeg` before and after, pasted

---

### T8 · Site shell: layout, tokens, 404, robots, sitemap, meta
- type: Feature
- depends_on: T1, T6
- ships_independently: yes. A themed empty shell with a 404 page; nothing personal is on it.
- jira:
- rung: R2 (total 5)
- scores:
  - Files 2: base layout, header, footer, global styles, fonts, `404.astro`, `robots.txt`, `sitemap`, head component.
  - Change 0: new (replaces the T1 placeholder).
  - Risk 0: no data.
  - Ambiguity 2: applies the owner's chosen look; the gate decides when it is done.
  - Algorithmic difficulty 0.
  - Test surface 1: gate, browser checks, a few unit tests for the head tags.
- mcp: playwright, 21st (generic queries for header or footer patterns, only if useful), `design-taste-frontend` skill.

Builds the shared pieces the picked look needs: base layout with `lang="en"`, canonical URL `https://www.adhyaanilkumar.com` (D22), self-hosted fonts, global styles from the T6 tokens, `prefers-reduced-motion` handling, skip link and visible focus, a 404 page, `robots.txt`, `sitemap.xml` generated from the routes, and Open Graph tags (the share image is added in T9 once the photo is used). The footer carries the cookie-free analytics line (spec section 7) but no email and no phone.

**Acceptance criteria**
- AC1: `dist/` has `404.html`, `robots.txt` and `sitemap.xml`; the sitemap lists only real routes under `https://www.adhyaanilkumar.com`.
  - verify_with: `vitest` - `sitemap.test.ts` on the built output
- AC2: Every page has `lang="en"`, a title, a description and a canonical link to the `www` URL.
  - verify_with: `vitest` - `head.test.ts` on built HTML
- AC3: The shell renders in the chosen look at 1440x900 and 390x844 with no console errors, no horizontal scroll (also at 320 px) and a visible keyboard focus state.
  - verify_with: `playwright` - `shell.spec.ts` (both projects, plus a 320 px viewport) · `screenshot-browser` - both widths · `gate` - `GATE: PASS` at the five widths
- AC4: With `prefers-reduced-motion: reduce` set, no transitions or animations run on the shell.
  - verify_with: `playwright` - emulated media check on computed styles
- AC5: Fonts load from the site's own origin; the network log shows no third-party request.
  - verify_with: `playwright` - network log asserts only same-origin requests
- AC6: Text contrast is at least WCAG AA on the shell.
  - verify_with: `playwright` - an axe-core check in the browser test · `screenshot-browser` - looked at in both widths

---

### T9 · Main page: hero, resume download and fact sheet
- type: Feature
- depends_on: T4, T5, T7, T8
- ships_independently: yes. It is a complete first screen of the main page; later sections are added by T10, T11 and T13.
- jira:
- rung: R2 (total 6)
- scores:
  - Files 1: hero component, resume download card, page, fact sheet, tests.
  - Change 1: edits the shell and the page.
  - Risk 1: the first public copy; every sentence must trace to a resume line.
  - Ambiguity 2: the intro copy is judged by the owner.
  - Algorithmic difficulty 0.
  - Test surface 1: browser checks, link checks, a download test.
- mcp: playwright (download and layout checks), 21st (generic queries for a download-card component), `design-taste-frontend` skill.

Spec section 3 item 1 and 5.6 (download component), D10, D28, D30. Hero: name, a one-line intro built only from resume facts (role, city, degree, what is built), the head-and-shoulders photo (`<picture>` with width and height, `fetchpriority="high"`, no lazy loading, alt "Adhya Anil Kumar"), GitHub and LinkedIn links only, **Download resume** and **Contact** buttons, and "Bengaluru, India". Writes `sdlc/v0/tasks/T9/fact-sheet.md`, a table of each site sentence to its resume line, for the owner to review. Adds the Open Graph share image from the processed photo. The download button shows the file name and size, links to `/adhya-anil-kumar-resume.pdf` with the `download` attribute, and the section shows "Resume updated <date>" from `resume.json`.

**Acceptance criteria**
- AC1: The hero shows the name, intro line, photo, "Bengaluru, India", a GitHub link, a LinkedIn link, a Download resume button and a Contact button, and nothing else personal (no email, no phone, no other social link).
  - verify_with: `playwright` - `hero.spec.ts` finds each element at both widths and asserts the link hrefs match the resume's · `screenshot-browser` - both widths · `gate` - `GATE: PASS`
- AC2: The fact sheet maps every sentence on the page to a resume line, and the owner approves it and the intro copy.
  - verify_with: `owner` - approves `fact-sheet.md` in the PR · `vitest` - every fact-sheet row's resume quote exists in `resume.json`
- AC3: The Download resume button downloads a PDF whose text matches key lines of the `.tex`; the button shows the file name and size and the "Resume updated" date equals the `.tex`'s last commit date.
  - verify_with: `playwright` - download test reads the file and compares text; date matches `resume.json` (FR4)
- AC4: The photo is served as `<picture>` with AVIF, WebP and JPEG sources, explicit dimensions, no lazy loading, correct alt text; the hero image LCP file is under the budget (640 file under 100 KB).
  - verify_with: `playwright` - asserts the markup and file sizes · `screenshot-browser` - both widths
- AC5: The page has no email and no phone in its HTML, scripts or network traffic.
  - verify_with: `command` - `make scan --dist` passes · `playwright` - network log and page source scanned for the email and phone patterns (FR7)
- AC6: The page works with the keyboard (tab order, visible focus) and the buttons and links are labelled.
  - verify_with: `playwright` - keyboard test and an axe-core check
- AC7: The Open Graph image and tags are present and point to the `www` URL.
  - verify_with: `vitest` - `og.test.ts` on built HTML

---

### T10 · Main page: timeline and skills sections
- type: Feature
- depends_on: T4, T8
- ships_independently: yes (page sections that read only `resume.json`); T9 sets the first screen.
- jira:
- rung: R2 (total 5)
- scores:
  - Files 1: timeline component, skills component, page edit, tests (3 to 5 files).
  - Change 1: edits the main page.
  - Risk 0: data comes from `resume.json`.
  - Ambiguity 2: "one section per screen" and the timeline fitting one or two screens need judgment.
  - Algorithmic difficulty 0.
  - Test surface 1: text comparison and the gate at five widths.
- mcp: 21st (generic queries for timeline patterns; the owner's plan covers code retrieval, D27), playwright, `design-taste-frontend` skill.

Spec section 3 items 2 and 3, D19. The timeline has exactly the three dated resume entries, newest first, each with org, role, dates, place and its bullets; projects stay off the timeline. Skills show the five groups as written. Both read only `resume.json`.

**Acceptance criteria**
- AC1: The timeline lists exactly three entries, newest first (Apple | Adecco, BluBridge, VIT), each with org, role, dates, place and the resume's bullets, and no project appears in it.
  - verify_with: `vitest` - `timeline.test.ts` on `resume.json` · `playwright` - reads the rendered text and compares it to `resume.json` (FR2)
- AC2: Skills show the five groups with the resume's labels and items.
  - verify_with: `playwright` - rendered text equals `resume.json`
- AC3: At 1440x900 and 390x844 each section fits the design skill's one-section-per-screen rule (the timeline fits one or two screens), equal left and right edges, no horizontal scroll, readable text and visible focus.
  - verify_with: `screenshot-browser` - both widths, each section · `gate` - `GATE: PASS` at the five widths
- AC4: Copy-lint passes (no copy not in the resume; the page adds no invented text beyond headings).
  - verify_with: `gate` - copy-lint step · `vitest` - every body string equals a resume string or a heading in the fact sheet
- AC5: Bullets with links (`\href`) render as real links with `rel="noopener"` where external.
  - verify_with: `playwright` - link attributes asserted
- AC6: Fact sheet from T9 is extended for these sections and the owner approves it.
  - verify_with: `owner` - approves the extension in the PR

---

### T11 · Project cards and the three project pages
- type: Feature
- depends_on: T4, T8, T10
- ships_independently: yes. Adds a section and three pages.
- jira:
- rung: R1 (total 4)
- scores:
  - Files 1: card component, project page template, three generated routes, tests.
  - Change 0: new pages plus one section added to the main page.
  - Risk 0: resume data only.
  - Ambiguity 1: short pages must look intentional (spec R10).
  - Algorithmic difficulty 0: generated from `resume.json`.
  - Test surface 2: three pages, links, two widths, gate.
- mcp: playwright, 21st (generic card queries if needed), `design-taste-frontend` skill.

Spec section 3 items 4 and the project pages, D2, D20. Main page shows three project cards linking to `/projects/ultron/`, `/projects/social-grid/`, `/projects/sentinel-rag/`. Each page: title, stack line, the three resume bullets, a GitHub link, (Social Grid only) the live link to social-grid.dev, and a back link. No invented imagery; no content beyond the resume.

**Acceptance criteria**
- AC1: Each project page shows title, stack line, exactly three bullets from `resume.json`, a GitHub link (Ultron's is the `tree/v0-design` link) and a back link; Social Grid also has the live link to social-grid.dev.
  - verify_with: `playwright` - `projects.spec.ts` visits all three and compares text and hrefs to the resume (FR3) · `vitest` - generation test on `resume.json`
- AC2: The main page's project cards link to the three pages, and each card's target loads (no 404).
  - verify_with: `playwright` - clicks each card at both widths
- AC3: Sentinel-RAG's result line is exactly "GraphRAG beat traditional RAG on 2 of 8 evaluation metrics: Faithfulness and Context Recall".
  - verify_with: `playwright` - exact string match on the page
- AC4: Each page and the cards look intentional at 1440x900 and 390x844 (not empty), with no image invented or sourced from stock.
  - verify_with: `screenshot-browser` - 3 pages and the cards at both widths, looked at · `gate` - `GATE: PASS` on each page · `owner` - approves the look in the PR
- AC5: `/projects/<name>/` resolves locally and in the built output (the CloudFront Function in T15 is added later for the live site).
  - verify_with: `playwright` - the preview server serves each trailing-slash URL; `dist/projects/<name>/index.html` exists (`command`)
- AC6: Sitemap lists the three pages; every external link has `rel="noopener"`; no console errors on any page.
  - verify_with: `vitest` - sitemap test · `playwright` - console and link attribute checks

---

### T12 · Contact form backend: Lambda handler with SES and Turnstile check
- type: Feature
- depends_on: T1
- ships_independently: no. It has no caller until T13 and no AWS resource until T16; it is built and tested locally.
- jira:
- rung: R3 (total 7)
- scores:
  - Files 1: handler, validation, Turnstile client, SES client wrapper, tests, a build script (3 to 5 files).
  - Change 0: new.
  - Risk 2: it takes visitor input, sends mail to the owner, checks a secret, and must avoid header injection and abuse.
  - Ambiguity 1: spec section 4.2 is detailed; how the owner's address and secret arrive (Lambda configuration) needs plan detail.
  - Algorithmic difficulty 1: validation and error mapping.
  - Test surface 2: valid, honeypot, bad token, oversize, header injection, SES failure, CORS, logging.
- mcp: none (tests mock SES and `fetch`; no Cloudflare or AWS call; no real mail).

Spec section 4.2, D13. Node 22 TypeScript Lambda behind a Function URL. Fields: name (up to 100), reply-to email (up to 254), message (up to 2,000), a hidden honeypot, Turnstile token. Rejects a filled honeypot, oversize or malformed input; calls Turnstile `siteverify`; strips CR and LF from name and subject; sends one plain-text SES `SendEmail` from `website@adhyaanilkumar.com` to the owner address read from an environment variable, `Reply-To` the visitor; no auto-reply; nothing stored. Responses 200, 400, 429, 502. CORS allows only `https://www.adhyaanilkumar.com`. Logs carry a request id and an outcome code only. `make lambda` builds the deployable zip. The owner's address is never in the repo or its tests. **Later code updates (owner decision 2):** the OIDC role cannot update the Lambda, so `plan.md` proposes how new Lambda zips get deployed after the first create (for example a manual `make lambda` plus an approved console or MCP upload, or a separate narrowly scoped role limited to `lambda:UpdateFunctionCode` on this one function) with the trade-offs, for owner review. Nothing is widened without that approval.

**Acceptance criteria**
- AC1: A valid request makes exactly one SES `SendEmail` call with the right From, To (from the environment), Reply-To (the visitor), a plain-text body and returns 200.
  - verify_with: `vitest` - `handler.valid.test.ts` with a mocked SES client and mocked `fetch`
- AC2: A filled honeypot, a field over its limit, a malformed email, an empty message or a bad Turnstile token each return 400 and send no mail.
  - verify_with: `vitest` - `handler.invalid.test.ts` (one case per rule)
- AC3: A name or subject containing CR or LF cannot inject a header: the sent subject and headers contain no extra line, and the test proves it with a `Bcc:` attempt.
  - verify_with: `vitest` - `handler.injection.test.ts`
- AC4: An SES failure returns 502; a Turnstile `siteverify` outage fails closed (400 or 502, no mail); a throttle returns 429.
  - verify_with: `vitest` - `handler.errors.test.ts`
- AC5: CORS: a preflight and a response from `https://www.adhyaanilkumar.com` get the allow headers; any other origin gets none.
  - verify_with: `vitest` - `handler.cors.test.ts`
- AC6: Logs contain a request id and an outcome code only; a test captures logs and asserts the name, email, message, Turnstile token and owner's address are absent.
  - verify_with: `vitest` - `handler.logging.test.ts` with captured output
- AC7: The owner's address and Turnstile secret are read from environment variables only; no tracked file (source, tests, template, CI) contains either, and `make scan` passes.
  - verify_with: `command` - `make scan` exit 0 · `vitest` - the handler throws a clear configuration error when a variable is missing (fails closed, sends nothing)
- AC8: `make lambda` produces a zip with no dev dependencies, under 5 MB, and the tests never send real mail or call the network.
  - verify_with: `command` - zip size printed · `vitest` - network is blocked (fetch and SES are mocks; an un-mocked call fails the test)

- AC9: `plan.md` states how Lambda code updates are deployed after the first create, lists at least two options with their permissions and cost (INR), and recommends one; the owner reviews it.
  - verify_with: `owner` - reviews the options in the PR; `command` - `grep -n "UpdateFunctionCode" sdlc/v0/tasks/T12/plan.md` finds the discussion
---

### T13 · Contact form UI (React island, Turnstile widget, stub)
- type: Feature
- depends_on: T8, T12
- ships_independently: no. It posts to a URL that does not exist until T16; it works against a local stub, and the real Function URL and site key are filled into the build config after T16 (owner decision 3).
- jira:
- rung: R3 (total 8)
- scores:
  - Files 1: form island, Turnstile loader, local stub server, page section, tests.
  - Change 1: edits the main page; adds a dev stub.
  - Risk 2: visitor personal data, spam surface, third-party script (Turnstile), no email shown.
  - Ambiguity 1: failure message wording and visual states need judgment.
  - Algorithmic difficulty 1: states, validation, token handling.
  - Test surface 2: success, each error, keyboard, two widths.
- mcp: playwright (form flow against the stub), 21st (generic form patterns; owner's plan covers retrieval), `design-taste-frontend` skill. No real send.

Spec sections 3 item 5 and 4.2, D3, D13. React island: name, reply-to email, message, a hidden honeypot, the Turnstile widget (public **site key** only, read from committed build config, a public value; Cloudflare's always-pass **test keys** locally and in CI). Posts JSON to the Function URL (`PUBLIC_CONTACT_URL`, also in build config once T16 has created it; until then a stub URL), shows sending, success, and a clear error, and on failure says "Couldn't send. Message me on LinkedIn instead." with the LinkedIn link. A local stub server stands in for the Lambda in tests.

**Acceptance criteria**
- AC1: The form has labelled fields (name, email, message), a submit button, a hidden honeypot that real users cannot reach by keyboard, and the Turnstile widget.
  - verify_with: `playwright` - `contact.spec.ts` asserts labels, tab order and the honeypot's `tabindex=-1` and hidden state at both widths · `screenshot-browser` - both widths · `gate` - `GATE: PASS`
- AC2: A valid submission against the stub posts the JSON with the Turnstile token and shows a success state; the page never shows or contains any email address.
  - verify_with: `playwright` - stub receives the body; success text visible; network log and page source scanned for email patterns (FR6, FR7)
- AC3: Client-side limits mirror the Lambda's (100, 254, 2,000) and an invalid field shows a clear error message tied to the field.
  - verify_with: `playwright` - invalid input per field · `vitest` - the limit constants equal T12's
- AC4: When the stub returns 400, 429 or 502, or the network fails, the page shows "Couldn't send. Message me on LinkedIn instead." with the LinkedIn link, and the form stays usable.
  - verify_with: `playwright` - one test per stub response
- AC5: The Turnstile site key is the only third-party identifier in the page; scripts load only from `challenges.cloudflare.com`; no third-party request occurs before the form is used except as the plan states.
  - verify_with: `playwright` - network log asserts hosts (NFR4)
- AC6: The form is operable by keyboard, has visible focus, status messages are announced (`aria-live`), and text contrast is at least AA.
  - verify_with: `playwright` - keyboard flow and axe-core check · `screenshot-browser` - error and success states at both widths
- AC7: No real mail is sent by any test and no Turnstile **secret** is in the repo; the committed config holds only the public site key (a test key until T16) and the contact URL.
  - verify_with: `command` - `make scan` exit 0 · `owner` - one real end-to-end send after T21 (recorded in T20's report)

---

### T14 · CI pipeline: PDF, privacy scan, browser checks, screenshots, PR template
- type: Story
- depends_on: T3, T5, T11
- ships_independently: yes. Changes only the pull-request workflow.
- jira:
- rung: R2 (total 6)
- scores:
  - Files 1: `ci.yml`, PR template, a screenshot script, README or CLAUDE note.
  - Change 1: extends T1's workflow.
  - Risk 1: CI runs untrusted PR code with no secrets; keep it that way.
  - Ambiguity 1: how screenshots are attached (artifact versus PR comment).
  - Algorithmic difficulty 1: container steps in Actions.
  - Test surface 1: CI runs on a PR.
- mcp: playwright (the same runner CI uses); none else.

Spec section 2.5 step 1 and R14, D14, D29. The `ci` job gains: build the resume PDF in the pinned container, run `make scan` on tracked files, `dist/` and the PDF, run the Playwright browser checks at 1440x900 and 390x844, and upload screenshots at both widths as a workflow artifact and a PR comment. Adds `.github/pull_request_template.md` with the box "I copied the latest Overleaf version into `resume/` before this PR." The job needs no secrets and nothing deploys. **The design gate is not run in CI** (owner decision 4): it runs locally before each PR, and the PR template gets a box "I ran the design gate locally and pasted `GATE: PASS`."

**Acceptance criteria**
- AC1: A PR run shows these steps passing: lint, test (including the browser checks), build, resume PDF, privacy scan. No `gate.mjs` step exists in any workflow.
  - verify_with: `command` - `gh run view` on the task's PR lists each step green; `grep -rn "gate.mjs" .github/` finds nothing
- AC2: A PR that plants a fake phone number in a tracked file fails the `ci` job at the scan step (proved once with a throwaway branch, then closed).
  - verify_with: `command` - `gh run list` for the throwaway PR shows failure at the scan step; the PR is closed unmerged
- AC3: Screenshots at 1440x900 and 390x844 are attached to the PR run (artifact link and a comment) for every page that exists.
  - verify_with: `command` - `gh run download` lists the screenshot files · `screenshot-browser` - one downloaded image is opened and looked at
- AC4: The PR template contains the resume-copy checkbox and the local design-gate checkbox.
  - verify_with: `command` - `grep -n "latest Overleaf\|design gate" .github/pull_request_template.md` finds both
- AC5: The workflow uses no secrets, pins every action and container tag, and requests only `contents: read` (plus `pull-requests: write` only for the screenshot comment if the plan justifies it).
  - verify_with: `command` - `grep` of `permissions:` and `secrets.`; `owner` - reviews the permissions in the PR

---

### T15 · Infrastructure as code: CloudFormation template and read-only inventory
- type: Feature
- depends_on: T12
- ships_independently: yes. A reviewed template and a read-only inventory report; nothing is created.
- jira:
- rung: R3 (total 7)
- scores:
  - Files 1: `infra/site.yaml`, a CloudFront Function file, a response-headers policy, a lint config, tests, an inventory report.
  - Change 0: new.
  - Risk 2: it defines public hosting, an IAM role trusted by GitHub, SES identities and a public Lambda URL.
  - Ambiguity 2: Lambda code deployment after first create (see Ambiguity notes) and the Turnstile widget creation are not fully settled in the spec.
  - Algorithmic difficulty 1: CloudFormation, OAC, OIDC trust conditions.
  - Test surface 1: template lint and a policy review.
- mcp: aws-mcp (read-only inventory: buckets, distributions, certificates, IAM roles, SES identities, the `all-projects-monthly` budget, the account's plan), cloudflare (read-only: the zone's DNS records, CAA, MX, SPF, DMARC, any old `www`, Web Analytics state, token scope), aws documentation search. **No writes.**

Spec sections 2.4, 4, D11, D13, D18, D26. Starts with the read-only inventory so nothing is duplicated, confirms the account is paid, that the IAM user's permissions cover S3, CloudFront, ACM, Lambda, SES and CloudFormation, that Cloudflare's CAA allows `amazon.com`, and notes the SES, MX and apex state. Then writes `infra/site.yaml` with every item in the spec 2.4 table (private S3 bucket with OAC, versioning and the 30-day lifecycle; CloudFront for `www.adhyaanilkumar.com` with HTTP/3, redirect to HTTPS, compression, `index.html` root, custom 404, a price class that includes India; the CloudFront Function for `/projects/x/` to `index.html`; the response-headers policy with HSTS at 1 day, nosniff, referrer policy and the CSP; cache headers split between `/_astro/*` and images versus HTML and PDF; ACM certificate with DNS validation; the GitHub OIDC role scoped to this repo, the `production` environment, the one bucket and one distribution; the SES domain identity and the Lambda, its Function URL, concurrency limit 2 and 14-day log retention). Nothing paid is applied here.

**Acceptance criteria**
- AC1: The inventory report lists what already exists (buckets, distributions, certificates, roles, SES identities, the `all-projects-monthly` budget) and the Cloudflare zone's records, and flags anything the template would duplicate or clash with; no call wrote anything.
  - verify_with: `command` - the report's call list shows only read operations; `owner` - reads the report
- AC2: The template includes every row of the spec 2.4 table; the OIDC role allows only `s3:PutObject/DeleteObject/ListBucket` on the one bucket and `cloudfront:CreateInvalidation` on the one distribution and trusts only this repo and the `production` environment.
  - verify_with: `command` - `cfn-lint` (or the AWS template validation through the MCP, read-only) passes · `vitest` - a policy test parses the template and asserts the role's actions, resources and trust conditions
- AC3: The bucket is private with block-public-access on and only CloudFront (OAC) can read it; no `*` principal appears in any bucket policy.
  - verify_with: `vitest` - template assertions
- AC4: The Lambda has concurrency 2, 14-day log retention, no stored data resource (no table or bucket for messages), and the owner's address and Turnstile secret are **parameters set by the owner, not in the template or any file**.
  - verify_with: `vitest` - template has no literal email and no secret value; `command` - `make scan` exit 0
- AC5: The response-headers policy sets HSTS (1 day), `nosniff`, `Referrer-Policy: strict-origin-when-cross-origin` and a CSP allowing only `self`, `static.cloudflareinsights.com`, `cloudflareinsights.com`, `challenges.cloudflare.com` and the Lambda URL.
  - verify_with: `vitest` - header values asserted
- AC6: A cost sheet states the monthly INR cost per resource and the total (spec section 11: about ₹2 to ₹3) with the rate and GST assumptions, ready for the owner's approval in T16.
  - verify_with: `owner` - reviews the sheet

---

### T16 · Infrastructure apply (everything except live `www`)
- type: Feature
- depends_on: T15
- ships_independently: no. The site is not served on `www` yet (T21).
- jira:
- rung: R3 (total 7)
- scores:
  - Files 0: executes one template (a few records and secrets set by hand).
  - Change 0: new AWS and Cloudflare resources.
  - Risk 2: creates paid-capable AWS resources, IAM, SES identities and DNS records.
  - Ambiguity 2: tool and permission gaps (MCP versus console) may appear.
  - Algorithmic difficulty 2: ACM validation and SES verification need ordered DNS steps and waiting.
  - Test surface 1: read-back checks.
- mcp: aws-mcp (write, only what `plan.md` lists), cloudflare (write: ACM validation CNAME, three SES DKIM CNAMEs, apex placeholder and redirect rule, Turnstile widget, after the owner's OK in `plan.md`). **Never touches the `www` record and never the production distribution's alias.**

D18 and D23. **Stops first for the owner's approval of `plan.md` and the monthly INR cost** (T15's sheet). Then applies `infra/site.yaml` in us-east-1 through the MCP (or the owner runs it in the console or CloudShell if the MCP cannot), adds the ACM DNS-validation record and the three SES DKIM records at Cloudflare (DNS only), and creates the free Turnstile widget through the Cloudflare MCP **after the owner approves that step in `plan.md`** (owner decision 3). The agent commits the public site key and the contact URL to the build config and sets the Turnstile secret key **only** in the Lambda configuration at AWS (never in a file, log, CI variable or report). The owner clicks the SES verification link for the destination inbox and enters the destination address into the Lambda configuration. The first Lambda zip is uploaded. No long-lived AWS keys are created.

**Acceptance criteria**
- AC1: Before any write, the owner has approved `plan.md` and the INR cost in the PR or the chat, and the approval is quoted in the task report.
  - verify_with: `owner` - approval recorded; the report quotes it with the date
- AC2: The stack creates cleanly; the bucket, distribution, certificate, Function, response-headers policy, OIDC role, Lambda and Function URL exist as the template describes.
  - verify_with: `command` - `DescribeStacks` shows `CREATE_COMPLETE` and the resource list, pasted (read-back through aws-mcp)
- AC3: ACM validation and the three SES DKIM CNAMEs exist at Cloudflare as DNS only and the certificate and domain identity reach `ISSUED` and `SUCCESS`; the `www` record does not exist or still points where it did.
  - verify_with: `command` - Cloudflare record listing and ACM and SES status pasted (read-back through the cloudflare and aws MCPs)
- AC4: The Lambda has concurrency 2, the Function URL's CORS allows only the `www` origin, the owner's address is set by the owner and the Turnstile secret key is set only in the Lambda configuration; neither appears in any file, log, CI variable or report.
  - verify_with: `command` - `GetFunctionConfiguration` read-back with env values masked · `owner` - confirms setting both
- AC4b: The Turnstile widget exists (created through the Cloudflare MCP after the owner's OK), the public site key and the contact URL are in the committed build config, and the secret key is nowhere in the repo.
  - verify_with: `command` - widget read-back (site key shown, secret masked); `git grep` for the secret finds nothing; `make scan` exit 0 · `owner` - approved the step in `plan.md`
- AC5: A Lambda smoke call from the owner's browser or `curl` with a deliberately bad Turnstile token returns 400 and sends no mail; no real submission is made by any agent.
  - verify_with: `command` - the response status pasted
- AC6: The owner has clicked the SES verification link for the destination inbox (D13).
  - verify_with: `owner` - confirms; `command` - `GetEmailIdentity` shows verified
- AC7: Nothing outside `plan.md`'s list was created or changed, nothing existing in the account was modified, and the cost read-back matches the approved sheet.
  - verify_with: `command` - before and after inventory diff pasted; `owner` - reviews

---

### T17 · Deploy workflow, `production` environment and branch protection
- type: Feature
- depends_on: T14, T16
- ships_independently: yes. A deploy path that runs only after the owner's approval; no site change by itself.
- jira:
- rung: R3 (total 6, forced to R3 by Risk 2)
- scores:
  - Files 1: `deploy.yml`, a smoke-test script, cache-header config, tests, a runbook note.
  - Change 0: new.
  - Risk 2: an OIDC role that can write to the live bucket and invalidate the distribution.
  - Ambiguity 1: how Lambda code updates are deployed later (see Ambiguity notes).
  - Algorithmic difficulty 1: sync with per-path cache headers, invalidation.
  - Test surface 1: workflow lint, smoke script tests, a dry run.
- mcp: aws-mcp (read: distribution status, last invalidation), playwright (read-only smoke test of the live URL and screenshots, never the form), `gh`.

Spec 2.5, D17, D24. GitHub Actions job on merge to `main`, behind the GitHub Environment `production` with the owner as required reviewer: OIDC login to the T15 role, `aws s3 sync` with the cache headers (`/_astro/*` and images `public, max-age=31536000, immutable`; HTML and PDF `no-cache`), invalidate `/*`, and a read-only smoke test. Branch protection on `main`: PR required, `ci` green, zero required approving reviews (the owner's merge click is the approval), no direct push. Rollback by re-running the deploy for a previous commit. The `PUBLIC_CONTACT_URL` and Turnstile site key come from committed build config (public values, set in T16), not from secrets or CI variables. **Lambda code updates (owner decision 2):** `plan.md` also proposes how Lambda updates are deployed later (see T12 AC9) and the owner reviews it; the OIDC role is not widened without that approval.

**Acceptance criteria**
- AC1: The deploy job runs only on `main`, waits for approval on the `production` environment (the owner as required reviewer), and does not run on a pull request.
  - verify_with: `command` - `gh api repos/:owner/:repo/environments/production` shows the required reviewer; workflow `on:` and `if:` conditions reviewed · `owner` - confirms the approval gate on the first run
- AC2: The workflow gets AWS access only by OIDC (no stored key) and its permissions are `id-token: write` and `contents: read` only.
  - verify_with: `command` - `grep` for `AWS_ACCESS_KEY` and `secrets.AWS` finds nothing; `permissions:` block reviewed
- AC3: `main` is protected: PR required, `ci` required and green, zero required approvals, no direct push, no force push.
  - verify_with: `command` - `gh api repos/:owner/:repo/branches/main/protection` output pasted; `command` - a test `git push` to `main` is refused
- AC4: Sync sets the cache headers per path as in spec 2.4 and deletes removed files; invalidation covers `/*` once.
  - verify_with: `vitest` - the header-mapping script's tests · `command` - on the first approved deploy, `HeadObject` read-back of one `_astro` file and one HTML file
- AC5: The smoke script, read-only, fetches `/`, the three project pages, the PDF headers (`application/pdf`), HSTS, the apex redirect and the certificate, and **never submits the contact form**.
  - verify_with: `vitest` - `smoke.test.ts` against a local server · `command` - the script's source has no POST to the Lambda URL
- AC6: A dry run (workflow on a test branch with the sync in `--dryrun`) lists the expected files without changing the bucket.
  - verify_with: `command` - dry-run log pasted; the bucket listing unchanged
- AC7: A runbook section (in `sdlc/v0/` or the README) documents rollback and who approves; no secret in any file.
  - verify_with: `owner` - reads it; `command` - `make scan` exit 0

- AC8: `plan.md` proposes one option for deploying later Lambda code updates (consistent with T12 AC9), says exactly what permission it needs, and the OIDC role in the template is unchanged until the owner approves.
  - verify_with: `owner` - reviews the proposal in the PR; `vitest` - the role test still asserts only the S3 and CloudFront actions
---

### T18 · Cloudflare Web Analytics beacon
- type: Feature
- depends_on: T8, T16
- ships_independently: yes. Adds one script tag; cookie-free.
- jira:
- rung: R2 (total 5)
- scores:
  - Files 1: layout edit, a config value, a CSP check, tests.
  - Change 1: edits the layout and the headers policy's allowed hosts if not already there.
  - Risk 1: a third-party script on a public page; cookie-free by Cloudflare's design.
  - Ambiguity 1: the MCP may not reach Web Analytics.
  - Algorithmic difficulty 0.
  - Test surface 1: script present, no cookies, no console errors.
- mcp: cloudflare (create the Web Analytics site for `www.adhyaanilkumar.com` and read back the public token; else the owner clicks it in the dashboard).

Spec section 7, D7. The owner (or the Cloudflare MCP) adds the hostname in Web Analytics and the build places the JavaScript beacon before `</body>`. The token is a public identifier. The footer line about anonymous visit counts already exists (T8) and is checked here. No automatic injection (the host is DNS-only).

**Acceptance criteria**
- AC1: Every page's built HTML has exactly one beacon script from `static.cloudflareinsights.com` with the site's token before `</body>`, and the token comes from a build variable, not a hard-coded secret.
  - verify_with: `vitest` - `analytics.test.ts` on `dist/` HTML
- AC2: The page sets no cookies and `document.cookie` is empty after load.
  - verify_with: `playwright` - `analytics.spec.ts` (FR11)
- AC3: The beacon host is allowed by the CSP in `infra/site.yaml` and the page logs no CSP or console errors.
  - verify_with: `vitest` - CSP string includes both Cloudflare insights hosts · `playwright` - console-error check
- AC4: Only the Cloudflare hosts and the Lambda URL appear in third-party network traffic on the main page (the beacon's request is allowed).
  - verify_with: `playwright` - host list assertion (NFR4)
- AC5: The footer states the visit counts are anonymous and cookie-free, in one line, at both widths.
  - verify_with: `screenshot-browser` - footer at 1440x900 and 390x844
- AC6: The Web Analytics site exists for `www.adhyaanilkumar.com` and its token is read back.
  - verify_with: `command` - Cloudflare MCP read-back (token shown, it is public), or `owner` - confirms the dashboard shows the site

---

### T19 · Claude PR review (copy `claude-review.yml` and `REVIEW.md` from Social Grid)
- type: Story
- depends_on: T14
- ships_independently: yes.
- jira:
- rung: R1 (total 3)
- scores:
  - Files 0: `.github/workflows/claude-review.yml`, `REVIEW.md`.
  - Change 0: new.
  - Risk 1: a workflow with a token secret; read-only for the code, one comment.
  - Ambiguity 1: `REVIEW.md` must be rewritten for this repo.
  - Algorithmic difficulty 0.
  - Test surface 1: one PR run.
- mcp: none (`gh` only).

D25. Copies Social Grid's workflow (read-only, one comment, never approves or blocks, runs on open, reopen, ready and on the owner's "@claude review" comment, `timeout-minutes: 20`). Rewrites `REVIEW.md` for this repo: its passes keep [Bugs], [Security], [Compliance], but the Security items become this site's: **a phone number anywhere; the owner's email outside the two allowed files, in the page, scripts or PDF; the original photo; a secret or API key; the Lambda's header injection, CORS and logging; an OIDC role wider than spec 2.4; a CSP weaker than spec 2.4**, and Compliance cites `sdlc/v0/spec.md`, the facts-from-the-resume rule and the cost rule. The Social Grid rules (session login, `apiFetch`, keyset paging) are removed.

**Acceptance criteria**
- AC1: `.github/workflows/claude-review.yml` matches Social Grid's behaviour (triggers, draft and fork skip, owner-only re-review, read-only permissions, concurrency group) with this repo's names.
  - verify_with: `command` - `diff` against Social Grid's file shows only intended changes, pasted
- AC2: `REVIEW.md` has no Social Grid-only rule, and includes the site's privacy, form, infra and CSP checks above plus the "no test skipped, weakened or deleted" rule.
  - verify_with: `owner` - reviews the file; `command` - `grep -n "apiFetch\|keyset\|Testcontainers" REVIEW.md` finds nothing
- AC3: On the task's own PR the action posts one review comment that covers the diff and cites `REVIEW.md`; it does not approve or block.
  - verify_with: `command` - `gh pr view` shows the comment; the workflow run is green
- AC4: The secret `CLAUDE_CODE_OAUTH_TOKEN` is set by the owner in repo secrets, never in a file; the Claude GitHub App is installed on the repo (owner action).
  - verify_with: `owner` - confirms both; `command` - `gh secret list` shows the name only
- AC5: The workflow adds no cost beyond the owner's existing Claude plan.
  - verify_with: `owner` - confirms

---

### T20 · Whole-site release gate (before the cutover)
- type: Story
- depends_on: T9, T10, T11, T13, T14, T18
- ships_independently: yes. A verification pass and fixes it finds; nothing is deployed.
- jira:
- rung: R2 (total 6)
- scores:
  - Files 1: tests, small fixes in components, a traceability table.
  - Change 1: edits existing pages for gaps.
  - Risk 1: the last check before a public release.
  - Ambiguity 1: some gate findings need judgment.
  - Algorithmic difficulty 0.
  - Test surface 2: every page at five widths, perf, a11y, privacy.
- mcp: playwright (all checks, screenshots), `design-taste-frontend` skill (`gate.mjs`, `perf.mjs`, run locally).

Runs the full spec 9 acceptance table end to end on the final built site and fixes what fails (failures found become fix commits with tests first, per the TDD rule). Writes `sdlc/v0/tasks/T20/traceability.md`: each FR1 to FR11 and NFR1 to NFR7 with the evidence (test name, screenshot, command output).

**Acceptance criteria**
- AC1: Run locally (not in CI), `gate.mjs` reaches `GATE: PASS` on `dist` at 1440, 1024, 820, 768 and 390 widths, with any waivers reviewed and listed in the PR.
  - verify_with: `gate` - local run output pasted in the PR; `command` - `grep -rn "gate.mjs" .github/` finds nothing
- AC2: `perf.mjs` (run locally) passes and the main page's first-load transfer is under 1 MB (NFR2); images and fonts are the largest assets.
  - verify_with: `command` - `perf.mjs` output and the transfer total pasted · `playwright` - network total asserted
- AC3: Keyboard operation, visible focus, labelled fields, AA contrast, `prefers-reduced-motion`, no horizontal scroll at 320 px (NFR3) on every page.
  - verify_with: `playwright` - the a11y spec on all pages at 1440x900, 390x844 and 320 px · `screenshot-browser` - looked at
- AC4: The privacy scan passes on tracked files, `dist/`, `resume.json` and the real PDF text; the page source, scripts and network log hold no email or phone (FR5, FR7).
  - verify_with: `command` - `make scan` over all three targets, exit 0 · `playwright` - network log check
- AC5: The traceability table covers FR1 to FR11 and NFR1 to NFR7 with real evidence for each; any item not yet verifiable before go-live (FR10, NFR5) is marked "checked at T21".
  - verify_with: `owner` - reviews `traceability.md`
- AC6: The fact sheet (T9, T10) covers every sentence on the site, and the owner re-approves it for the final build.
  - verify_with: `owner` - approves; `vitest` - fact-sheet quotes still match `resume.json`
- AC7: Build is reproducible: lockfile committed, TeX Live tag and action versions pinned (NFR7).
  - verify_with: `command` - `npm ci` and `make build` twice give identical `dist/` hashes for the static files; `grep` finds no unpinned action

---

### T21 · First deploy and live `www` cutover (owner approves)
- type: Feature
- depends_on: T17, T19, T20
- ships_independently: no. It is the release.
- jira:
- rung: R3 (total 5, forced to R3 by Risk 2)
- scores:
  - Files 0: no code; uses the deploy workflow and two DNS records.
  - Change 0: new live records.
  - Risk 2: makes the site public on the owner's domain; DNS and the apex redirect change.
  - Ambiguity 1: the order of steps and the cost recheck.
  - Algorithmic difficulty 1: DNS, certificate and CAA interactions.
  - Test surface 1: read-only smoke tests.
- mcp: cloudflare (add the `www` CNAME and the apex Redirect Rule only after approval), aws-mcp (read: distribution and certificate status), playwright (read-only smoke test and screenshots; **never submit the form**).

Spec D18, D22 and 2.5. **Stops for the owner twice:** (1) the first deploy goes through the approved `production` environment to the CloudFront default domain (`dxxxx.cloudfront.net`) and is checked there before any DNS change; (2) the owner approves the live cutover. Then adds `www` CNAME to the distribution (DNS only, grey cloud), the proxied placeholder apex record and the Redirect Rule from the apex to `https://www.adhyaanilkumar.com`, rechecks the cost, raises HSTS only after a clean week (a follow-up note, not part of this task). The owner does one real end-to-end contact-form send.

**Acceptance criteria**
- AC1: Before the cutover, the site on the CloudFront default domain passes the T17 smoke script and the T20 browser checks at 1440x900 and 390x844.
  - verify_with: `command` - smoke output pasted · `screenshot-browser` - both widths of the main page and one project page
- AC2: The owner has approved the cutover and the monthly INR cost after a rate and Billing check, and the approval is quoted in the report; the `www` record is added only after that.
  - verify_with: `owner` - approval recorded; `command` - the Cloudflare record's creation shown after the approval date
- AC3: `https://www.adhyaanilkumar.com` serves HTTPS with a valid certificate; the apex redirects to `www`; the 404 page works; `/projects/ultron/`, `/projects/social-grid/` and `/projects/sentinel-rag/` resolve (FR10).
  - verify_with: `command` - read-only smoke script against the live URL, output pasted · `screenshot-browser` - live pages at both widths
- AC4: Live response headers match spec 2.4: HSTS (1 day), nosniff, referrer policy, the CSP, and the cache headers per path (NFR5).
  - verify_with: `command` - `curl -I` on `/`, an `_astro` file and the PDF, pasted
- AC5: The live site and PDF contain no email and no phone; the live PDF's text matches the repo's `.tex` and the "Resume updated" date matches its last commit.
  - verify_with: `command` - the scan run over fetched pages and the live PDF text, exit 0 · `playwright` - download and text match
- AC6: The Cloudflare Web Analytics beacon is live and sets no cookies on the live site.
  - verify_with: `playwright` - cookie check against the live URL · `command` - the Web Analytics dashboard shows the site (owner)
- AC7: The owner does one real contact-form send and receives it with Reply-To set to the test visitor; no agent submits the form.
  - verify_with: `owner` - confirms receipt
- AC8: A rollback has been rehearsed or documented: the previous commit's deploy can be re-run, and bucket versioning holds the prior files.
  - verify_with: `command` - bucket versioning read-back; `owner` - reads the runbook
- AC9: The monthly cost matches the approved figure (about ₹2 to ₹3 for the site) and the `all-projects-monthly` budget has no new alert.
  - verify_with: `command` - budget and Billing read-back (aws-mcp, read-only), pasted

---

## Ambiguity notes (found while splitting the spec; items 1 to 4 and the CI gate question were answered, see Decisions at the top)
1. **`.mcp.json` is tracked by git** although D27 says it should be gitignored. Resolved (decision 1): T2 untracks and ignores it.
2. **Lambda code updates after the first create.** Resolved (decision 2): the T12 and T17 plans propose an option for owner review.
3. **Contact URL and Turnstile site key in the build.** Resolved (decision 3): committed build config.
4. **Turnstile widget creation.** Resolved (decision 3): an agent via the Cloudflare MCP after the owner's OK.
5. **Branch protection and the `production` environment** are said to be "reused" from Social Grid (D24) but must be set on this repo; T17 does it.
6. **`pdftotext` is not on this PC;** T5 and T3 run it in the pinned container (the plan confirms).
7. **Open for owner:** decision 4 says CI runs "build/lint/test only". These tasks read that as dropping only the design gate and keeping the resume PDF build, privacy scan and screenshots in CI (the scan is the fail-closed privacy guard). Say so if the scan, PDF or screenshots should also leave CI.
