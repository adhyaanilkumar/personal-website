# T1 plan: Stack and tooling setup
Author: Claude (R2 developer subagent, Sonnet 5.5 high, attempt 1), for adhyaanilkumar. Date: 2026-11-24. Branch: `v0-t1-tooling`.
Source: `sdlc/v0/tasks.md` T1, `sdlc/v0/spec.md` D12, section 6.1, section 10, NFR7.

## Goal
A working, empty Astro site plus the commands to build, lint, test and preview it, and a CI job. Nothing public changes (no deploy). No design values yet: T6 picks the look and T8 builds the shell.

## Version choices (checked on npm, 2026-11-24)
The installed Node is 22.16.0. Astro 7 and `@astrojs/react` 7 need Node 22.23.4 or newer, so they are **not** used.

| Piece | Choice | Why |
|---|---|---|
| Astro | 6.x (`engines >=22.12.0`) | Runs on the installed Node 22.16. Static output is the default. |
| `@astrojs/react` | 5.x (`>=22.12.0`) | The integration line that matches Astro 6. |
| React | 19 | 21st.dev and shadcn components target it. |
| Tailwind | 4.x with `@tailwindcss/vite` | CSS-first config (`@theme`), so T6 can map tokens in one CSS file. `@tailwindcss/cli` is added as a dev dependency so `npx tailwindcss --help` resolves (AC5); v4's core package has no binary. |
| TypeScript | 6.0.x, strict | typescript-eslint 8.74 supports `<6.1`; `@astrojs/check` supports 5 or 6. TypeScript 7 is not supported by either. |
| ESLint | 10 flat config, `typescript-eslint`, `eslint-plugin-astro` | Plugin peers need ESLint 10. |
| Prettier | 3 with `prettier-plugin-astro` | |
| Vitest | 5 | Node 22.12+. |
| Playwright | `@playwright/test` 1.65 | Real Chromium. |
| shadcn helpers | `clsx`, `tailwind-merge` and `src/lib/utils.ts` (`cn`) | What `components.json` aliases point at, so 21st components paste in later. |

Node: `.nvmrc` says `22`; `package.json` `engines.node` is `>=22.12.0`. Exact versions are pinned by `package-lock.json` (committed); `npm ci` is used in CI.

## Files that change (in order of work)
1. `sdlc/v0/tasks/T1/plan.md` (this file, committed alone first).
2. Tests first (TDD): `tests/unit/utils.test.ts` (fails until `cn` exists) and `tests/e2e/smoke.spec.ts` (fails until the page exists).
3. Project files: `package.json`, `package-lock.json`, `.nvmrc`, `astro.config.mjs`, `tsconfig.json`, `components.json`, `src/styles/global.css`, `src/lib/utils.ts`, `src/pages/index.astro`.
4. Tool configs: `eslint.config.js`, `.prettierrc.json`, `.prettierignore`, `vitest.config.ts`, `playwright.config.ts`.
5. `Makefile`: `build`, `lint`, `test` (unit then browser), `preview`; style copied from social-grid (MSYS2 bash, `npm.cmd` on Windows). The pass-stamp and Docker parts of social-grid are not copied: this repo has no PR hook yet. `make resume` arrives in T5.
6. `.github/workflows/ci.yml`: job id `ci`, on `pull_request`, `permissions: contents: read`, actions pinned to full commit SHAs (checkout v7.0.1, setup-node v7.1.0), `ubuntu-24.04`, Node from `.nvmrc`, `npm ci`, Chromium install, then `make lint`, `make test`, `make build`. No secrets.
7. `.gitignore`: add `.astro/`, `test-results/`, `playwright-report/` (the five required patterns are already present).
8. `CLAUDE.md`: replace "Add build, lint and test commands here ..." with the real commands and the Node version; keep it about a page.

The placeholder page holds only the heading "personal-website" and the line "Coming soon." No personal data, no photo, no invented facts, no colours (browser defaults plus Tailwind's reset).

## Test design
- Unit (Vitest): `cn` merges class names and lets the later Tailwind class win. This is a real function in the repo, not a stub.
- Browser (Playwright, `tests/e2e/smoke.spec.ts`): two projects, `desktop` 1440x900 and `mobile` 390x844, both Chromium. The test loads `/`, fails on any console error or page error, asserts the heading is visible and asserts `scrollWidth <= clientWidth` (no horizontal scroll).
- `playwright.config.ts` starts `npm run build && npm run preview` on `127.0.0.1:4321` itself, so `npx playwright test` works from a clean tree; locally it reuses a running preview.
- Lint: `eslint . --max-warnings 0`, `prettier --check`, `astro check`.

## Proof per acceptance criterion
- AC1: `make build`, `make lint`, `make test` exit 0; result lines pasted.
- AC2: `smoke.spec.ts` passes on both projects (console, scroll). Playwright MCP opens the built site (served by `make preview`) at 1440x900 and 390x844 and takes screenshots to look at.
- AC3: `git diff` of `CLAUDE.md` and `.gitignore`; `git check-ignore -v assets/photo.jpeg private/x` and `.taste-skill/chrome-x` print matches.
- AC4: The pinned-action `grep -E "uses: .*@(main|master|v[0-9]+$)"` finds nothing and `package-lock.json` is tracked. The green PR run needs a push and a PR, which this task may not do (never push); it stays open for the owner or the main session. The workflow is also dry-checked by running the same three `make` commands from a clean `npm ci`.
- AC5: `components.json` is present and valid for shadcn; `npx tailwindcss --help` resolves; no hex colour or design value appears in source; owner reviews the choices in the PR.

## Risks
- Node 22.16 is below Astro 7's floor: handled by choosing Astro 6. A later bump needs a Node upgrade.
- TypeScript 7 and ESLint 10 are new: if a plugin conflicts, fall back to the nearest supported version and record it here.
- Windows: `make` runs in MSYS2 bash (as in social-grid). `playwright install` downloads Chromium once into the user cache folder, which has spaces; if that breaks, set `PLAYWRIGHT_BROWSERS_PATH` to a folder without spaces.
- CRLF on Windows (`core.autocrlf=true`): Prettier uses `endOfLine: "auto"` so `--check` does not fail on a checkout.
- `.mcp.json` is tracked and is T2's job (owner decision 1); this task leaves it alone.
- A green CI run cannot be shown without a push (see AC4).

## MCPs used
playwright (open the built page at both widths and screenshot it). No AWS, Cloudflare or 21st calls.
