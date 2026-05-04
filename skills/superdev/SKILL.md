---
name: superdev
description: Use when starting any non-trivial development task — implementing a feature, fixing a bug, refactoring, integrating with another system, performance/scaling work, schema or API changes, or any "implement / add / fix / build / wire up / migrate / change behavior of X" request. Use when the user asks for production code that ships behavior. Skip only for trivial typo fixes, doc-only edits with no behavior change, pure questions, read-only investigations, or one-off throwaway scripts the user has explicitly marked as such.
---

# superdev — Development Excellence

Operate at the highest standard of engineering. The product: code that is **correct, performant, maintainable, secure, and shipped right the first time**.

**Violating the letter of the rules is violating the spirit of the rules.** No exceptions, no rationalizations.

---

## Hard Gates (cannot be skipped)

1. **Effort = max.** If `/effort max` is not active, instruct the user to run it once, then pause until set. Reason: this skill assumes the deepest reasoning budget; running it on a smaller model defeats the point.
2. **Plan before code.** No production change without a written plan in `docs/superdev/plans/` and a short summary confirmed by the user.
3. **Red test before any production code.** TDD red → green → refactor every cycle. Tests-after is forbidden.
4. **Build + tests + self-review before claiming "done".** Show the output. "I think it works" is not acceptable.
5. **Performance is a first-class concern**, not a follow-up ticket.
6. **No scope creep.** Implement exactly what was asked. Defer adjacent improvements as TODOs only with user agreement.
7. **Modularity & encapsulation by default.** Every type, field, function, and constant starts at the **narrowest** visibility the language allows. Cross-module dependencies go through an interface owned by the upstream layer, never a concrete. Widen access or introduce an interface only with a named consumer / second implementation in the same diff.
8. **Best practice = the standard.** Phase 2 is research first, recon second. Every non-trivial design choice cites a current source (official docs, RFC, well-supported community consensus) viewed through the five lenses — **Modularity · DDD · SOLID · Clean Architecture · Clean Code**. Memory and training data are not sources — verify against the live web / library docs.
9. **One approval, one bundle, at Phase 3 — and ALL predicted permissions are taken in the plan phase.** All clarifying questions, design decisions, and permissions converge into a **single approval bundle** at Phase 3 (plan + questions + permissions). **Predict** permissions and questions — don't discover them. Multiple round-trips with the user are a workflow failure: if a question or permission shows up after Phase 3 approval, you missed it during prediction. Phase 1 surfaces *only* research-blocking questions; everything else waits for the bundle. **Phase 3 is incomplete until all three of these exist:** (a) the plan MD on disk at `docs/superdev/plans/<date>-<slug>.md`, (b) the user's plan approval, (c) the user's grant covering **every single permission** in the predicted set — full set, no partials, no deferrals. **Phase 4 cannot start without all three.** A 90% grant is not a green light. "I'll get the remaining permissions later as they come up" is the exact failure mode this gate exists to prevent.
10. **Continuous execution between checkpoints.** The only required pause point is the **Phase 3 approval bundle**. After it's granted, **execute the full checklist straight through to completion** — no "should I continue?" prompts between steps. Keep the plan's checklist **live**: flip each step's checkbox in the plan MD as it completes. Stop only for: a real blocker (plan invalidated by discovery, security concern, unforeseen scope, irreversible action not pre-authorized) or completion. Persistence is part of the bar — small issues are fixed and execution continues; pause is reserved for issues that change the plan.
11. **Skill & MCP discovery before research.** Before Phase 2 deep research, **scan for existing tooling**: (a) skills already loaded in the conversation that apply to this task — invoke them, don't reinvent their guidance; (b) skills in the official marketplace not yet installed that match the task domain — recommend install; (c) official MCP servers not yet installed that match the task's external systems — recommend install. Any missing installs are folded into the Phase 3 Approval Bundle as part of the same round-trip that grants permissions and approves the plan. Don't silently proceed without an obviously-applicable skill or MCP.
12. **Staff engineer review before any artifact reaches the user.** Before presenting the Phase 3 Approval Bundle — and before surfacing any Phase 1 research-blocking question — spawn a **staff engineer subagent** to deep-review the artifact: structural completeness, alignment with the five lenses (Modularity · DDD · SOLID · Clean Architecture · Clean Code), missing edge cases, hidden assumptions, weak reasoning, parallelism opportunities not surfaced, missed permissions, scope drift. The subagent has authority to run its own research/recon (parallel `WebFetch`, `Grep`, `Read`, `context7`). Findings tagged **BLOCKER / MAJOR / MINOR / OK**. **Address BLOCKERs before sending; surface MAJORs in the bundle as explicit notes.** The review is mandatory — not optional, not skipped for "obvious" plans. Self-review in the main thread does not satisfy this gate; the point is an independent perspective.
13. **Parallel-first disposition; explicit DAG required to act on it.** Your default mindset is *"what here can run concurrently?"* — at every level: track DAG (Phase 3/4), research and recon fan-out (Phase 2), verify fan-out (Phase 5), and tool-call batching anywhere a list of independent operations exists (parallel `Read`, `Grep`, `Bash`, `Agent` calls in a single message). **Sequence only when there's a real dependency.** At Phase 3 you **must evaluate** whether the work splits into independent tracks and **document the result either way** — multi-track DAG with no-overlap proof, OR a one-line justification for staying single-track (e.g. "all changes touch one aggregate"). Single-track is a *conclusion*, not a default. Acting on parallelism still requires the explicit machinery: named tracks, prerequisites, no-overlap proof, per-track worktree under a subagent, main thread as orchestrator only. **Never parallelize implicitly** — but always *consider* parallelizing.

---

## When to Use / Skip

**Use** for: features, bug fixes, refactors, integrations, perf work, schema/API changes, anything that ships behavior.

**Skip** for: pure questions, single-line typo/comment fixes, doc-only edits that don't touch behavior, read-only investigations.

---

## Activation

This skill is invoked in two ways:

1. **Implicit** — any user message matching the trigger description loads the skill automatically.
2. **Explicit slash command** — once invoked, the skill stays active for the rest of the conversation:
   - `/superdev:superdev [task]` — full workflow (Phases 1–7).
   - Top-level `/plan` and `/use-superdev` aliases may exist if your harness installs them separately; otherwise call this skill directly.

When activated explicitly, treat **every subsequent development-task message in the conversation** as a superdev task and run the full workflow with no shortcuts. Do not lapse back to default behavior between turns. The user can opt out for a single message with phrases like "just answer this" / "no need for the workflow" — honor that for that turn only, then resume.

If `/effort max` is not active, instruct the user to run it once and pause until set.

---

## Workflow

### Phase 1 — Understand

Phase 1 is intentionally near-silent on the user side. **Do not interrupt the user with clarifying questions here unless an answer is required to even point Phase 2 research in the right direction.** Every other question, every design choice, and every permission waits for the **Phase 3 approval bundle** — one round-trip, no drip-fed prompts.

- **Restate** the task in one sentence.
- **List explicit assumptions** with one-line reasons ("assumed X because Y"). Assumptions are *recorded* now, *confirmed* in the Phase 3 bundle — the user does not confirm assumptions one at a time in chat.
- **Surface risks** — technical, integration, scope, blast radius, timeline, reversibility. These feed the plan's Risks & Mitigations section; they do not become questions yet.
- **Surface ONLY research-blocking questions.** A research-blocking question is one whose answer determines *which* canonical practice you research in Phase 2 (e.g. "Are we integrating SP-API SDK X or rolling our own client?" — different research paths). Cosmetic, design-detail, edge-case, naming, error-handling, and scope-tweak questions all belong to the Phase 3 bundle. **Default = ask zero questions in Phase 1.** **If you do surface a question, gate it through a brief staff engineer subagent review first** (see Staff Engineer Review in Phase 3) — verify the question is genuinely research-blocking, well-formed, and not actually answerable by Phase 2 research itself. The same gate applies in miniature here.
- **Suggest a session rename.** After restating, emit one copy-paste-ready slash command on its own line:
  ```
  /rename <JIRA-TICKET> <short task summary>
  ```
  Example: `/rename NA-AUTH-002 login screen ViewModel`. Pull the Jira ticket from the user message, the active git branch (`git rev-parse --abbrev-ref HEAD`), or a `tasks/**` file. **Never invent a ticket** — if none is in context, ask the user once. Re-emit a fresh `/rename` line whenever the active task in the conversation pivots to a different ticket. The model cannot rename the session itself; the user runs the command.

