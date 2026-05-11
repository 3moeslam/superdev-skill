---
name: team-feature-plan
description: Use when planning a non-trivial feature for multi-engineer parallel implementation — translates requirements into architecture, plan, and per-engineer task packets via a staff-engineer pipeline. Eight phases - (1) input + slug, (2) codebase grounding (parallel reads of layering, DI, test harness) + per-requirement validation for edge cases and bottlenecks, (3) clarifying questions before design, (4) staff-engineer architecture applying TDD red-then-green, DDD, Clean Architecture, SOLID at module/class/function, interface-first DI, (5) 3 parallel architect agents (Clean Architecture, DDD, SOLID/Testability) + senior-architect adjudicator, (6) task decomposition with foundation tasks (senior-only, runs first to avoid shared-interface conflicts) + engineer headcount, (7) senior-architect debate on the full package, (8) write artifacts to docs/<feature-slug>/: architecture.md, plan.md, tasks.md, engineer<i>-tasks.md per engineer. Output flows into superdev.
---

# team-feature-plan — Multi-Agent Feature Planning Pipeline

Operate feature planning at a staff-engineer standard. The product: a **set of planning artifacts** at `docs/<feature-slug>/` — an architecture document, an execution plan, a tasks DAG, and per-engineer task packets — produced by a staff engineer, critiqued by three specialist architect agents in parallel, debated to consensus, and validated by a senior architect adjudicator.

Single-mind planning misses cross-architectural concerns, foundational sequencing, and the parallelism that lets multiple engineers ship without colliding. A staff engineer plus an architect debate plus a final senior-architect review doesn't.

**Violating the letter of the rules is violating the spirit of the rules.** No exceptions, no rationalizations.

---

## Hard Gates (cannot be skipped)

1. **Effort = max.** If `/effort max` is not active, instruct the user to run it once, then pause until set.
2. **Requirements input is bounded.** Phase 1 must produce a concrete, restated requirements list — pulled from a brainstorm doc, a spec, a Linear/Jira ticket, or the user's own text. "Plan a new feature" without scope is not a valid input — clarify first.
3. **Codebase grounded before design.** Phase 2 must read CLAUDE.md, AGENTS.md, and any architecture / layering / DI / test-harness documentation in parallel. Designing in ignorance of the codebase's conventions is a workflow failure.
4. **Every requirement validated against the existing system.** Phase 2 maps each requirement to one of `{exists, partial, greenfield}` with the integration point named. "We'll figure it out later" is not a valid mapping.
5. **Clarifying questions surfaced BEFORE the architecture draft.** Phase 3 is the only phase where the user is asked questions; ambiguities discovered later become Open Questions in the final document, not silent picks.
6. **All three architect specialists run in parallel.** Phase 5 is one message with three `Agent` calls. Sequential dispatch of independent agents is a workflow failure.
7. **Foundation tasks identified explicitly.** Phase 6 must produce a Foundation Sprint — the senior-only tasks that establish the shared port traits, DI wiring, error hierarchy, and test harness so that parallel engineers afterward cannot collide on shared modules or interfaces. If "every task can be done in parallel from the start," you have not modeled the foundation correctly.
8. **Final senior-architect review before any artifact is written.** Phase 7 debates the staff engineer's whole package against a senior-architect challenger. The final write in Phase 8 reflects the adjudication, not the draft.
9. **The artifacts at `docs/<feature-slug>/` are the single authoritative output.** Conversation-only summaries are addenda; the four MD files are what the team and downstream `superdev:superdev` invocation work from.

---

## When to Use / Skip

**Use** for: any non-trivial feature implementation that more than one engineer will touch, any feature spanning more than one module or layer, any feature requiring a new domain concept or aggregate, any feature with a non-trivial API contract, any feature where parallelism across engineers would shorten time-to-merge.

**Skip** for: typo fixes, single-line behavior tweaks, refactors with no design surface, throwaway scripts, work where the implementation is mechanical and a single engineer can ship it inside a day.

---

## Activation

Invoke via:

