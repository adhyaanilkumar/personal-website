# Agent rungs

Copied from ultron (`C:\git\ultron\sdlc\v0\spec.md` §11.4) on 2026-11-22, with the owner's later change: on the Max plan, Fable is allowed as the top rung without asking (owner, 2026-11-20). Every subagent friday's SDLC spawns (research, developer, testing) runs on this ladder. Pass `model` and `effort` on every Agent call and state the rung when spawning.

| Rung | Model | Effort |
|---|---|---|
| R0 | Haiku 5.5 | medium |
| R1 | Sonnet 5.5 | medium |
| R2 | Sonnet 5.5 | high |
| R3 | Opus 5.5 | high |
| R4 | Opus 5.5 | xhigh |
| R5 | Opus 5.5 | max |
| R6 (cap) | Fable 5.2 | high |

Why this order: above `high`, the ladder changes model rather than raising effort, because Opus high beats Sonnet xhigh at a lower cost.

## Starting rung
For a build task, score each factor 0, 1 or 2, judged from the code and not only the wording. Write the scores, a one-line reason for each, and the rung into `tasks.md`.

| Factor | 0 | 1 | 2 |
|---|---|---|---|
| Files or modules touched | 1–2 | 3–5 | 6 or more |
| Change type | New, additive | Edits existing code | Cross-module refactor |
| Risk | None | Moderate | Concurrency, security or auth, migrations, data loss, public API |
| Ambiguity of acceptance criteria | Low | Some | High |
| Algorithmic difficulty | Low | Some | High |
| Test surface | Small | Medium | Large |

| Total | Starting rung |
|---|---|
| 0–2 | R0 |
| 3–4 | R1 |
| 5–6 | R2 |
| 7–8 | R3 |
| 9 or more | R4 |

- Any risk factor scored 2 forces at least R3. For friday, anything touching Gmail, outreach, or personal data counts as risk 2.
- `plan.md` may propose a different rung, with a reason, for the owner to approve.
- A testing agent runs at the task's rung, but never below R1.
- Non-build subagents start by the kind of work: R0 read-only fetching or listing; R1 routine writes from clear instructions; R2 judgment-heavy synthesis or research; R3 or higher for high-risk, hard-to-undo or outward-facing work.

## Climbing on failure
- **Counted failures move up one rung:** failing tests, a stop by the owner, hitting the turn or token limit, or ending without passing tests or with bad or incomplete output.
- **Not counted, and no climb:** usage limits, overload and infrastructure errors. Rerun at the same rung.
- **The same test failing the same way twice** goes back to `plan.md` with that evidence, instead of just adding power.
- At most 3 attempts (CLAUDE.md, TDD rule), then hand over to the owner. At the cap, attempts stay at the cap. A task that starts at R2 runs R2, R3, R4.
- An escalation ticket lists the rung of each attempt.