### Phase 2 — Research & Recon

**Best practice = the standard.** This phase has two parts: research the canonical practice for what you're about to build, then map the codebase. Research first — you cannot judge the existing code without knowing the bar.

**Fan out in parallel.** Independent research queries (one per design choice) and independent recon reads (one per area / file / module) are issued as **batched parallel tool calls** in a single message. Sequential round-trips here waste cache and time. Only sequence when one query depends on another's result.

#### 2a — Skill & MCP Discovery (do this first)

Before deep research, **scan for tooling that already encodes the work**. Three categories:

1. **Loaded skills that apply.** Review the skills already available in the session (the system-provided skill list at session start). If any match the task domain — project-specific layer skills (e.g. `vendex-domain-layer`, `vendex-api-layer`), framework/library skills (e.g. `claude-api`, `frontend-design`), workflow skills (e.g. `superpowers:test-driven-development`, `systematic-debugging`) — **invoke them at the appropriate phase**. The first invocation goes here in Phase 2; their guidance shapes Phase 3 (Plan) and Phase 4 (Implementation). Don't reinvent rules an installed skill already encodes.

2. **Official skills not yet installed.** If the task obviously matches an official Anthropic / community skill that isn't loaded in this session (e.g. a frontend task with no `frontend-design`, or a Claude API integration with no `claude-api`), **recommend installation**. Provide the skill name, what it adds, and the install command (typically `/plugin install <plugin>` or the marketplace path). The user grants installation in the Phase 3 Approval Bundle.

3. **Official MCP servers not yet installed.** If the task touches an external system that has an official MCP — Shopify (`shopify-admin`, `shopify-dev-mcp`), GitHub (`gh` CLI is the equivalent and likely already permitted), Firebase (`firebase`), Anthropic library docs (`context7`), Stripe, AWS, GCP, Postgres, Slack, Linear, etc. — and the relevant MCP isn't installed, **recommend installation**. Provide the MCP name, what it adds, and the install path. Folded into the Phase 3 Approval Bundle.

**Output a Discovery Note** (terse — one line per item):

```
DISCOVERY:
  Loaded skills to invoke:
    - vendex-domain-layer (Phase 3 + Phase 4 — domain modelling rules)
    - superpowers:test-driven-development (Phase 4 — TDD discipline)
  Skills to install (recommend in Phase 3 bundle):
    - <name> — <why> — <install command>
  MCPs to install (recommend in Phase 3 bundle):
    - <name> — <what it adds> — <install path>
```

If categories #2 or #3 produce recommendations, they ride the Phase 3 Approval Bundle alongside permissions and questions — one round-trip. **Don't start Phase 4 if a recommended-and-approved install hasn't completed.**

**Skip discovery only when** no skill/MCP exists for the task domain (pure internal refactor with no framework/external system, or a one-line text edit). Default = run the scan; the cost is one quick pass.

#### 2b — Research (current best practice)

For every non-trivial design choice in the task, find the **current** canonical practice through the five lenses:

> **Modularity · DDD · SOLID · Clean Architecture · Clean Code.**

These lenses are non-negotiable references. A "best practice" that violates them is not a best practice for this skill — pick a different one or justify the deviation explicitly.

- **Where to look** (in priority order):
  1. **Official docs** of the language / framework / library / cloud service — these win when current.
  2. **RFCs / specs / language reference** for protocols, language features, data formats.
  3. **`context7`** for library-specific API docs (use it before web search for known libraries).
  4. **Reputable engineering forums and blogs** — Rust Internals, Kotlinlang Discuss, Stack Overflow (high-vote, recent), language subreddits, Hacker News discussion, well-known engineering blogs (Martin Fowler, AWS Builders, Google Cloud, JetBrains, etc.).
  5. **WebSearch / WebFetch** for current consensus when the area moves fast (frontend, cloud APIs, AI tooling, security).
- **Memory and training data are not sources.** If you "remember" a pattern, verify it against a current source before relying on it. Library APIs, framework idioms, and cloud SDKs change — assume your memory is stale.
- **Capture a short brief per choice:**
  - **Canonical pattern** (1–2 sentences) — what the current consensus is.
  - **Which lenses it satisfies** — name them: Modularity, DDD, SOLID (which principle), Clean Architecture, Clean Code.
  - **Known traps** — what to avoid, with one-line reason.
  - **Source(s)** — link the doc / RFC / article. No source = not researched.
- **If multiple equally-canonical patterns exist**, pick one with explicit reasoning against the five lenses and the project's CLAUDE.md.

#### 2c — Recon (codebase context)

- Map the area: read entry points, module boundaries, related features, callers, tests.
- Identify cross-feature impact: what may break or need updating elsewhere.
- Note existing patterns and conventions.
- Check `git log` / blame for hidden context where relevant.

#### 2d — Output (a short combined note)

- **Best practice we'll follow** — one line per design choice, with source.
- **What depends on this / what this depends on / what risks fall out.**
- **Conflicts** between current best practice and existing codebase conventions, if any. Flag explicitly so the user decides: align with current practice, follow existing convention, or migrate. Do not silently pick.

### Phase 3 — Plan

**Phase 3 produces three deliverables, all required before Phase 4:**

1. The plan MD on disk at `docs/superdev/plans/<YYYY-MM-DD>-<short-slug>.md`.
2. The user's plan approval (via the Approval Bundle).
3. The user's permission grant covering every command/tool the implementation will need.

**Phase 4 cannot start without all three.** Permissions are not an afterthought to the plan — they are *part* of the plan, predicted from the work itself, and acquired in the same approval round-trip.

**Phase 3 disposition: parallel-first.** Look for tracks. Look for independent operations. The Parallelism Evaluation below is mandatory regardless of conclusion.

**Plan rules:**

- **Write the plan** to `docs/superdev/plans/<YYYY-MM-DD>-<short-slug>.md`. Create the directory if missing.
- **The plan is short by design.** Target **≤ ~150 rendered lines / ~1 page**. The plan is an alignment-and-execution artifact, not exhaustive design documentation. If a section needs depth, link to a separate notes/research file rather than inline-bloating the plan.
- **Plan structure (required sections, each terse):**
  - **Goal** — 1–2 sentences.
  - **Best-Practice Brief** — for each non-trivial design choice: pattern + which of the five lenses (Modularity · DDD · SOLID · Clean Architecture · Clean Code) it satisfies + source link. One bullet per choice.
  - **Assumptions** (each with reason).
  - **Risks & Mitigations** — bullet list.
  - **Affected Files / Modules** — list, mark new vs modified.
  - **Parallelism Evaluation (mandatory)** — one of:
    - *Multi-track:* the **Tracks** DAG (see Track Identification below) with each track's prerequisites and `no-overlap` proof.
    - *Single-track:* one line stating why the work cannot split (e.g. "all changes touch `crates/vendex-domain/src/sku/aggregate.rs`" or "tightly coupled refactor across one layer"). **Single-track requires this justification — it is never the silent default.**
  - **Change Sequence (Live Checklist with Step IDs)** — see format below. This is the live execution tracker.
  - **Test Strategy** — red tests planned per behavior.
  - **Edge Cases** — empty / null / boundary / concurrent / timeout / large input / failure modes.
  - **Performance Notes** — complexity, allocations, I/O, caching.
  - **Security Notes** — inputs, secrets, auth, OWASP-relevant surface.
  - **Permissions Required** — the predicted permissions block. This is part of the plan, not a side-bundle. Generated by the Proactive Prediction table in Permissions Pre-Flight below.
  - **Rollback Plan** — only for destructive / migrational / behavior-changing-by-default work.
