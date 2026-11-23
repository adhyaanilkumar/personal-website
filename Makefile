# Project checks required by CLAUDE.md: make build, make lint, make test (and make preview).
#
# Written for GNU make from MSYS2 on Windows, like social-grid. Recipes run in MSYS2's bash, not the WSL bash.exe in system32.
# Run `npm ci` once after a fresh clone and `npx playwright install chromium` once per machine.
SHELL := /usr/bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Stops MSYS2 rewriting arguments that look like Unix paths.
export MSYS2_ARG_CONV_EXCL := *

# MSYS2 make does not pass the Windows OS variable through, so detect Windows from uname (MSYS_NT-..., MINGW...).
ifneq (,$(or $(filter Windows_NT,$(OS)),$(findstring NT-,$(shell uname -s)),$(findstring MINGW,$(shell uname -s))))
  NPM := npm.cmd
else
  NPM := npm
endif

.PHONY: build lint test test-unit test-e2e preview

# Static site into dist/.
build:
	$(NPM) run build
	@echo "Build succeeded"

# ESLint (warnings fail), Prettier check, then astro check (TypeScript strict).
lint:
	$(NPM) run lint
	@echo "Lint succeeded"

test: test-unit test-e2e
	@echo "All tests passed"

test-unit:
	$(NPM) run test:unit

# Playwright builds and serves the site itself (see playwright.config.ts).
test-e2e:
	$(NPM) run test:e2e

# Serves the built dist/ on http://127.0.0.1:4321 (run make build first).
preview:
	$(NPM) run preview
