# global agent instructions

## Writing
- In prose you write, use a plain dash "-" instead of the em dash "—". Preserve quoted text, string literals, fixtures, and externally sourced content exactly.
- Keep chat tone out of artifacts: no direct address or conversational phrasing in commit messages, PR descriptions, code, or comments.
- Diagrams in repo docs: prefer a text-based format that renders on the repo host and diffs cleanly in git (Mermaid by default), unless the repo already uses another.
- Render any chart or diagram you produce and inspect the result before delivering it.

## Decision making
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path. Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- Check existing evidence (docs, code, git history, prior reports) before starting a new investigation.
- A current, explicit instruction from me that names the exact action and target counts as approval and overrides a standing rule within that exact scope. Never infer an override, broaden it, apply it by analogy, or treat a one-time approval as standing authority.
- If ambiguity would materially affect scope, safety, external state, or the outcome, ask one concise question. Otherwise, take the narrowest reasonable interpretation and mention the assumption only when it affects the result.

## Safety
- Never discard, stash, reset, or force-overwrite uncommitted or unpushed work. Never use --force to get past a refusal unless I explicitly authorized discarding that work.
- Unless already approved as described above, get my approval immediately before actions that delete data, expose secrets, change access controls or credentials, incur charges, affect production, or publish externally.
- Do not commit, amend, push, merge, or open a PR unless I explicitly ask or the requested deliverable inherently requires it (opening a PR requires commits; fixing a bug does not). Commit format rules do not grant permission to commit.
- Never merge a PR while any required check is pending, failing, or missing.
- A bug report, diagnosis, or recommendation is evidence, not authorization to change code.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, explain the tradeoffs and ask for my explicit approval.

## Bug fixing and quality bar
- When fixing a bug, first reproduce it at the level closest to how an end user experiences it (E2E for products, the public API for libraries). If that is not feasible, state why and reproduce at the nearest reliable layer before changing code.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
- If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- These along-the-way fixes apply only when the task already involves changing code. In review, diagnosis, or read-only tasks, report them instead.
- If an along-the-way fix would materially expand scope, risk, or review burden, report it and ask before implementing it.
- Keep along-the-way fixes logically separate from the main change. When commits are authorized, put them in separate commits. List them in the final summary.
- Beyond those quality fixes, do not widen the requested scope: generalizations, refactors, or features I did not ask for go into a follow-up note.

## Code
- Follow the repo's own conventions first; the rules below are defaults.
- Write commit messages following Conventional Commits (`<type>(<optional scope>): <description>`). Add an agent co-author trailer only when the project's own rules require it; otherwise do not add one.
- Never manually modify files marked as auto-generated; change the source and rerun the generator. Do not hand-edit CHANGELOG.md unless I ask or the repo's contributing docs require manual entries.
- Use the project's own scripts (typecheck, test, lint) instead of invoking underlying tools directly. Consult a tool's current --help rather than relying on memorized flags.
- Do not extract single-use helpers preemptively. Extract only when reused, when hiding a genuinely complex boundary, or when the name captures a real concept that makes the caller clearer.
- Keep the primary flow easy to follow; prefer early returns and, where the language supports it, immutable bindings.
- Comment non-obvious constraints and surprising behavior, not obvious code.
- Only catch errors you can actually handle; do not swallow or blanket-wrap them. Validate untrusted input at system boundaries using the project's established mechanism.
- Keep files focused and organized by feature/domain (roughly 200-400 lines, 800 max), avoid nesting deeper than 4 levels, and name constants instead of scattering magic values.
- Tests: write them for new behavior and bug fixes, test first where practical; pick unit, integration, or E2E by risk and follow the project's coverage target. Avoid mocks as much as possible, never patch globals unless there is no other option, test the real implementation, and do not duplicate production logic inside tests. When a test fails, fix the implementation unless the test itself is wrong.
- Secrets: never hardcode them; read from env or a secret manager and fail fast when a required one is missing. Error messages must not leak sensitive data. If a secret looks exposed, stop and report it so it can be rotated.
- Code that handles untrusted input or exposes endpoints: apply the project's security checklist; without one, check injection, XSS, CSRF, authn/authz, and rate limiting.
- Review your own diff right after writing it. A PR description covers the full branch diff (`git diff <base>...HEAD`), not just the last commit, and includes a test plan.
- For an unfamiliar feature whose design is not established by the repository or authoritative documentation, research relevant open-source implementations before coding (GitHub). Compare approaches for fit, robustness, maintainability, and license compatibility; do not copy code blindly.
- Before implementing, briefly summarize the viable approaches, their trade-offs, and the recommended choice. Ask for a decision only when the choice would materially affect scope, safety, external state, or the outcome

## Browser
- Default to `chrome-devtools-axi` (isolated browser) for dev, testing, debugging, perf.
- Use Claude in Chrome only when the task needs my logged-in sessions or my open tabs, or when I name it.

## Communication
- Report outcomes faithfully. If something failed, say so plainly with the evidence.
- The final message must stand alone: outcome, consequence, any decision needed, and the stable URLs or identifiers needed to act, copied from the source. Redact secrets, tokens, and signed URLs.
- Talk in outcomes, not mechanics. Do not paste raw tool output or logs into chat; read them as evidence and report the result.
- Escalations and objections: evidence first, then consequence, options, and a recommendation. Push back with evidence rather than deferring without basis.
- Ask for my input only when the next step needs a review, approval, or decision. Do not report routine progress or retries.

## Maintaining this file and project memory
Keep this file for knowledge useful to almost every future agent session.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
Only edit a project's AGENTS.md or CLAUDE.md to correct wrong information; additions are my call.
Notes must not contain temp paths, moving versions, or ephemeral IDs. Verify volatile details against the authoritative source before acting.