- `/superdev:team-feature-plan [feature-name-or-description]` — explicit invocation.
- **Implicit triggers**: user says "plan this feature", "break this into tasks", "split this across the team", "what does the architecture look like for X", "how should we sequence the work".
- **Composed with `superdev:team-brainstorm`**: if a brainstorm document exists at `docs/brainstorm/*<feature>*.md`, the user may point at it as the requirements input. Brainstorm is *not* required — raw requirements are the supported standalone input.
- **Composed with `superdev:superdev`**: the planning artifacts are the natural input to superdev's Phase 1. Pipeline: `team-brainstorm` (optional) → `team-feature-plan` → `superdev:superdev` → `team-code-review`.

---

## Pipeline (eight phases)

Each phase is mandatory unless explicitly waived by the user. Each agent dispatch is a separate `Agent` tool call with `subagent_type: general-purpose` (or a more specific subagent type when one fits).

### Phase 1 — Input Acquisition & Feature Slug

- **Restate the feature** in one sentence.
- **Acquire the requirements input** — accept any of:
  - A brainstorm document (`docs/brainstorm/<date>-<feature>.md`).
  - A spec doc / PRD / Linear or Jira ticket — file path or pasted text.
  - The user's own restatement.
- **Slugify the feature name** for the artifact directory: lowercase, hyphenated, no spaces (e.g. `inventory-rebalance`, `oauth-google-signin`). Reuse the brainstorm slug if it exists. Verify with the user before continuing.
- **Restated requirements list** — convert the input into a numbered list of crisp, atomic requirements (R1, R2, R3, ...). Each requirement is one sentence, testable, and refers to a concrete user-visible behavior or system invariant. Compound requirements get split.

**Output: a Requirements Restatement** (the R-list) — saved in working memory; will be the spine of every downstream phase.

### Phase 2 — Codebase Grounding & Requirement Validation

**All reads in this phase go in one message** as parallel tool calls. Designing without knowing the codebase's layering, DI pattern, error model, and test harness is the most common planning failure.

**Parallel reads (one message):**

- Project standards: `CLAUDE.md`, `AGENTS.md`, root-level architecture docs, `README.md` architecture section.
- Layering / dependency rules: any `ARCHITECTURE.md`, `LAYERING.md`, hex/clean-arch docs.
- DI / IoC convention: search for the project's DI container, factory pattern, or constructor-injection style.
- Test harness: test framework, test runner, mocking convention, integration vs unit split, fixture/factory pattern.
- Error model: project's error hierarchy, result type, error-mapping convention at layer boundaries.
- 3–5 representative existing modules whose layering / style you'll mirror.

**Detect:**

- **Platform(s)** — Android / iOS / web / backend / multi.
- **Language(s) and framework(s)**.
- **Layering convention** — strict Clean Architecture? Hexagonal? Layered MVC? CQRS? Pure DDD? Document which one and what the dependency direction looks like.
- **DI mechanism** — constructor injection? Hilt? Dagger? Koin? Spring? `tower::Layer`? Manual factories? Document the team's choice; the architecture draft will use it.
- **Interface convention** — trait? abstract class? protocol? interface? Document the team's word and idiom.
- **Test convention** — TDD-aligned? test-after? property-based? snapshot? Document the project's posture.

**Per-requirement validation** — for each R in the Requirements Restatement, classify:

| Class | Meaning | What to record |
|---|---|---|
| **`exists`** | The capability is already in the codebase; the feature reuses it. | Name the module / function / endpoint. |
| **`partial`** | Some of the capability exists; gaps must be filled. | Name what exists + what gap. |
| **`greenfield`** | None of it exists; new code required. | Name the module(s) that will be new. |

**Edge cases & bottlenecks (per requirement):**

- **Edge cases**: empty state, error state, slow network, no network, permission denied, expired session, large data, pagination boundary, concurrent updates, race conditions, idempotency violation, stale cache, time-zone, i18n, accessibility, dark mode, offline.
- **Bottlenecks**: DB hot spots, N+1 queries, large payloads, lock contention, scheduler thundering herd, rate-limit boundaries, third-party SLA, cache invalidation, schema migration cost.

**Output: a Codebase Grounding Note + a Validation Table.** The grounding note is ≤ 10 bullets (platform, frameworks, layering, DI, errors, test harness, conventions). The validation table is one row per requirement: `R# | class | integration point | edge cases | bottlenecks`.

