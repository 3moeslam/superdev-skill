---
name: team-code-review
description: Use when reviewing code changes — PR diffs, branch diffs, or specific file changes — through a multi-agent pipeline. Spawns 7 specialist parallel reviewers (code standards / team style, architecture, clean code, simplification, market standards [SOLID · Clean Architecture · DDD], bug detection, security), aggregates findings via a staff engineer, runs a debate phase on disputed findings, proposes and debates solutions, and produces a structured findings checklist with file:line references and team-recommended solutions. Use for PR review, pre-merge review, security audit, periodic codebase review, or end-of-implementation review (composes with superdev Phase 5/6).
---

# team-code-review — Multi-Agent Code Review Pipeline

Operate code review at the highest standard. The product: a **structured findings checklist** of cross-validated, debated, and solution-proposed observations — file, line, finding, team-recommended solution. Single-pass review by one model misses things; a team of specialist agents with a debate phase doesn't.

**Violating the letter of the rules is violating the spirit of the rules.** No exceptions, no rationalizations.

---

## Hard Gates (cannot be skipped)

1. **Effort = max.** If `/effort max` is not active, instruct the user to run it once, then pause until set.
2. **Diff is bounded.** Phase 1 must produce a concrete file list and line-range scope. "Review the codebase" without a diff is not a valid scope — ask the user to specify.
3. **All seven specialist agents run.** No skipping based on intuition that a category "doesn't apply." If the diff is JS-only and you skip the Architecture Agent, you also skip the architecture findings — and that's how violations land in main.
4. **Parallel dispatch wherever independent.** Phase 2 is one message with seven `Agent` calls. Phases 4 and 5 batch their dispatches per round. Sequential dispatch of independent agents is a workflow failure.
5. **Debate before document.** Disputed findings are debated by defender + challenger before the staff engineer adjudicates. The checklist never includes a finding that hasn't been challenged at least implicitly.
6. **Every finding cites file:line.** No vague "the auth code has issues" — every finding points at a path and a line (or line range).
7. **Every finding has a team-recommended solution.** Code-level specifics, not "consider improving X." If no solution can be proposed, the finding is downgraded to NIT or dropped.
8. **The checklist document is the single authoritative output.** Conversation-only summaries are addenda; the MD file at `docs/code-review/<date>-<scope>.md` is what the team works from.

---

## When to Use / Skip

**Use** for: PR review, branch-diff review (current branch vs main), pre-merge review, security audit, periodic codebase review, end-of-implementation review (after superdev Phase 5).

**Skip** for: typo fixes, formatting-only changes, doc-only changes that don't touch behavior, single-line changes that are obviously correct, throwaway scripts the user has explicitly marked as such.

---

## Activation

Invoke via:

- `/superdev:team-code-review [scope]` — explicit invocation. Scope syntax:
  - `branch` — current branch vs main (default).
  - `pr <number>` — GitHub PR via `gh`.
  - `files <paths...>` — specific files.
  - `staged` — currently staged diff.
  - `commits <range>` — git revision range.
- **Implicit triggers**: user says "review this code", "do a code review", "deep review", "PR review", "audit this".
- **Composed**: from `superdev:superdev` — after Phase 5 (Verify) when the work merits cross-validated review beyond the quick Phase 6 self-review.

---

## Pipeline (six phases)

Each phase is mandatory. Each agent dispatch is a separate `Agent` tool call with `subagent_type: general-purpose` (or a more specific subagent type when one fits — see the per-agent notes below).

### Phase 1 — Scope & Setup

Gather everything the specialists need in a single batched-parallel sweep. **All reads in this phase go in one message** as parallel tool calls.

- **Compute the diff** — `git diff <base>..HEAD`, `gh pr diff <n>`, or whatever the scope demands. Save to `/tmp/review-diff-<id>.patch` if large; pass the path to subagents instead of inlining.
- **Enumerate changed files** — list with adds/dels per file. Group by language/framework.
- **Detect languages, frameworks, and project standards files** — `CLAUDE.md`, `AGENTS.md`, `.editorconfig`, `.eslintrc*`, `rustfmt.toml`, `clippy.toml`, `.prettierrc*`, `.ktlint*`, `pyproject.toml` lint sections, `tsconfig.json`, etc. Read them in parallel.
- **Sample 3–5 representative existing files** in the same modules touched by the diff (not in the diff) — these ground the Code Standards Agent's "team style" rubric.