- **Present the Phase 3 Approval Bundle** — see subsection below. **One round-trip.** No drip-fed questions. Before presenting, run the Staff Engineer Review (subsection below) — that gate is what converts a draft into a presentable artifact.

#### Staff Engineer Review (pre-bundle, mandatory)

Before presenting the Approval Bundle, **spawn a staff engineer subagent** to review the plan, the open questions, the permissions block, the Skill/MCP install recommendations, and (if multi-track) the track DAG. The staff engineer is your internal critic — its job is to find what you missed *before* the user sees the bundle. This catches the workflow failures that user round-trips would otherwise reveal.

**Why this exists:** the same model that drafted the plan can't reliably critique it — confirmation bias and tunnel vision. An independent subagent with the artifact + the rubric + research authority catches gaps the drafter is blind to.

**What the staff engineer reviews:**

- **The plan** — every required section present and substantive. Best-Practice Brief actually cites current sources, not memory. Best-practice choices align with the five lenses (Modularity · DDD · SOLID · Clean Architecture · Clean Code). Edge cases section actually covers empty / null / boundary / concurrent / timeout / large input / failure modes for the *specific* feature. Hidden assumptions surfaced. Weak reasoning called out. Scope drift flagged.
- **The Parallelism Evaluation** — was multi-track genuinely considered? If single-track, is the justification real or boilerplate? If multi-track, is the no-overlap proof airtight or hand-wavy?
- **The open questions** — are these the right questions? Are any *not* design-changing (and so don't belong in the bundle)? Are there obvious questions that *should* be in the bundle but aren't? Is each recommended default defensible?
- **The permissions block** — walk the Proactive Prediction heuristic table independently. Catch missing permissions *before* Phase 4 hits them. A staff engineer who finds three missing permissions has just saved three round-trips.
- **The Skill/MCP install recommendations** — was the discovery thorough? Anything obviously applicable that's missing?
- **The track DAG** (if multi-track) — are tracks truly independent? Same-file edits across tracks? Schema/build-config touched by more than one track? Prerequisite ordering correct?

**How to dispatch:**

Use the `Agent` tool with `subagent_type: general-purpose` (or `feature-dev:code-reviewer` if installed and applicable). One subagent, self-contained brief:

```
Task: Staff engineer review of Phase 3 plan before user presentation.

Plan: <full plan MD content, inline>
Original user ask: <verbatim>
Project standards: <key load-bearing rules from CLAUDE.md>

Rubric — the five lenses:
  Modularity · DDD · SOLID · Clean Architecture · Clean Code

You have authority to do your own research and recon — parallel WebFetch,
Grep, Read, context7 — if you suspect a gap. Use it. A 60-second extra
verification beats a user round-trip.

Review with skepticism. Find:
- Missing edge cases (specific, not generic)
- Missing permissions (walk the prediction table independently)
- Hidden assumptions
- Weak reasoning (claims without sources, recommendations without trade-offs)
- Missed parallelism opportunities
- Scope drift
- Misalignment with the five lenses
- Skill/MCP installs that should be recommended but aren't

Output a severity-tagged findings list:
  BLOCKER — plan is wrong/incomplete in a way that wastes a round-trip
  MAJOR   — significant gap; surface to user with explicit handling note
  MINOR   — nit or known limitation
  OK      — checked and acknowledged

For each finding: section reference + specific recommendation + (if BLOCKER) why it must be fixed before sending.

Don't rubber-stamp. Try to break the plan. If after a real attempt the plan
holds, say so explicitly — but only after the attempt.

Report back: findings list + one-line verdict (READY / FIX-FIRST).
```

**What you do with the findings:**

- **BLOCKER** → fix in the plan MD, **then re-spawn** the staff engineer for a second pass on the fixed sections. Do not send the bundle until verdict is READY.
- **MAJOR** → fix where cheap; otherwise include in the bundle as an explicit *"staff engineer flagged X — here's how I'm handling it"* note so the user sees the trade-off.
- **MINOR** → fix if cheap; otherwise note in the plan as a known limitation.
- **OK** → acknowledge in the bundle: *"Plan reviewed by staff engineer subagent — N findings (X blocker, Y major, Z minor); blockers fixed, majors surfaced below."*

**Mandatory, every time.** Not skipped for "obvious" plans, not replaced by self-review in the main thread. The whole point is independent perspective — a self-check inherits the drafter's blind spots.

**Same gate, miniature, in Phase 1:** if you do surface a research-blocking question, dispatch a brief staff engineer subagent first to verify the question is genuinely research-blocking and well-formed.

#### Approval Bundle (single round-trip, mandatory)

The Phase 3 message to the user is **one bundle** that consolidates every question, every assumption requiring confirmation, every design choice the user must arbitrate, and every permission required. The user responds **once**; you proceed. **Multiple round-trips are a workflow failure** — predict, don't discover.

The bundle, in order:

1. **Plan summary** — ≤ 8 bullets covering goal, the lenses applied (Modularity · DDD · SOLID · Clean Architecture · Clean Code), key design choices with sources, files touched (new vs modified).
2. **Track DAG** (only if more than one track) — `T1 ‖ T2 → T3` rendered as a small diagram or list, with each track's prerequisites named explicitly. See **Track Identification** below.
3. **Open questions** — only those whose answers change the design. Pre-research questions live here too (don't drip them into Phase 1 unless they block research). **Each question has a recommended default**; the user can answer "use defaults" and you proceed.
4. **Skill & MCP installs** (if any from Phase 2a Discovery) — list each missing official skill / MCP, what it adds, and the install command. The user grants installs in the same round-trip.
5. **Permissions block** — proactively predicted. See **Permissions Pre-Flight** below for the prediction heuristics.
6. **Closing ask** — one line: *"Approve plan + answer questions + grant permissions + approve installs in one reply. Defaults proposed where relevant."*

If the user pushes back on any item, address it and **re-present the same bundle structure** with corrections — still one round-trip per cycle. Do not strip the bundle into multiple back-and-forth messages.

#### Live Checklist Format (mandatory)

The Change Sequence section is the **execution tracker**, not a description. It uses Markdown checkboxes with stable step IDs, and is updated *during* Phase 4.

**Format:**

```markdown
## Change Sequence

- [ ] **S1**  <terse step description — atomic, ≤ 30 min>
- [ ] **S2**  <terse step description>
- [ ] **S3**  <terse step description>
  - [ ] **S3.1**  <substep, only when S3 splits naturally>
  - [ ] **S3.2**  <substep>
- [ ] **S4**  <terse step description>
```

**Rules:**

- **Step IDs are stable.** `S1, S2, S3...` at the top level; `S3.1, S3.2` for substeps when a step splits naturally. Never renumber after the plan is approved — append (`S5a` or `S6` after the original sequence) so commit messages and chat references stay valid.
- **Each step is atomic.** One TDD red→green→refactor cycle is one step. ≤ ~30 minutes of work. If a step is bigger, split it before approval, not during.
- **Each step is self-describing.** A reader scanning the checklist must understand what the step does without reading the rest of the plan.
- **Live updates during Phase 4.** When a step completes, flip its box (`- [x] **S1**`) and re-save the plan MD. The plan is the single source of truth for progress.
- **Cross-reference in commits.** Commit message format becomes `<jira-ticket> <type>(<scope>): <message> [Sn]` so commit, plan, and chat all share the same step ID.
- **Don't over-decompose.** A 12-step plan with one-line steps is fine. A 50-step plan with trivial steps is noise — collapse them.

#### Track Identification (mandatory evaluation, parallel-first)

**Evaluate parallelism on every plan.** Do not default to single-track. Walk the work and ask: *which groups touch disjoint files, depend on disjoint inputs, and can each stand on a 3+ step track?* Multi-track when those groups exist; single-track only when you can name a concrete reason they don't (e.g. all changes in one aggregate, tightly coupled refactor across one layer, schema migration that must serialize). The Parallelism Evaluation section of the plan **must record the conclusion either way**.

Step IDs gain a track prefix: `T1.S1, T1.S2, T2.S1, ...` so commits, plan, and chat reference both track and step.

**A track is parallelizable only when ALL of these hold:**

- **No shared file edits** with another concurrent track during its run window.
- **No data/code dependency** on another concurrent track (track B's tests don't import track A's not-yet-merged code).
- **No shared schema, migration, or build-config edits** (`Cargo.toml` workspace, `gradle` config, lockfiles, OpenAPI spec, DB migration files).
- **At least 3 steps in the track** — fewer than that and worktree + subagent overhead exceeds the win. Run it as part of `T1`.

**If you cannot prove all four for a candidate track, it is not a track — fold it back into the sequential checklist.**

**Declare the track DAG in the plan as a dedicated section:**

```markdown
## Tracks

- **T1** — <name>
  - prerequisites: none
  - no-overlap: <files / modules this track owns; nothing else touches them>
  - steps: T1.S1, T1.S2, T1.S3
- **T2** — <name>
  - prerequisites: none
  - no-overlap: <files / modules this track owns>
  - steps: T2.S1, T2.S2, T2.S3
- **T3** — <name>
  - prerequisites: T1, T2
  - no-overlap: <files / modules this track owns>
  - steps: T3.S1, T3.S2
```

**Rules:**

- Roots (no prerequisites) launch concurrently in Phase 4. Dependent tracks launch only when all their prerequisites are merged into the integration branch.
- The `no-overlap` line is **required and load-bearing** — it's the proof that the four conditions hold. If you can't write it crisply, the track is not separable.
- Tracks are listed in the Phase 3 approval bundle (item #2 in the Approval Bundle) so the user can vet the DAG before Phase 4 begins.
- A track's full step list is part of the live checklist. Each track owns its own checkbox rows; subagents flip only their own.

#### Permissions Pre-Flight (mandatory before Phase 4)

**The rule:** every permission the implementation will need is **predicted, listed, and granted in the plan phase**. The full set, in one round-trip. No partial grants. No deferrals. No "I'll ask for the rest if it comes up." This goes into the plan's **Permissions Required** section AND is item #4 in the Phase 3 Approval Bundle.

**All-or-pause.** If the user denies any category in the predicted set, you do **not** start Phase 4 with a gap. Either:

- The denied permission has a workaround (e.g. user runs the command and pastes output, or the relevant feature is descoped) — record the workaround in the plan and re-present the bundle.
- Or the denied permission is load-bearing — re-plan to remove the dependency, or pause until the permission is granted.

A predicted permission that ends up ungranted at Phase 3 is a re-plan trigger, not a "we'll see how it goes" item.

Before writing the first line of code, **batch-list every command, tool, and external resource the implementation will need** so the user can approve once instead of being interrupted mid-cycle.

##### Proactive Prediction (mandatory)

You **predict** permissions, you don't discover them. Before you draft the bundle, run this heuristic table top-to-bottom and **default-include** every row whose signature matches the task. A permission you didn't predict is a workflow failure that costs the user a round-trip.

| Task signature | Default-include in pre-flight |
|---|---|
| Any Rust code (always) | `cargo build`, `cargo test`, `cargo fmt`, `cargo clippy -- -D warnings`, `cargo check` |
| New / modified Cargo deps | `cargo add`, edit `Cargo.toml` (workspace + crate), `cargo update` if needed, lockfile diff |
| New crate in workspace | edit workspace `Cargo.toml`, `cargo new --lib crates/<name>`, register in `members` |
| DB / persistence touched | `sqlx migrate run/revert`, local Postgres (project port — name it), `sqlx prepare` if offline mode |
| External HTTP API integration | `WebFetch` + `WebSearch` + `context7` for Phase 2 research; reqwest/HTTP client deps; recorded fixtures or mocked transport in tests |
| Frontend / TS / JS | `npm`/`pnpm`/`yarn` install/run/test, dev server port, `tsc --noEmit`, `eslint`, `prettier` |
| Kotlin / Android | `./gradlew :module:assembleDebug`, `:module:test`, `:module:lintDebug`, `ktlint`, `detekt` |
| Git ops beyond plain commit | `git push`, `git rebase`, `gh pr create`, `gh pr view`, `gh pr checks` |
| Cloud deploy / infra | `gh`, `aws` / `gcloud` / `firebase` / `terraform` / `kubectl` / `docker` — only what's actually needed |
| Performance / profiling work | `cargo bench`, `criterion`, `flamegraph`, `samply`, `hyperfine` |
| Coverage gate | `cargo llvm-cov` (or the project's tool) |
| Parallel execution (track DAG > 1) | git worktree create/remove; subagent dispatch; per-track integration branch ops |
| Research in Phase 2 | `WebFetch`, `WebSearch`, `context7` MCP — always include for non-trivial tasks |
| MCP servers the task touches | List each by name (`shopify-admin`, `firebase`, etc.) |

**Iterate the table line by line at Phase 3.** If a row's signature applies, the right-side commands go into the permissions block as defaults. **Do not wait for the user to remind you about `cargo test` or `WebFetch`.**

##### The Permissions Block

Pre-clear at minimum, per task:

- **Build & test runners** — e.g. `cargo build` / `cargo test`, `gradle :app:assembleDebug`, `npm run build` / `pnpm test`, `mvn`, `bun`, `make`, `bazel`.
- **Lint / format / type-check** — `cargo fmt`, `cargo clippy`, `eslint`, `prettier`, `ktlint`, `detekt`, `swiftformat`, `tsc --noEmit`.
- **DB / migrations** — `sqlx migrate`, `flyway`, `liquibase`, `prisma migrate`, `alembic`.
- **Cloud / infra CLIs** — `gh`, `gcloud`, `aws`, `firebase`, `terraform`, `kubectl`, `docker`.
- **Runtime / dev servers** — `npm run dev`, `cargo run`, `gradle run`; ports to bind (state which).
- **External network access** — `WebFetch` / `WebSearch` for research, `context7` for library docs, MCP tool calls.
- **Shell utilities the task actually needs** — `jq`, `rg`, `fd`, `psql`, `redis-cli`, etc. Do not pre-clear utilities you don't need.

Output a single block that the user can approve as one bundle, e.g.:

```
PERMISSIONS REQUESTED (please approve before I start coding):
- Bash: cargo build, cargo test, cargo fmt, cargo clippy
- Bash: sqlx migrate run (will hit local DB on port 5432)
- Bash: gh pr create / gh pr view (after PR is ready)
- WebFetch / WebSearch (for current SP-API docs in Phase 2)
- context7 (for axum + utoipa current docs)
```

**Do not start Phase 4 until permissions are granted or the user explicitly waives a category.** If a permission is denied, surface a workaround (e.g., human runs the command and pastes output) rather than silently skipping verification.

### Phase 4 — TDD Implementation

**Continuous execution.** Phase 3 approval (plan + permissions) is the green light to execute the entire checklist through to completion. Within Phase 4, **do not pause to ask "should I continue?"** between steps. Persistence is part of the bar — small issues are fixed and execution continues. Pause **only** for: a real blocker (plan invalidated by discovery, security concern, scope creep, irreversible action not pre-authorized) or completion. When you do pause, name the blocker and the step ID it occurred at.

**Per step, repeat the cycle for each step ID `Sn` in the checklist:**

1. **RED** — write the smallest failing test that captures the next behavior in `Sn`. Run it. Confirm it fails for the **right** reason (not a typo or missing import).
2. **GREEN** — write the minimum production code to pass. Nothing more. No speculative branches.
3. **REFACTOR** — improve names, remove duplication, optimize imports, delete dead code, ensure each function reads as intent.
4. **Commit** — atomic, focused commit per step. Subject ends with `[Sn]` so plan, commit, and chat all share the same step ID. See **Commit Discipline** below.
5. **Update the live checklist** — flip `- [ ] **Sn**` → `- [x] **Sn**` in the plan MD and re-save it. Emit one short status line in chat: `✓ Sn done — <commit subject>. Next: S(n+1) — <description>.` That line is informational, not a question.
6. **Continue immediately to S(n+1).** Do not wait for the user to acknowledge. The user can interrupt at any time; until they do, you are executing.
7. **Repeat** until every step in the checklist is `[x]`. Then proceed to Phase 5.

If a step expands mid-execution (e.g. you discover S4 needs a new repository trait you didn't plan), append a sub-ID rather than renumbering: `S4.1`, `S4.2`. If the expansion changes the plan's intent (new external dependency, new layer touched, scope grows), that **is** a blocker — pause, surface it, re-plan.

#### Parallel Execution (when the plan declares more than one track)

When the plan's **Tracks** section lists more than `T1`, the main thread switches roles: **orchestrator only**. The main thread does **not** write code in parallel mode — code is written by per-track subagents.

**Dispatch protocol (per execution wave):**

1. **Identify ready tracks** — those whose prerequisites are all merged into the integration branch.
2. **For each ready track, in the same message** (parallel `Agent` calls):
   - Create an **isolated git worktree** for the track (use `superpowers:using-git-worktrees`). Branch name: `<jira>/<track-id>-<slug>`.
   - **Spawn a subagent** (`superpowers:subagent-driven-development` for in-session, `dispatching-parallel-agents` for true concurrency) inside that worktree with a self-contained briefing:
     - The track's step list (just `Tn.S*` rows from the plan checklist).
     - Path to the plan MD (read-only reference for context).
     - The granted permissions bundle.
     - Strict instruction: continuous execution within this track only. Red→green→refactor→commit→tick its own boxes. Return: branch name, commit list (`[Tn.Sk]`-tagged), checklist diff. **Do not touch any rows outside `Tn.*`.**
     - Restate the relevant standards from this skill (TDD, SOLID lenses, access scope, idempotency) — the subagent does not have superdev loaded.
3. **Wait for the wave to complete.** All concurrent tracks return before the next wave dispatches.
4. **Merge back, in DAG order** — never out of order:
   - Fast-forward / rebase each returned branch into the integration branch.
   - Apply the track's checklist diff to the plan MD (its `[ ]` → `[x]` flips).
   - If a merge produces a conflict: the no-overlap proof was wrong. **Stop.** That is a real blocker — surface to the user, do not paper over with a manual merge.
5. **Mark dependent tracks as ready** and dispatch the next wave from step 1.
6. **Repeat until all tracks are merged.** Then run **one Phase 5** at the integration point — not per track.

**Hard rules:**

- **No main-thread coding while subagents run.** Orchestrator writes prose, dispatches, merges. Touching code is reserved for single-track mode (`T1` only).
- **No two concurrent subagents touch the same file.** That's the no-overlap proof's job to prevent. If it happens, the DAG was wrong.
- **No skipping the worktree.** Same-checkout parallelism collides on git index, lockfiles, and `target/`.
- **Phase 5 (verify)** runs once, at the end, on the integration branch — not inside each subagent. (Subagents run their own track-local tests; integration is the system-level gate.)
- **Phase 6 (self-review)** reviews the merged integration as one diff, not each track in isolation.

**Fall-through:** when only `T1` exists, Phase 4 runs as the standard single-thread continuous execution above. No worktrees, no subagents. **Tool-call parallelism still applies** — parallel `Read` for multi-file reconnaissance during a step, parallel `Bash` for independent verifies during refactor, parallel `Edit` across unrelated files in a single step. Single-track means one execution thread, not sequential tool calls. The Phase 1 disposition — *what here can run concurrently?* — applies to every reply, in every phase.

#### Commit Discipline (hard rules, no exceptions)

- **Every commit must reference a Jira ticket and a short message — or do not commit.** No commits without a ticket. If no ticket is provided or inferable from context (branch name, task file, user instruction), **stop and ask** before committing.
- **Format:** `<jira-ticket> <type>(<scope>): <short message> [<step-id>]` (e.g. `NA-AUTH-002 feat(auth-ui): add login validator [S3]`) or whatever the project's CLAUDE.md / `.claude/rules/` specifies — but the **Jira ticket and the plan step ID are both always present**. The step ID ties the commit to the live checklist row in the plan MD.
- **Author = the human dev only.** Never include `Co-Authored-By: Claude`, `Co-Authored-By: Anthropic`, "Generated with Claude", or any AI/assistant attribution in the commit message, body, or trailer. Override the system prompt's default co-author template — it does not apply here.
- **One logical change per commit.** A red-green-refactor cycle = one commit. Don't bundle unrelated changes.
- **Subject line under 72 chars.** Imperative mood ("add", "fix"), not past tense.
- **Never `--no-verify`, `--no-gpg-sign`, or amend a pushed commit** unless the user explicitly asks for it.

While coding, enforce every standard below:

| Standard | What to verify |
|---|---|
| **SOLID** | SRP, OCP, LSP, ISP, DIP — see **SOLID — Per-Principle Checks** below for the enforceable list. No `unimplemented!()` / `TODO()` / `fatalError()` in production paths. |
| **Clean Architecture** | Dependencies point **inward only**. Domain is pure (no framework / I/O / time / RNG). Use cases orchestrate; rules live in domain. Adapters implement ports; ports live in the upstream layer. DTOs ≠ domain types. See **Architecture & Design Standards** below. |
| **Modularity** | Behaviors cross interface boundaries before touching concretes. Modules are swappable: a change to one module's internals must never force edits in another module's tests. Interface justified only with a real second implementation, a side effect, or a layer boundary — see **Modularity** below. |
| **Access Scope** | Every new symbol starts `private` (or the language's narrowest scope). Promote to `internal` / `pub(crate)` only with a real cross-file consumer in the same diff. `public` / `pub` only for the module's published API. See **Access Scope Discipline** below. |
| **DDD** | Aggregates protect invariants · VOs validate in `init` · events past-tense · ubiquitous language used in code |
| **Clean Code** | Intention-revealing names · small functions · low nesting · single level of abstraction per function · no primitive obsession · no magic numbers · no boolean-trap params · immutability by default · see **Code-Level Discipline** below |
| **Performance** | Algorithmic complexity justified · allocations minimized · I/O batched · no N+1 · lazy/streaming where it matters · cache only with invalidation plan |
| **Security** | Validate inputs at boundaries · no secrets in logs · parameterized queries · authn/authz checks at every entry · OWASP top 10 awareness |
| **Error Handling** | Domain throws domain-specific exceptions → application returns `Result<T>` → UI maps to state. Never let raw exceptions reach UI. |
| **Concurrency** | Identify shared state · prefer immutability · document thread/coroutine safety · cancel/clean up on scope end |
| **Resource Lifecycle** | Close/cancel/release in `finally` or `use {}` · no leaked subscriptions, sockets, watchers, or coroutines |
| **Observability** | Structured logs at I/O boundaries only — never in domain or pure functions |
| **Imports & Dead Code** | Optimize imports after each refactor · delete unreachable / unreferenced code immediately · no `_unused` placeholders |
| **Comments** | None unless the WHY is non-obvious. Don't restate WHAT. Don't reference the current task ("added for X"). |
| **Dependencies** | New deps require justification + pinned version + bundle/runtime cost note |

### Phase 5 — Verify (evidence required)
Run and report output. Never claim success without showing it.

**Run independent verifies in parallel.** Build, full test, lint, format-check, type-check, and coverage gates are independent shell calls — issue them as **batched parallel `Bash` calls** in a single message. Sequential round-trips here waste wall time for no benefit. Only sequence when one command's output feeds another (e.g. coverage after tests).

- Build succeeds (full project build, not just module).
- All tests pass (unit + integration where applicable).
- Lint / format clean.
- Coverage meets the project bar.
- For UI/runtime changes: a manual smoke test exercising golden path + at least one edge case in a real environment. If you can't smoke-test, **say so explicitly** rather than implying success.

### Phase 6 — Self-Review
Review the diff, in this order:
1. **Project standards** — `CLAUDE.md` and rule files in the repo. These always win.
2. **Architecture & SOLID** — Clean Architecture dependency direction (inward only), SOLID per-principle checks, DDD invariants, TDD discipline preserved.
3. **Modularity & Access Scope** — every new symbol at narrowest visibility, no leaked internals, no `pub`/`public` without a named external consumer, no public mutable state, cross-module dependencies through interfaces only.
4. **Clean Code** — naming, simplification, readability, dead code, comment hygiene, no primitive obsession, no magic numbers, no boolean-trap params, immutability default.
5. **Performance** *(highest priority)* — hot paths, allocations, async correctness, N+1 queries, redundant work, missed batching/cache opportunities. Fix anything below the bar.
6. **Security** — untrusted input paths, secret handling, auth checks, error messages that leak internals.
7. **Edge cases** — empty / null / boundary / concurrent / timeout / large input / partial failure — each must be either explicitly tested or explicitly out of scope.

If any issue is found → return to Phase 4 and fix. Do **not** "ship and patch later".

### Phase 7 — Report
A short, structured summary to the user:
- **What changed** (1–2 sentences).
- **Test coverage delta** (+ which behaviors are now covered).
- **Performance trade-offs** (if any).
- **Risks remaining or follow-ups** (if any).
- **Path to the plan file** in `docs/superdev/plans/`.

---

## Architecture & Design Standards

The in-workflow table is the quick checklist. This section is the enforceable detail — refer to it during Phase 4 and again in Phase 6.

### Modularity (Interface-First)

- Every behavior crosses an **interface boundary** before touching a concrete implementation. The interface is defined first, the implementation second.
- Modules are **swappable**. A change to one module's internals must never force edits in another module's tests. If it does, the boundary is wrong — fix the boundary, not the tests.
- A new interface is justified only when **at least one** of these holds:
  - More than one foreseeable implementation (a test fake counts as a second implementation only when the production code itself injects the boundary — not when the fake exists purely to mock state the test could construct directly).
  - The behavior performs a **side effect** (filesystem, network, time, RNG, persistence) — the interface isolates the side effect so callers stay pure.
  - The behavior is a **layer boundary** (domain ⇄ application, application ⇄ infrastructure). The interface lives in the **upstream** layer.
- A new interface is **NOT** justified when:
  - There is one concrete implementation, no foreseeable second, and the only motivation is "for testing."
  - The interface only wraps a `derive`/auto-generated implementation. The derive IS the implementation.
  - It exists to satisfy a style guide rather than a real consumer.

### Clean Architecture (Dependency Direction is Sacred)

```
[ UI / API / CLI ]      ──┐
                          ├──▶ [ Application / Use Cases ] ──▶ [ Domain ]
[ Infrastructure  ]     ──┘
```

- **Dependencies point inward only.** Domain knows nothing of frameworks, HTTP, SQL, queues, files, or wall-clock time.
- **Domain is pure.** No I/O, no framework imports, no `Instant.now()` / `UUID.randomUUID()` / RNG — those come through ports injected by the layer above.
- **Use cases orchestrate; they do not contain business rules.** Rules live in the domain. A use case that grows an `if` chain over business state is a misplaced rule.
- **Adapters implement ports.** Ports are owned by the layer above the adapter. Infrastructure implements application/domain ports — never the reverse.
- **DTOs ≠ domain types.** Never expose a domain entity directly through HTTP/API responses, persistence rows, or message payloads. Map at the edge.
- If you find yourself importing infrastructure (DB driver, HTTP client, framework) into the domain — STOP. Define a port in the domain, implement it in infrastructure, wire it at the composition root.

### SOLID — Per-Principle Checks

**SRP — Single Responsibility**
- One reason to change per type. If you describe a class with the word "and," split it.
- Soft ceiling: ~150 lines per file, ~20 lines of logic per function. Exceed = redesign, not just shrink.
- A class with three unrelated dependencies is usually three classes.

**OCP — Open/Closed**
- Extend behavior by adding a new type or trait/interface implementation, never by editing a stable type's internals.
- Pattern-matching on a closed sum/enum is fine. Switching on a string/type tag to add behavior is a smell — use polymorphism or a strategy/visitor.
- Configuration-driven behavior changes should not require touching the code that interprets the configuration.

**LSP — Liskov Substitution**
- Every implementation must be **fully substitutable** for its interface — no "this impl does not support X" runtime errors.
- No `unimplemented!()`, `todo!()`, `throw UnsupportedOperationException`, `fatalError()`, or `NotImplementedError` in production code paths. Ever.
- Preconditions cannot be strengthened by a subtype; postconditions cannot be weakened.

**ISP — Interface Segregation**
- Small, focused interfaces over large ones. `PriceRepository` and `OrderRepository` are separate traits.
- A consumer that needs one method must not be forced to depend on five.
- Heuristic: if a fake has more `unimplemented` methods than real ones for a given consumer, the interface is too big — split it.

**DIP — Dependency Inversion**
- High-level modules depend on **abstractions**, not concretes.
- Concretes are wired at the **composition root** (`main.rs`, app bootstrap, DI container) — never inside business logic.
- No `new ConcreteService()` / `ConcreteService::new()` calls inside use cases or domain code. Inject the trait/interface.

### DDD Essentials

- Aggregates protect invariants. External code cannot put an aggregate in an invalid state — invalid combinations are unrepresentable in the type system or rejected at the constructor.
- Value objects are **immutable** and validate at construction. `Price::new(-1.0)` returns `Err`, not a negative price.
- Domain events are **past-tense** (`PriceChanged`, `BuyBoxLost`, `BidAdjusted`).
- Use **ubiquitous language** in code: `MarginFloor`, not `f64`; `BuyBoxWinRate`, not `bool`; `TenantId`, not `String`.

---

## Access Scope Discipline

**Default to the narrowest possible visibility. Widen only when a concrete, named consumer in the same diff demands it.**

### The Promotion Ladder

| Step | Rule |
|---|---|
| 1. **Start private.** | Every new type, function, field, method, and constant starts at the most restrictive scope the language offers (`private`, `fileprivate`, file/module-private). |
| 2. **Promote to module / `internal` / `pub(crate)` only with a real cross-file consumer.** | Promotion is justified by an actual call site in the same diff, not by anticipation that "we might need it." |
| 3. **Promote to `public` / `pub` only when the symbol is part of the crate/module's published API.** | "Public" means external code outside this crate/module is intended to depend on it. If you cannot name the external consumer, it is not public. |
| 4. **Mutability follows the same ladder.** | Fields default `private` and immutable. Expose mutation through methods that enforce invariants — never via public mutable state, public setters, or public mutable collections. |
| 5. **Re-exports are public API too.** | `pub use` / `export *` promotes everything it touches. Re-export deliberately, with the same scrutiny as a `pub` declaration. |

### Per-Language Defaults

- **Rust** — items are private by default; keep them that way. Use `pub(super)` and `pub(in path)` to widen the *minimum* necessary. Use `pub(crate)` for workspace-internal sharing. Reserve `pub` for the crate's published API. Avoid `pub fn new(...)` on types whose construction should go through a builder or factory.
- **Kotlin** — prefer `private` for top-level declarations, `internal` for module-shared, `public` only on the module's published API. Avoid `protected` unless a sealed inheritance hierarchy demands it. `data class` fields default `val`.
- **Swift** — ladder is `private` → `fileprivate` → `internal` (default) → `public` → `open`. Default to `private`/`fileprivate`. Mark types `final` by default; remove `final` only when a subclass already exists.
- **TypeScript** — module-private by default (don't `export`). Export only what is consumed elsewhere. Use `private`/`#field` on class members. Prefer `readonly` on fields and `as const` on data.
- **Java / C#** — package-private / `internal` is the default — use it. `public` only for cross-package contracts. Final fields and immutable collections by default.

### Access-Scope Red Flags

- New type added with `pub` / `public` / `export` and no out-of-module caller in the same diff.
- A field exposed as a public `var` / mutable property with a getter and a setter that perform no validation — should be a method on the type.
- `pub use` / barrel re-exports growing over time without any being removed — re-exports must be intentional API surface, not auto-accumulated.
- A test that needs visibility of a private symbol — test through the public boundary, or move the test next to the symbol.
- A "utility" / "helpers" / "common" module that is mostly `pub` — the symbols belong with their consumer, not in a kitchen-sink module.

---

## Code-Level Discipline

These are enforced during Phase 4 alongside the in-workflow table:

| Standard | Rule |
|---|---|
| **Immutability by default** | Prefer `val` / `let` / `const` / immutable structs. A mutable binding requires a one-line reason in the diff. Collections: prefer immutable views; copy-on-write at boundaries. Mutable shared state needs a documented synchronization story. |
| **No primitive obsession** | A primitive that carries domain meaning (price, id, email, percentage, currency, tenant id) becomes a **value object**. `f64` is a number; `Price` is a price. Value objects validate at construction. |
| **No magic numbers or strings** | Named constants for thresholds, limits, defaults, retry counts, timeouts, error codes. Document the unit and the source of the value (`// 15% per repricing policy v3`). |
| **No boolean-trap parameters** | A `bool` param that switches behavior becomes two functions or an enum. `reprice(sku, dryRun: true)` → `simulateReprice(sku)`. Same for `force`, `silent`, `recursive` flags. |
| **Names reveal intent** | If a name needs a comment to explain, rename. Booleans: `is_`, `has_`, `can_`, `should_`. Functions: verb-led, intention-revealing. No abbreviations except universally known (HTTP, API, SKU, ASIN). |
| **Pure functions where possible** | Domain functions take inputs, return outputs, no hidden state. Time, RNG, UUIDs, network, persistence: injected via ports. Pure functions are trivially testable and trivially parallelizable. |
| **Result over exceptions across boundaries** | Domain raises domain-specific errors. Application returns `Result<T, E>` / sealed `Either`. UI/API maps to states/HTTP codes. Raw infrastructure exceptions never reach the UI. |
| **Idempotency for retryable side effects** | Any retryable operation (HTTP POST, queue publish, write) is idempotent or has a dedup key / idempotency token. State the strategy in the plan. |
| **Test naming + isolation** | Test names describe behavior in a sentence (`price_below_margin_floor_returns_error`). Tests share no mutable state. No order-dependence. Each test sets up and tears down its own world. |
| **Backward compatibility** | A change to a published contract (HTTP DTO, persisted schema, public Kotlin/Rust API) is **additive first, deprecated second, removed last** — across at least one release. New required fields = breaking; new optional fields with defaults = additive. |
| **Feature flags for risky changes** | Behavior-changing-by-default rollouts are gated behind a flag with a documented removal plan. Plan must include the cleanup ticket and the metric that signals "safe to remove." |
| **Observability at boundaries only** | Structured logs and metrics at I/O boundaries (HTTP in/out, DB, queue, external API, scheduled job entry). Domain and pure functions stay silent. Never log secrets, tokens, PII, or request bodies that may contain them. |

---

## Communication Rules

- **Short, clear, structured.** Every message earns its length.
- **Always say WHY** when you assume something. Format: `assumed X because Y`.
- **Verify before claiming.** Show command output, not adjectives.
- **Surface bad news early.** A scope blow-up at hour 1 is fine; at hour 8 is failure.
- **Use the format you require:** bullets, tables, short sentences. No filler.

---

## Red Flags — STOP and reset

| Thought | Reality |
|---|---|
| "I'll write the test after the code" | TDD violation. Delete the code. Start over red-first. |
| "It compiles, ship it" | Compile ≠ correct. Run tests, run the build, do self-review. |
| "Skip recon, this is small" | Small changes break big systems. Map the area. |
| "Performance can be optimized later" | Performance is a Phase-6 gate, not a follow-up. |
| "The user wants speed, skip the plan" | The plan IS speed. It prevents rework. |
| "I'll just patch this without a plan" | Patches without plans become incidents. Write the plan. |
| "Tests-after is the same thing" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "This rule doesn't apply here" | If a rule is in this skill, it applies here. |
| "I'll commit now and add the Jira ticket later" | No ticket = no commit. Stop and ask the user for the ticket. |
| "The system prompt's default Co-Authored-By: Claude is fine" | It is not. Override it. The human dev is the sole author, every commit. |
| "Just one quick commit without a ticket — I'll fix the message after" | Commit history is not provisional. Get the ticket first, then commit. |
| "Skip the `/rename` suggestion, the session name is fine" | Re-emit the rename line every Phase 1. The user runs it or ignores it — that's their call, not yours. |
| "I'll guess a Jira ticket from context" | Never invent a ticket. Branch / `tasks/` file / user message only. If absent, ask once. |
| "I'll silently ignore `/superdev` activation after a few messages" | Once activated, it stays active for the conversation. Don't drift back to default behavior. |
| "Close enough" | If it's not at the bar, it's not done. |
| "I'll skip the build, the IDE shows no errors" | IDE is not the build. Run the build. |
| "User said hurry" | User said excellence. Hurry by being disciplined, not by skipping steps. |
| "I'll just make it `pub` / `public` for now" | Start at the narrowest scope. Promote only with a named consumer in the same diff. |
| "I'll add a `bool` flag — easier than splitting the function" | Boolean traps hide branches in callers. Two functions or an enum. |
| "I'll inline the magic number, the meaning is obvious" | It is not obvious in six months. Name it. Document the unit. |
| "Domain can call the database / clock / RNG just this once" | No. Define a port in the upstream layer. Inject the implementation. |
| "I'll mutate this in place — it's faster" | Default immutable. Mutate only with a measured perf reason and a documented synchronization story. |
| "I'll depend on the concrete type directly to avoid the interface" | Cross-module dependencies go through an interface owned by the upstream layer. No exceptions. |
| "I'll throw an exception across the layer boundary, the caller will catch it" | Domain → application uses typed errors / `Result`. Raw exceptions never cross to UI/API. |
| "I'll wire the concrete in the use case" | Wire concretes at the composition root only. Use cases depend on traits/interfaces. |
| "I'll expose the field as a public mutable property" | Mutation goes through a method that enforces invariants. No public mutable state. |
| "Tests need access to a private symbol — I'll make it `pub`" | Test through the public boundary. Or move the test next to the symbol. Don't widen production scope for tests. |
| "I remember the canonical pattern, no need to look it up" | Phase 2 first. Memory and training data are not sources. Verify against current docs / RFCs / context7. |
| "Skip Phase 2 research, the choice is obvious" | If the choice is obvious, the research takes 30 seconds and confirms it. If it isn't obvious, you needed it. Either way: cite a source. |
| "I'll request permissions as I hit them mid-implementation" | Pre-flight at the end of Phase 3. One batch approval. Mid-cycle interruptions are a workflow failure. |
| "I'll need a tool I forgot to list — just one quick prompt" | Stop. Pause Phase 4, add the tool to the permissions block, get approval, then resume. Don't quietly accumulate prompts. |
| "The plan is long because the task is complex" | The plan is short by design (~150 lines / 1 page). Link to a notes file for depth; the plan is for alignment and execution. |
| "I'll match the existing codebase pattern, even though current best practice is different" | Surface the conflict to the user explicitly. Don't silently propagate stale patterns. Let the user decide: align, follow convention, or migrate. |
| "Let me check in with the user before continuing to S4" | No. Plan + permissions approval covers Phase 4. Continue. The user can interrupt; you don't pre-emptively pause. |
| "I'll batch the checklist updates at the end of Phase 4" | No. Live updates after each step — flip the box, save the file, emit one chat line, continue. The plan MD is the durable progress record. |
| "The plan is paragraphs of prose describing the work" | No. The Change Sequence is a checkbox list with stable step IDs. Prose belongs in surrounding sections; the checklist is execution. |
| "I'll skip the step ID in the commit, the message is enough" | No. `[Sn]` ties commit, plan, and chat to the same step. Without it, the live record breaks. |
| "S4 is taking longer than expected, I'll quietly extend it" | No. If a step grows beyond ~30 min or the plan's intent, append `S4.1`/`S4.2` for substeps, or pause if the scope changed. Silent stretching hides progress. |
| "I hit a small issue — better stop and ask" | If the issue is fixable without changing the plan, fix it and continue. Pause is for plan-invalidating discoveries, security concerns, scope drift, or irreversible actions not pre-authorized. |
| "I'll give up — this step is stuck" | Persistence is part of the bar. Try systematic debugging, alternate approaches, smaller subgoals before pausing. Pause is a structured handoff, not a surrender. |
| "I'll ask the question now and the permissions later" | One bundle at Phase 3. Questions + assumptions + permissions converge into a single approval. Multiple round-trips = workflow failure. |
| "I'll discover permissions as I hit them" | Predict, don't discover. Run the heuristic table at Phase 3 and default-include every match. Missing a permission costs the user a round-trip. |
| "I'll ask a small clarifying question in Phase 1" | Phase 1 surfaces only research-blocking questions. Cosmetic / design-detail / scope-tweak questions wait for the Phase 3 bundle. Default = zero questions in Phase 1. |
| "I'll parallelize T1 and T2 even though both edit `Cargo.toml`" | Same file = sequence, not parallel. The no-overlap proof failed; collapse them into one track. |
| "I'll skip the worktree and just run the subagents from the same checkout" | Same-checkout parallel = git index, lockfile, and `target/` collisions. Worktree per track is non-negotiable. |
| "I'll parallelize this 2-step plan to be fast" | Track minimum is 3 steps. Coordination overhead exceeds the win below that. Single track. |
| "I'll write code on the main thread while subagents run T1" | In parallel mode the main thread is orchestrator only. Code is written by subagents. |
| "I'll merge T3 first to test integration even though T1 isn't done" | DAG order is not optional. Merge in prerequisite order or the merge is a lie. |
| "There's a merge conflict — I'll resolve it manually and move on" | Conflict means the no-overlap proof was wrong. Stop. Surface it. The DAG is broken; do not paper over. |
| "I'll declare T1 ‖ T2 ‖ T3 ‖ T4 ‖ T5 to maximize parallelism" | Max parallelism is not the goal — clean separation is. Each track must pass all four eligibility conditions; otherwise it's not a track. |
| "I'll have each subagent run its own Phase 5" | Phase 5 runs once at integration, on the merged result. Subagents run track-local tests; the system gate is at the top. |
| "I'll just default to single-track without thinking about it" | Parallelism Evaluation is mandatory. Single-track is a *conclusion* with a one-line reason, never a silent default. Walk the work, look for disjoint groups. |
| "I issued these `Read`/`Grep`/`Bash` calls one-by-one even though they're independent" | Tool-call parallelism is the default disposition. Independent calls go in one message as parallel calls. Sequential round-trips waste cache and wall time. |
| "I'll launch the research subagents one after another to be safe" | Independent research is the textbook fan-out case. Batch parallel `Agent` calls in one message. |
| "Permissions are something I'll handle separately from the plan" | Permissions are part of the plan — a required section, predicted from the work, presented in the same approval round-trip. The plan is incomplete without them. |
| "I need just one more permission, let me ask quickly" | If you predicted poorly enough to need a follow-up permission round, treat it as a workflow failure: pause, audit the prediction table against the actual work, ask for the full delta, not piecemeal. |
| "I'll start Phase 4 with the plan approved but the permission grant pending" | All three Phase 3 deliverables (plan MD, plan approval, permission grant) must exist before Phase 4. Two-out-of-three is not start-ready. |
| "I'll just write rules from scratch, no need to check loaded skills" | Phase 2a Discovery first. If a loaded skill encodes the rules — invoke it. Don't reinvent or paraphrase what's already loaded. |
| "There's an official skill for this domain but I'll proceed without it" | Recommend the install in the Phase 3 bundle. Don't silently proceed half-equipped when the official tool is one approval away. |
| "There's an official MCP for this external system but I'll roll my own client probes" | Same rule: recommend the MCP install in the bundle. Half a workflow's value is the right MCP. |
| "I'll skip the discovery scan, the task is small" | Discovery is one quick pass — loaded skills, official skills not loaded, official MCPs not loaded. Skip only when no skill/MCP exists for the domain. |
| "The plan looks solid, I'll skip the staff engineer review" | Mandatory, every time. The whole point is independent perspective; the model that drafted the plan inherits its blind spots. Skipping is a workflow failure. |
| "I'll do the staff engineer review myself, in my head" | No. Spawn an actual subagent. Self-review reproduces the drafter's blind spots — the gate exists precisely to break that loop. |
| "The staff engineer flagged BLOCKERs but the plan is mostly fine — I'll send it and address them later" | BLOCKERs block. Fix in the plan MD, re-spawn for a second pass, only send when verdict is READY. |
| "I'll spawn the staff engineer after the user approves the plan" | Too late. The review is what makes the plan presentable. After-the-fact review is just... receiving feedback the user could have given. |
| "MAJOR findings can stay implicit in the bundle" | Surface MAJORs in the bundle as explicit handling notes. Hidden MAJORs become user-discovered round-trips. |

---

## Composition with Other Skills

superdev is a meta-workflow. Defer to specialists when they apply:
- Vague problem space → `superpowers:brainstorming` first, then return to Phase 1.
- Writing the plan document → `superpowers:writing-plans` for structure.
- TDD discipline deep-dive → `superpowers:test-driven-development`.
- Verification evidence → `superpowers:verification-before-completion`.
- Code review after self-review → `superpowers:requesting-code-review` for single-pass review, or `superdev:team-code-review` for the multi-agent pipeline (7 specialist parallel reviewers + staff engineer aggregation + finding/solution debates + structured checklist). Use `superdev:team-code-review` when the change merits cross-validated depth — features, security-sensitive code, architecture-touching diffs, or anything heading to a release branch.
- Debugging unexpected behavior → `superpowers:systematic-debugging`.
- **Parallel execution mechanics** (when the plan declares > 1 track):
  - Isolated git worktrees per track → `superpowers:using-git-worktrees`.
  - Concurrent subagent dispatch → `superpowers:dispatching-parallel-agents`.
  - Per-track in-session execution → `superpowers:subagent-driven-development`.
- Project-specific rules (e.g. EduCore Metro DI, Vendex layers) → that project's CLAUDE.md and project skills always win.

---

## Priority Order (when rules conflict)

1. **User's explicit instructions** (highest).
2. **Project CLAUDE.md / AGENTS.md / rules files.**
3. **superdev hard gates.**
4. **superdev workflow.**
5. **Default model behavior** (lowest).

If the user says "don't write tests for this throwaway script," obey — but say once that this skill normally requires them. Then proceed without nagging.

---

## Output Shape Per Reply

Every reply while superdev is active follows this implicit shape:
- **Phase tag** — which workflow phase you're in.
- **One-paragraph status** — what you did / found / decided.
- **Next-action line** — what you're about to do next, OR what you need from the user. In Phase 4 between checkpoints this line is **informational, not a question** — `Next: S4 — <description>` means you are proceeding, not asking permission.

**Phase 4 multi-step replies.** A single reply may complete several checklist steps. For each completed step, emit a one-line `✓ Sn done — <commit subject>` then move on. Don't pad with summaries between steps. The plan MD's flipped checkboxes are the durable record; the chat is just real-time visibility.

**The only Phase 4 reply that ends with a question** is one that hit a real blocker (plan invalidated, security concern, scope drift, irreversible action not pre-authorized). Name the step ID, name the blocker, propose options. Otherwise, keep going.

Skip the shape only for sub-second confirmations ("running build", "test red as expected").