### Phase 3 — Clarifying Questions

**Surface every ambiguity now, before the architecture draft.** Don't carry "I'll decide that later" into Phase 4.

Categorize each ambiguity:

- **Blocker** — without an answer, the architecture cannot be drafted.
- **High-signal** — the answer materially changes the design; ask the user.
- **Low-signal** — log as an Open Question with a recommended default; do not pause the pipeline.

For Blocker and High-signal questions, use `AskUserQuestion` (or plain question text if no UI fits) — **bundle them, do not interrogate the user serially.** Examples of question categories:

- **Scope**: out-of-scope items, MVP cut, future-phase items.
- **Data model**: identity / authority / source-of-truth for shared data.
- **Concurrency & consistency**: strong vs eventual, transactional boundaries, ordering guarantees.
- **Failure semantics**: retry policy, idempotency keys, dead-letter behavior, partial-failure handling.
- **Observability**: metrics, logs, tracing needs.
- **Performance targets**: latency budget, throughput targets, RPO/RTO.
- **Security & privacy**: PII handling, audit trail, authz boundaries.
- **Platform constraints**: minimum OS, browser support, network model.

Wait for the user's answers to Blocker / High-signal questions before continuing. Open Questions roll into the final `plan.md`.

**Output: an Open Questions list** with recommended defaults for the low-signal ones, and the user's resolved answers for the rest.

### Phase 4 — Staff-Engineer Architecture Draft

The model itself is the staff engineer here. Produce the architecture by applying, in this order:

1. **TDD red-then-green at the spec level.** For each requirement, write the *test that doesn't yet pass* — the assertion that will fail until the feature exists. The architecture is then designed to make those tests passable. This produces the per-task TDD red list later in Phase 6.
2. **DDD modeling.**
   - Identify **bounded contexts**: which contexts the feature lives in, which boundaries it crosses.
   - Identify **aggregates**: which aggregate owns each invariant. Each aggregate has one root; mutating operations go through the root.
   - Identify **value objects**: types that validate at construction (Email, Money, Percentage, SkuCode, etc.). No primitive obsession.
   - Identify **domain events**: past-tense, immutable.
   - Establish the **ubiquitous language**: the names domain experts use are the names in code.
3. **Clean Architecture layering.**
   - Dependency direction is inward: domain ← application/use-case ← adapter/interface ← framework/infrastructure.
   - Domain has zero framework imports. Application defines port traits; infrastructure implements them.
   - DTOs at the boundary; domain types never leak outward through HTTP / persistence schemas.
   - Each new file lands in the layer that owns the responsibility — not where it's convenient.
4. **SOLID at module / class / function granularity.**
   - **SRP** at module: each new package has one reason to change. Name the reason out loud.
   - **OCP** at class: design for extension via new types implementing existing traits, not modification of existing code.
   - **LSP** at trait: every implementor must satisfy the trait's contract without surprising semantics (no `unimplemented!()`, no narrowing of preconditions).
   - **ISP** at interface: many small interfaces over one fat one. A consumer never depends on methods it doesn't call.
   - **DIP** everywhere: depend on the abstraction (trait / interface), never the concretion. Wire the concrete via DI.
5. **Interface-first + dependency injection.** Every cross-module dependency is a trait/interface. Every concrete is injected at composition root, never new-ed up inside business logic. List the **composition root**: where dependencies are wired (`main.rs`, `App.kt`, `ServiceModule`, etc.).

**For each new or substantially-modified module, produce a Module Card:**

```yaml
module: <package or path>
layer: <domain | application | infrastructure | interface | framework>
responsibility: <one sentence — the single reason this module exists>
public_interface:
  - <trait/interface/type> — <purpose>
depends_on:
  - <module/interface it consumes>
owned_invariants:
  - <invariant this module enforces>
solid_application:
  srp: <one reason to change>
  ocp: <how it extends>
  lsp: <how implementors are bound>
  isp: <how the interface is narrow>
  dip: <which abstraction it depends on>
testing_seam: <where tests substitute fakes — which port trait>
error_model: <which error type it returns / maps>
```

**Also identify**:

- **Shared types and traits** that more than one module depends on — these are the seeds of the Foundation Sprint.
- **DI wiring sketch** — composition root signature, who builds whom.
- **Migrations or schema changes** — what tables / collections / indexes / migrations are required.
- **External contracts** — API endpoints to add/change (path, method, request shape, response shape, error shape, pagination).
- **Cross-cutting concerns** — logging, metrics, tracing, auth context propagation.

**Output: the Architecture Draft** — Module Cards + DI sketch + migrations + external contracts + cross-cutting decisions. This is the input to Phase 5.

### Phase 5 — Architect Debate (3 specialists in parallel + adjudicator)

**Dispatch all three architect agents in a single message** as parallel `Agent` calls. Each agent gets a self-contained brief: the Requirements Restatement, the Codebase Grounding Note, the Validation Table, the Architecture Draft, its specialist rubric, and the output schema. Each agent has authority to run its own `Read` / `Grep` / `WebFetch` / `context7` calls.

**Per-agent output schema (mandatory, identical for all 3):**

```yaml
architect: <agent name>
summary: <2-4 sentences on the agent's overall position on the draft>
strengths:
  - <what the draft gets right, with rationale>
weaknesses:
  - <what the draft gets wrong, with rationale + suggested correction>
contract_concerns:
  - <issues with port traits, DTO shapes, or DI seams>
testability_concerns:
  - <issues with the test seam, mock-ability, integration boundary>
disagreement_points:
  - <where this architect expects to disagree with another architect>
```

#### The Three Architects

##### 1. Clean Architecture Architect

- **Subagent type**: `general-purpose`.
- **Rubric**: dependency direction (inward), framework-free domain, ports owned by the upstream layer, DTO≠domain, composition root cleanliness, layer-leak detection (SQL in domain? HTTP in domain? domain types in HTTP response?), proper use of inversion of control. Cites *Clean Architecture* (Martin), hexagonal architecture, ports-and-adapters.

##### 2. DDD Architect

- **Subagent type**: `general-purpose`.
- **Rubric**: aggregate boundaries (do they protect invariants?), value-object opportunities (any primitive obsession in the draft?), ubiquitous language in code matches the domain expert's language, domain events past-tense and immutable, no anemic domain models, repositories return aggregates not rows, transactional consistency aligned to aggregate boundaries. Cites *Domain-Driven Design* (Evans), *Implementing DDD* (Vernon).

##### 3. SOLID / Testability Architect

- **Subagent type**: `general-purpose`.
- **Rubric**: SRP at module + class + function, OCP (extension points are designed in, not retrofitted), LSP (no surprising implementors), ISP (no fat interfaces), DIP (every concrete depends on an abstraction). Plus testability: every port trait has an obvious fake, every use case can be unit-tested without infrastructure, every adapter has a contract test, DI seams allow integration tests to substitute real infra with fakes cheaply.

#### Adjudicating Senior Architect (after the three return)

Spawn **one senior-architect subagent** with the full three-agent output. Brief:

- For each weakness flagged by any architect, decide: `keep draft`, `revise as suggested`, or `synthesize a third option`. Document the choice with rationale.
- For each disagreement_point where two architects conflict, run a brief defender-vs-challenger debate (in the adjudicator's own reasoning, not a new subagent) and pick a position.
- Produce an **Updated Architecture** — the same shape as the draft, with the agreed revisions applied.
- Flag anything genuinely undecidable as an **Open Question** with the user's input required.

**Output: the Updated Architecture** + a short Debate Log (one line per resolved weakness or disagreement).

### Phase 6 — Task Decomposition & Parallelism Plan

Break the Updated Architecture into atomic tasks. The decomposition is a **two-layer DAG**:

#### Layer 1 — Foundation Sprint (senior-only, sequential)

The Foundation Sprint exists so that the parallel engineers in Layer 2 cannot collide on shared interfaces, modules, or wiring. The senior runs this first; nothing parallel starts until it lands.

**Required Foundation tasks (minimum set — add more as the architecture demands):**

- **F-skeleton** — create the new package/module skeletons with empty files matching the architecture. Engineers will fill them in.
- **F-traits** — define every port trait / interface that more than one engineer will consume or implement. Empty bodies are fine; the *signatures* are what unblocks parallel work.
- **F-types** — define shared value objects, DTOs, error types, and domain events. These are the lingua franca.
- **F-di** — define the DI / composition-root wiring shape with stub bindings. Engineers wire their concrete into the existing slot rather than inventing a new one.
- **F-errors** — define the error hierarchy and error-mapping convention at layer boundaries. Engineers throw / return the right error type from the start.
- **F-test-harness** — define the test harness for the new module: fakes for each port trait, factory functions for value objects, common test fixtures.
- **F-ci** — wire the new packages into the build / lint / test commands so CI is green before engineers start.

Each Foundation task is owned by **the senior engineer**. They run sequentially or in batches the senior controls — they're not parallel-claimable.

#### Layer 2 — Parallel Frontiers (engineer-claimable)

After Layer 1 lands, the remaining work is the **Parallel Frontiers** — tasks that any engineer can pick up without conflicting with another engineer.

**Per-task schema (mandatory):**

```yaml
id: T<n>             # global, never reused
title: <one sentence>
layer: <foundation | parallel>
owner: <senior | engineer-N>      # for foundation: senior; for parallel: assigned in Phase 6.5
depends_on: [<task ids>]
unblocks: [<task ids>]
modules_owned: [<paths/packages this task creates or substantially modifies>]
interfaces_owned: [<traits/types this task defines>]
interfaces_consumed: [<traits/types this task uses>]
acceptance_criteria:
  - <bullet — observable behavior or invariant>
tdd_red_list:
  - <failing test name>: <what it asserts>
estimated_effort: <S | M | L>
notes: <anything unusual>
```

**Build the DAG, then partition Layer 2 into engineer-claimable bundles:**

- **Conflict rule**: two tasks owned by *different* engineers must not write to the same module / file / type. If two tasks overlap, either merge them into one task assigned to one engineer, or split the module ownership earlier in F-skeleton.
- **Independence frontier**: list, for each "level" of the DAG (everything whose dependencies are met at that point), how many tasks could run in parallel. The maximum width of the frontier is the **maximum useful engineer count**.
- **Recommended engineer count**: usually `min(max_frontier_width, sensible_team_size)`. Cite the trade-off (more engineers ⇒ more coordination cost; fewer engineers ⇒ longer wall time).

#### Phase 6.5 — Engineer Assignment

Assign each Parallel Frontier task to a specific engineer slot (`engineer-1`, `engineer-2`, …). Balance load. Avoid cross-engineer module ownership. Where the DAG narrows mid-way, plan for engineers to swap onto the critical path rather than idle.

**Output: the full Tasks DAG** (Foundation + Parallel) with engineer assignments.

### Phase 7 — Final Senior-Architect Review (debate + adjudication)

Spawn **one senior-architect subagent** with the *whole package*: Requirements Restatement, Codebase Grounding Note, Validation Table, Updated Architecture, Tasks DAG, and the per-engineer slot assignments. Brief:

- Position = **challenger**. The staff engineer's package is the **defender** (represented by the contents you've produced; the architect is critiquing it).
- **Debate prompts**:
  - "Is the architecture's dependency direction defensible? Where does it leak?"
  - "Is the Foundation Sprint sufficient to prevent cross-engineer conflicts? What's missing?"
  - "Is the parallelism plan realistic, or is the critical path under-modeled?"
  - "Does each engineer's packet have a clean ownership boundary, or are there hidden seams?"
  - "Is the test seam at the right layer? Will the TDD red list catch regressions?"
  - "What's the biggest risk the staff engineer underweighted?"
- For each challenge the architect raises, decide: `staff engineer was right`, `architect is right — revise`, or `synthesize`. Apply revisions to the package before Phase 8.

**Output: the adjudicated final package** + a Debate Log Phase 7.

### Phase 8 — Write Artifacts

Write four file types to `docs/<feature-slug>/`. Create the directory if missing.

**`docs/<feature-slug>/architecture.md`** — the architecture document.