**Output: a Scope Note** (≤ 10 bullets):
- Base / Head refs.
- Files changed (grouped by language).
- Languages / frameworks detected.
- Project standards files in play.
- Sample representative files for team-style.
- Anything unusual (huge files, generated code, vendored deps, migrations).

### Phase 2 — Parallel Specialist Review (7 agents, one message, all in parallel)

**Dispatch all seven agents in a single message** as parallel `Agent` calls. Each agent gets a self-contained brief: the diff path, the Scope Note, its rubric, and the output schema. Each agent has authority to run its own `Read` / `Grep` / `WebFetch` calls within its review.

**Per-agent output schema (mandatory, identical for all 7):**

```yaml
reviewer: <agent name>
findings:
  - id: <local id, e.g. "CS-1" for Code-Standards-1>
    severity: BLOCKER | MAJOR | MINOR | NIT
    file: <path>
    line: <line or "L42-L57">
    finding: <one-sentence description>
    rationale: <why it matters; cite rubric/pattern/source>
    suggested_solution: <code-level fix; concrete>
verdict_summary: <one-line per-agent verdict>
```

#### The Seven Specialists

##### 1. Code Standards Agent (team-style match)

- **Subagent type**: `general-purpose`.
- **Rubric**: read 3–5 representative existing files in the same module/package (from the Scope Note's samples) to learn the team's idioms — naming conventions, file organization, import order, error handling style, comment density, the team's quirks. Then check the diff against those patterns.
- **Goal**: new code reads as if the team wrote it. Findings flag divergence from established team style — even if the divergence is "more correct" by some external standard.
- **Examples of findings**: snake_case in a file where the team uses camelCase; new error type added with `pub struct` when the team's convention is `thiserror::Error` enums; result-bubbling pattern that doesn't match the team's `?`/`map_err` style.

##### 2. Architecture Agent (project architecture)

- **Subagent type**: `general-purpose` (or `feature-dev:code-reviewer` if it fits the project).
- **Rubric**: read the project's architecture docs (CLAUDE.md layer rules, module boundaries, dependency direction, ports/adapters). Check the diff for layer violations, dependency direction violations, misplaced files, leaky abstractions, business logic in the wrong layer.
- **Examples of findings**: SQL in a domain crate; HTTP DTO leaked through a domain return type; use case calling a concrete repository instead of the trait; infrastructure import in domain.

##### 3. Clean Code Agent (Clean Code specs)

- **Subagent type**: `general-purpose`.
- **Rubric**: Robert C. Martin's *Clean Code* — naming reveals intent, function size (≤ ~20 lines logic), function arguments (≤ 3, no boolean traps), single level of abstraction per function, comments-as-code-smell (only WHY, not WHAT), dead code, magic numbers, primitive obsession.
- **Examples of findings**: function with 6 args including 2 booleans; magic number `0.15` without a named constant; comment explaining what `parse_x()` does when the name should suffice; nested `if` chain 4 deep.

##### 4. Code Simplification Agent

- **Subagent type**: `code-simplifier:code-simplifier` if available, else `general-purpose`.
- **Rubric**: redundant code, over-abstraction, unnecessary indirection, duplicated logic that could be unified, premature optimization (caching with no measured need, parallelism with no measured benefit), opportunities to delete code entirely.
- **Examples of findings**: two near-identical functions that could be one with a parameter; trait with one impl that could just be the concrete; helper module that's only called from one site; `Option<Option<T>>` that should be `Option<T>`.

##### 5. Market Standards Agent (SOLID · Clean Architecture · DDD + language idioms)

- **Subagent type**: `general-purpose`.
- **Rubric**:
  - **SOLID** per principle (SRP / OCP / LSP / ISP / DIP).
  - **Clean Architecture** — dependency direction inward, framework-free domain, ports owned by upstream layer, DTOs ≠ domain types.
  - **DDD** — aggregates protect invariants, value objects validate at construction, ubiquitous language in code, domain events past-tense.
  - **Language/framework idioms** — pull in the relevant standards for the diff: Effective Rust, Kotlin Coroutines best practices, React rules-of-hooks, Spring Boot conventions, Express middleware ordering, etc. Authority to `WebFetch` / `context7` for current sources.
- **Examples of findings**: god-class with 8 responsibilities (SRP); `unimplemented!()` in a production trait impl (LSP); domain entity exposing public mutable field (DDD invariant leak); `useState` after early return (React rules-of-hooks).

##### 6. Bug Detection Agent

- **Subagent type**: `general-purpose`.
- **Rubric**: off-by-one, null/None handling, race conditions, error swallowing (empty catch, silent `?` discard, unchecked `Result`), incorrect exception scope, wrong return value on error path, type confusion, unhandled cases in pattern matches, integer overflow, encoding issues (UTF-8 vs bytes), time-zone bugs, async/await misuse (forgotten `.await`, blocking call inside async, lock held across `.await`).
- **Examples of findings**: `for i in 0..len` then `arr[i+1]` (off-by-one); `match` on enum without exhaustive arms after a new variant was added; `tokio::sync::Mutex` held across `.await` causing deadlock potential; `parseInt(x)` without radix.

##### 7. Security Agent

- **Subagent type**: `general-purpose` (or a security-specific subagent if installed).
- **Rubric**: OWASP top 10 mapped to the diff's context — input validation at boundaries, injection (SQL / command / path / template), broken access control, secrets in code or logs, weak/missing crypto, IDOR, SSRF, deserialization risks, dependency CVEs visible in the diff (lockfile changes), authn/authz checks at every entry point, sensitive data in error messages, CORS misconfig, missing rate limit on auth endpoints.
- **Examples of findings**: query built via string concatenation (SQL injection); JWT secret hardcoded as a constant; user-supplied URL passed to outbound HTTP without allow-list (SSRF); dynamic-code execution applied to untrusted input; password compared with `==` (timing); file path joined without normalization (path traversal).

#### After Phase 2

**Aggregate raw findings** into a single working list with auto-assigned global IDs (`F1, F2, F3, ...`). Preserve each finding's originating reviewer. Save to a working file `/tmp/review-findings-<id>.yaml` for downstream phases.

### Phase 3 — Staff Engineer Aggregation

Spawn **one staff engineer subagent** (`Agent`, `general-purpose`) with the full raw findings list. The staff engineer's job:

- **Deduplicate**: same line / same root cause flagged by multiple agents → merge into one finding, attribute to all reviewers (`reviewers: [clean-code, simplification]`).
- **Cluster**: findings sharing a root cause (e.g. five SOLID findings stemming from one God-class) → cluster under a parent finding with children.
- **Severity arbitration** — when agents disagree, normalize:
  - **BLOCKER** — correctness, security, architecture-breaking, data-loss risk.
  - **MAJOR** — measurable design-quality / maintainability / performance impact.
  - **MINOR** — local clarity / style improvement.
  - **NIT** — pure taste; flagged for awareness, not action.
- **Disputed list**: flag findings where the rationale is weak, the suggested solution doesn't fit the codebase, the originator may be wrong, or two agents conflict on whether something is a problem.

**Output**: cleaned findings list + disputed-findings sub-list (subset).

### Phase 4 — Debate (findings)

For **each disputed finding**, dispatch a 2-agent debate **in parallel across all disputes**:

- **Defender** = the original reviewer agent. Brief: *"Your finding F12 is disputed because <reason>. Defend or revise. Cite specific code, patterns, or sources. If you revise, explain why."*
- **Challenger** = a peer agent with relevant expertise (Clean Code finding → Code Standards challenges from team-style angle; Security finding → Bug Detection challenges from feasibility angle; Architecture finding → Market Standards challenges from SOLID angle).

After all debates return, the staff engineer subagent **adjudicates each disputed finding** in a single follow-up call:

- **keep** — defender's argument holds; finding stands.
- **revise** — partial point on both sides; finding rewritten.
- **drop** — challenger's point holds; finding removed.

Each retained finding gains a `debate_outcome` field: `"consensus"`, `"revised after debate: <note>"`, or for non-disputed: `"undisputed"`.

### Phase 5 — Solution Proposal & Debate

For each surviving **BLOCKER** and **MAJOR** finding (and optionally MINOR if the user requests deep treatment), dispatch a solution round **in parallel across all findings**:

- **Solution proposer** = the original reviewer (or staff engineer for cluster findings). Brief: *"For F12, propose 1–2 concrete code-level solutions. Each solution: what to change, where, with a code sketch. Note any risks the solution introduces."*
- **Solution challenger** = a peer agent (different from the proposer). Brief: *"Here's a proposed solution for F12: <proposal>. Critique. Is there a simpler / more idiomatic / less risky alternative? Does this solution introduce new problems? Propose your own alternative if the proposed one is weak."*

After all solution debates return, the staff engineer subagent **picks the team-recommended solution** for each finding — possibly synthesizing both proposals. If genuine ambiguity remains, list both as `solution_a` and `solution_b` with trade-offs and pick a primary.

### Phase 6 — Findings Checklist Document

Write the final artifact to `docs/code-review/<YYYY-MM-DD>-<scope-slug>.md`. Create the directory if missing. **This is the single authoritative output.** Format:

```markdown
# Code Review — <branch / PR# / commit-range> — <YYYY-MM-DD>

## Scope
- **Base:** `<commit/branch>`
- **Head:** `<commit/branch>`
- **Files changed:** N (+A / -D)
- **Languages:** Rust, TypeScript
- **Reviewers:** code-standards, architecture, clean-code, simplification, market-standards, bug-detection, security
- **Pipeline:** 7 specialists → staff engineer aggregation → debate → solution proposal & debate → checklist
- **Standards files:** CLAUDE.md, .eslintrc.json, rustfmt.toml

## Summary
- BLOCKERs: 3
- MAJORs:   8
- MINORs:   12
- NITs:     5
- Total:    28

## Findings

### F1 — BLOCKER — SQL injection in repricer query builder

- **File:** `crates/vendex-infrastructure/src/persistence/repricer_repo.rs:142`
- **Reviewer(s):** security, bug-detection
- **Finding:** User-supplied SKU is concatenated directly into a SQL string in `RepricerRepo::find_by_sku`, bypassing sqlx parameter binding.
- **Rationale:** Classic injection vector. The rest of the file uses `query!` macros correctly; this one path was missed.
- **Debate outcome:** consensus — bug-detection confirmed exploitability, code-standards confirmed divergence from the file's prevailing pattern.
- **Team-recommended solution:** replace the `format!`-built query with `sqlx::query_as!(RepricerRow, "SELECT ... WHERE sku = $1", sku)`. Add a regression test with a SKU containing `';--` to lock the fix.

### F2 — BLOCKER — Lock held across `.await` in repricer scheduler
- **File:** `crates/vendex-agent/src/scheduler/loop.rs:88-94`
- **Reviewer(s):** bug-detection
- **Finding:** `state.lock().await` is held while `client.fetch_competitor_price().await` is called. Under contention this serializes all repricer ticks behind the slowest network call.
- **Rationale:** Tokio mutex held across an await blocks every other waiter for the duration of the await. Standard async footgun.
- **Debate outcome:** consensus.
- **Team-recommended solution:** drop the lock before the await — clone or move out the data needed, run the fetch unlocked, then re-acquire to write the result.

### F3 — MAJOR — Domain entity exposes mutable field
- **File:** `crates/vendex-domain/src/sku/aggregate.rs:34`
- **Reviewer(s):** market-standards (DDD), architecture
- **Finding:** `Sku.price: pub Price` allows external mutation, bypassing the aggregate's invariant checks.
- **Rationale:** Aggregates must enforce all invariants; a public mutable field is an invariant leak. CLAUDE.md `Domain-Driven Design Rules` explicitly forbids this.
- **Debate outcome:** revised after debate — solution updated from "make field private with getter" to "make field private with `Sku::reprice(&mut self, new: Price) -> Result<...>`" so callers go through the invariant-checking method.
- **Team-recommended solution:** change `pub price: Price` → `price: Price` (private) and add `pub fn reprice(&mut self, new_price: Price) -> Result<RepricingAction, RepricingError>` that runs the existing margin-floor / consent checks.

<!-- ... continue with all findings ... -->

## Notes
- Cluster F8–F12 share a root cause (God-class `RepricerOrchestrator`); listed under F8 with children F9–F12.
- One disputed finding (originally CC-3) was dropped after debate — see commit history.
```

**Per-finding required fields:**

| Field | Required | Notes |
|---|---|---|
| **ID** | yes | `F<n>` global; never reused. |
| **Severity** | yes | BLOCKER / MAJOR / MINOR / NIT. |
| **Title** | yes | One sentence. |
| **File** | yes | Path. |
| **Line** | yes | Line number or range. |
| **Reviewer(s)** | yes | All originating agents. |
| **Finding** | yes | Description with concrete reference to the code. |
| **Rationale** | yes | Why it matters + which standard / pattern / rule. |
| **Debate outcome** | yes | `consensus`, `revised after debate: <note>`, or `undisputed`. |
| **Team-recommended solution** | yes | Code-level fix. If two solutions remain, list both with trade-offs and pick a primary. |

**Hand the user**: a one-paragraph summary in chat + the file path. Do not paste the whole document into chat — point at the file.

---

## Composition with Other Skills

- **`superdev:superdev`** — `superdev:team-code-review` is the natural deep review after `superdev:superdev`'s Phase 5 (Verify). The Phase 6 self-review is the quick sanity check; this skill is what runs when the work merits cross-validated multi-agent review.
- **`superpowers:requesting-code-review`** — covers single-pass review workflows. team-code-review is the multi-agent variant; pick based on depth needed.
- **`pr-review-toolkit:review-pr`** — pre-existing PR review skill with its own subagent set. team-code-review is independent but the two can be used in succession (theirs first for quick pass, this for depth, or the reverse).
- **Project-specific review skills** — if a project ships its own review skill (architecture-aware, codebase-aware), prefer it as the project-specific reviewer; team-code-review covers what the project skill doesn't.

---

## Communication Rules

- **Short, clear, structured** — every message earns its length.
- **Phase tag** in each reply (which phase you're in).
- **Show the dispatch** — when you fan out 7 agents, name them in one line so the user can see what's running.
- **Don't paste agent outputs into chat** — they're large. Summarize, point at the file path, surface only the headline numbers (BLOCKERs found, total findings).
- **Verify before claiming** — the file exists, the format matches, the per-finding required fields are all present.

---

## Red Flags — STOP and reset

| Thought | Reality |
|---|---|
| "I'll just do the review myself in one pass" | The whole point is the multi-agent debate. Single-pass review reproduces single-model blind spots. Spawn the seven. |
| "I'll skip the Architecture Agent — the diff is just a one-file change" | The agent's job is to verify *that* the one-file change doesn't violate architecture. Skipping it is how violations land. |
| "I'll dispatch the seven agents one at a time so the output's cleaner" | Dispatch all seven in one message as parallel `Agent` calls. Sequential is a workflow failure. |
| "I'll include the finding in the checklist without a recommended solution" | Every finding has a code-level solution or it's downgraded to NIT or dropped. "Consider improving X" is not a solution. |
| "I'll skip the debate — the staff engineer's adjudication is enough" | Debate is what gives the staff engineer a position to adjudicate from. Skip the debate and you skip the depth. |
| "I'll write findings without file:line because the change is small" | Every finding cites file:line. Without it, the team can't act. |
| "I'll paste the full findings doc into the chat reply" | Point at the file path. The doc is the artifact; the chat is the pointer. |
| "Two agents flagged the same line — I'll keep both findings separate" | Deduplicate during Phase 3. Same line / same root cause = one finding, multiple reviewers. |
| "I found a BLOCKER — I'll just fix it myself instead of writing it up" | Write it up. team-code-review produces the artifact; fixing is downstream. (Unless the user explicitly asked for fix-as-you-go.) |
| "I'll launch the solution debate before the finding debate" | Order matters. A finding might be dropped in Phase 4; debating its solution first wastes a round. |
| "Close enough" | If the bar isn't met, the document isn't done. |

---

## Priority Order (when rules conflict)

1. **User's explicit instructions** (highest).
2. **Project CLAUDE.md / AGENTS.md / rules files.**
3. **team-code-review hard gates.**
4. **team-code-review pipeline.**
5. **Default model behavior** (lowest).

If the user says "skip the security agent for this internal tool review," obey — but say once that this skill normally requires all seven. Then proceed.

---

## Output Shape Per Reply

While team-code-review is active:

- **Phase tag** — which phase.
- **One-paragraph status** — what just ran / what was found.
- **Next-action line** — what's about to dispatch, or the path to the final document.

The only reply that ends with a question is one that hit a real blocker (no diff to review, undecidable disputed finding the user must arbitrate, missing standards file the user must locate). Otherwise, keep dispatching and reporting.