```markdown
# Architecture — <feature name>

## Feature Summary
<2-4 sentences>

## Layering & Dependency Direction
<the project's layering, applied to this feature, with a diagram or bullet>

## Bounded Contexts
<DDD contexts the feature touches>

## Modules (Module Cards)
### <module name>
- **Layer:** <...>
- **Responsibility:** <one sentence>
- **Public interface:** <traits/types>
- **Depends on:** <...>
- **Owned invariants:** <...>
- **SOLID application:** SRP / OCP / LSP / ISP / DIP — one line each
- **Testing seam:** <which port trait>
- **Error model:** <which error type>

<repeat per module>

## Composition Root / DI Wiring
<sketch of where dependencies are wired>

## Migrations / Schema Changes
<list>

## External Contracts (API)
<endpoints, request shapes, response shapes, error shapes>

## Cross-Cutting Concerns
<logging, metrics, tracing, auth context>

## Sources & Debate Log
- Architects: clean-architecture, ddd, solid-testability — N findings adjudicated
- Senior-architect final review: M revisions applied
```

**`docs/<feature-slug>/plan.md`** — the execution plan.

```markdown
# Plan — <feature name>

## Requirements
- R1 — <restated requirement>
- R2 — ...

## Sequencing
- **Foundation Sprint (senior-only):** F-skeleton, F-traits, F-types, F-di, F-errors, F-test-harness, F-ci
- **Parallel Frontiers (engineers):** see tasks.md
- **Recommended engineer count:** N
  - *Trade-off:* <why this number>

## Validation Summary
- exists: <count>
- partial: <count>
- greenfield: <count>

## Edge Cases (high-priority, cross-cutting)
- <bullets>

## Bottlenecks & Risks
- <bullets with severity + mitigation>

## Open Questions
- **OQ1:** <question> — *recommended default:* <option>
- **OQ2:** ...

## Test Strategy
- TDD red-then-green per task — see tdd_red_list in tasks.md
- Layer-by-layer test pyramid: <unit/integration/E2E split>
- Test seam: <which port traits get fakes>

## Definition of Done
- All tasks complete with passing tests
- All Open Questions resolved or explicitly deferred
- /superdev:team-code-review run on the final branch
```

**`docs/<feature-slug>/tasks.md`** — the full DAG (every task, every engineer).

```markdown
# Tasks — <feature name>

## Foundation Sprint (senior)
### F-skeleton — create module skeletons
- **Owner:** senior
- **Depends on:** —
- **Unblocks:** F-traits, F-types
- **Modules owned:** <list of new dirs/packages>
- **Interfaces owned:** —
- **Interfaces consumed:** —
- **Acceptance criteria:** module skeletons exist and compile
- **TDD red list:** —
- **Effort:** S

<repeat per Foundation task>

## Parallel Frontiers
### T1 — <title>
- **Owner:** engineer-1
- **Depends on:** F-traits, F-types
- **Unblocks:** T7
- **Modules owned:** <paths>
- **Interfaces owned:** <traits>
- **Interfaces consumed:** <traits from Foundation>
- **Acceptance criteria:**
  - <bullet>
- **TDD red list:**
  - `test_<name>` — <assertion>
- **Effort:** M

<repeat per parallel task>

## Dependency Graph
<ASCII or bulleted swim-lanes view>
```

**`docs/<feature-slug>/engineer<i>-tasks.md`** — per-engineer packets. One file per assigned engineer slot.

```markdown
# Engineer <i> — Task Packet — <feature name>

## Your Tasks (in dependency order)
- T1 — <title>
- T7 — <title>
- T12 — <title>

## What You Consume (defined by Foundation, do not modify)
- <trait/type> — <purpose>
- <trait/type> — <purpose>

## What You Own (define / implement in your tasks)
- <trait/type> — <purpose>

## Hand-Off Contracts
- After T1 completes, T<x> (engineer-<j>) is unblocked because <reason>.
- You consume <trait> implemented by engineer-<j>'s T<y>.

## Your TDD Red List (write these tests first)
- `test_<name>` — <assertion>
- ...

## Out of Scope For You
- <thing> — owned by engineer-<j>, do not modify
- <thing> — owned by senior, do not modify
```

After writing, **verify** all files exist with the required sections, then hand the user a one-paragraph summary in chat + the directory path. **Do not paste the documents into chat** — point at the files.

**These artifacts are the input to `/superdev:superdev`.** When the user is ready to implement, they invoke `superdev` and the planning artifacts ground its Phase 1.

---

## Composition with Other Skills

- **`superdev:team-brainstorm`** — the optional upstream. If a brainstorm doc exists, accept it as input alongside or instead of raw requirements.
- **`superdev:superdev`** — the natural downstream. The planning artifacts ground superdev's Phase 1. Pipeline: `team-brainstorm` (optional) → `team-feature-plan` → `superdev:superdev` → `team-code-review`.
- **`superdev:team-code-review`** — runs after `superdev:superdev` to validate the implementation against the architecture this skill produced.
- **`superpowers:writing-plans`** — single-pass planning. Use that for quick one-engineer tasks; use `team-feature-plan` when multiple engineers and architectural rigor matter.
- **`superpowers:test-driven-development`** — the TDD discipline this skill expresses at the task level. Tasks ship with a TDD red list precisely so the implementer can follow that skill from a running start.

---

## Communication Rules

- **Short, clear, structured** — every message earns its length.
- **Phase tag** in each reply.
- **Show the dispatch** — when fanning out 3 architect agents, name them in one line so the user can see what's running.
- **Don't paste agent outputs into chat** — summarize, point at the file path.
- **Verify before claiming** — every required artifact exists, every required section is present.

---

## Red Flags — STOP and reset

| Thought | Reality |
|---|---|
| "I'll just plan this myself in one pass" | The whole point is staff-engineer draft + architect debate + senior-architect adjudication. Single-pass planning reproduces single-mind blind spots. Spawn the architects. |
| "I'll start drafting architecture without reading the codebase" | Designing in ignorance of layering / DI / error model is the most common planning failure. Phase 2 parallel reads are mandatory. |
| "Every requirement is greenfield — I don't need a validation table" | Even pure-greenfield features integrate with auth, errors, logging, persistence, observability — there is always something to map to existing. Build the table. |
| "I'll ask the clarifying questions as they come up" | Phase 3 surfaces them BEFORE the architecture draft. Late-surfaced ambiguities cause architecture rework. Ask up front. |
| "I'll dispatch the three architects one at a time so the output's cleaner" | Dispatch all three in one message as parallel `Agent` calls. Sequential is a workflow failure. |
| "Every task can be done in parallel from day one" | If you have zero Foundation tasks, you have not modeled the shared seams. Engineers will collide on port traits or DTO shapes. Add the Foundation Sprint. |
| "I'll let two engineers own the same module" | Cross-engineer module ownership creates merge conflicts and ambiguous accountability. Either split the module in F-skeleton or assign the whole module to one engineer. |
| "I'll skip the senior-architect final review — the three architects already debated" | Phase 5 debates the architecture; Phase 7 debates the whole package — including tasks, parallelism, and engineer assignments. Both are required. |
| "I'll write the documents during Phase 4 to save time" | Phase 5 and Phase 7 will revise the architecture and the tasks. Write in Phase 8. |
| "I'll dump all tasks into tasks.md and skip the per-engineer files" | The per-engineer files are how engineers start without re-reading the whole DAG. Write them. |
| "I'll move forward without resolving this Open Question" | Open Questions go in `plan.md` explicitly with recommended defaults. Don't silently pick. |
| "Close enough" | If the bar isn't met, the package isn't done. |

---

## Priority Order (when rules conflict)

1. **User's explicit instructions** (highest).
2. **Project CLAUDE.md / AGENTS.md / rules files.**
3. **team-feature-plan hard gates.**
4. **team-feature-plan pipeline.**
5. **Default model behavior** (lowest).

If the user says "skip the SOLID architect for this internal-tools plan," obey — but say once that this skill normally requires all three. Then proceed.

---

## Output Shape Per Reply

While team-feature-plan is active:

- **Phase tag** — which phase.
- **One-paragraph status** — what just ran / what was found.
- **Next-action line** — what's about to dispatch, or the path to the final artifacts.

The only reply that ends with a question is one that hit a real blocker (no requirements input, unresolved Phase 3 Blocker question, undecidable architect disagreement the user must arbitrate). Otherwise, keep dispatching and reporting.
