# superdev — Claude Code plugin

Four complementary [Claude Code](https://docs.claude.com/en/docs/claude-code) skills that enforce zero-compromise engineering discipline across the full feature lifecycle:

- **`/superdev:team-brainstorm`** — a multi-agent feature-design pipeline that gathers area / designs / requirements, then fans out 6 specialist agents (Senior UI/UX, two same-platform engineers, opposite-platform engineer, backend engineer, QA), runs a debate phase, lets a same-platform staff engineer do web research and synthesis, and produces a short brainstorm document.
- **`/superdev:team-feature-plan`** — a multi-agent feature-planning pipeline that grounds in the codebase, validates every requirement against the existing system, drafts a staff-engineer architecture (TDD + DDD + Clean Architecture + SOLID + interface-first DI), fans out 3 specialist architect agents (Clean Architecture, DDD, SOLID/Testability) plus a senior-architect adjudicator, decomposes work into a two-layer DAG (senior-only Foundation Sprint + engineer-claimable Parallel Frontiers), and produces an architecture document, an execution plan, a tasks DAG, and per-engineer task packets.
- **`/superdev:superdev`** — a max-effort development workflow with mandatory plan-before-code, TDD, parallel-first execution, single-bundle approval, staff-engineer review, and continuous execution between checkpoints.
- **`/superdev:team-code-review`** — a multi-agent code-review pipeline that spawns 7 specialist parallel reviewers, aggregates findings via a staff engineer, runs debate phases on disputed findings and proposed solutions, and produces a structured findings checklist with file:line references and team-recommended solutions.

The four skills compose end-to-end: **`team-brainstorm`** designs the feature → **`team-feature-plan`** plans the architecture and splits the work → **`superdev`** ships it → **`team-code-review`** reviews it.

---

## Philosophy

> *Violating the letter of the rules is violating the spirit of the rules. No exceptions, no rationalizations.*

All four skills share a few non-negotiable principles:

- **Plan before code.** No production change without a written plan and a single approval bundle.
- **Best practice = the standard.** Every non-trivial design choice cites current sources viewed through five lenses: **Modularity · DDD · SOLID · Clean Architecture · Clean Code**.
- **Parallel-first disposition.** Independent operations fan out as batched parallel tool calls or parallel subagent dispatches. Sequence only when there's a real dependency.
- **Independent review before any artifact reaches the user.** The model that drafted the plan can't reliably critique it — spawn a staff-engineer subagent.
- **Continuous execution between checkpoints.** No "should I continue?" prompts inside an approved plan.
- **Permissions are a plan deliverable.** All predicted permissions are taken in the plan phase — full set, no partials.

---

## What's included

### `/superdev:team-brainstorm`

A seven-phase upfront feature-design pipeline:

1. **Area Identification** — entry points, screens, modules, platform detection.
2. **Design Acquisition** — Figma (via MCP) or screenshots; explicit waiver if no designs.
3. **Requirements Gathering** — per entry point and per screen (data, actions, edge states).
4. **Specialist Brainstorm** — 6 agents in **one parallel dispatch**:
   - Senior UI/UX (app-native + market standards)
   - Senior Engineer, same platform — A
   - Senior Engineer, same platform — B *(independent perspective)*
   - Senior Engineer, opposite platform *(cross-pollination)*
   - Backend Engineer *(existing endpoint check or proposed response shape)*
   - QA Engineer *(test cases & edge cases)*
5. **Debate** — pair debates per disagreement; staff engineer adjudicates.
6. **Staff Engineer Research & Synthesis** — same-platform staff engineer with web-research authority unifies positions.
7. **Brainstorm Document** — `docs/brainstorm/<date>-<feature>.md` with feature description, scope, design references, short plan, per-platform notes, API/backend notes, test outline, open questions, concerns.

The brainstorm document is the input to the next stage (`/superdev:team-feature-plan`, or directly `/superdev:superdev` if a separate planning pass isn't needed).

### `/superdev:team-feature-plan`

An eight-phase feature-planning pipeline that turns requirements into a deployable plan with per-engineer task packets:

1. **Input Acquisition & Feature Slug** — accept a brainstorm doc, a spec / PRD / ticket, or raw requirements; produce a numbered atomic-requirements list (R1, R2, …) and slugify the feature for the artifact directory.
2. **Codebase Grounding & Requirement Validation** — parallel reads of `CLAUDE.md`, `AGENTS.md`, architecture / layering / DI / test-harness docs, plus representative existing modules. Classify every requirement as `exists | partial | greenfield` and surface edge cases + bottlenecks.
3. **Clarifying Questions** — bundle Blocker and High-signal questions to the user before any design; low-signal questions become Open Questions with recommended defaults.
4. **Staff-Engineer Architecture Draft** — TDD red-then-green at the spec level, DDD (aggregates / value objects / ubiquitous language / domain events), Clean Architecture (dependency direction inward, framework-free domain, DTO≠domain), SOLID at module / class / function, interface-first design, dependency injection at the composition root. Output is a set of Module Cards.
5. **Architect Debate** — 3 specialists in **one parallel dispatch**:
   - Clean Architecture Architect (dependency direction, layer leaks, composition root)
   - DDD Architect (aggregate boundaries, value objects, ubiquitous language, anemic-model detection)
   - SOLID / Testability Architect (SRP/OCP/LSP/ISP/DIP + test seams, fake-ability, integration boundary)
   - Plus an adjudicating Senior Architect subagent that synthesizes the three critiques into an Updated Architecture.
6. **Task Decomposition & Parallelism Plan** — two-layer DAG:
   - **Foundation Sprint (senior-only, runs first):** F-skeleton, F-traits, F-types, F-di, F-errors, F-test-harness, F-ci.
   - **Parallel Frontiers (engineer-claimable):** every task has acceptance criteria, a TDD red list, owned and consumed interfaces. Conflict rule: two tasks owned by different engineers may not write to the same module.
   - Recommended engineer headcount derived from the maximum width of the DAG frontier.
7. **Final Senior-Architect Review** — a senior-architect subagent challenges the whole package (architecture + plan + tasks + per-engineer packets); revisions applied before any artifact is written.
8. **Write Artifacts** — `docs/<feature-slug>/`:
   - `architecture.md` — layering, bounded contexts, Module Cards, DI wiring, migrations, external contracts, cross-cutting concerns.
   - `plan.md` — requirements, sequencing, validation summary, edge cases, bottlenecks, open questions, test strategy, definition of done.
   - `tasks.md` — full DAG: Foundation Sprint + Parallel Frontiers with dependencies and TDD red lists.
   - `engineer<i>-tasks.md` — one per assigned engineer slot: their tasks in dependency order, interfaces they consume vs own, hand-off contracts, their TDD red list.

The planning artifacts are the input to `/superdev:superdev`.

### `/superdev:superdev`

A meta-workflow for non-trivial development tasks. Seven phases:

| Phase | What it does |
|---|---|
| **1. Understand** | Restate, list assumptions, surface only research-blocking questions. Near-silent on the user side. |
| **2. Research & Recon** | Skill & MCP discovery → research current best practice (with sources) → codebase recon. Fan-out parallel. |
| **3. Plan** | Write short MD plan (≤ 150 lines) with parallelism evaluation, predicted permissions, live step-ID checklist. Staff-engineer review before presenting. Single approval bundle (plan + questions + permissions + installs). |
| **4. TDD Implementation** | RED → GREEN → REFACTOR → atomic commit (with `[Sn]` tag) → flip checklist box → continue. Single-track or parallel-track-DAG via worktree-isolated subagents. |
| **5. Verify** | Build, test, lint, format, coverage — independent verifies in parallel. |
| **6. Self-Review** | Architecture & SOLID, modularity & access scope, clean code, performance, security, edge cases. |
| **7. Report** | What changed, coverage delta, perf trade-offs, risks remaining, plan path. |

**Hard gates** include: effort=max, plan-first, red-test-before-green, modularity & encapsulation by default, best-practice-with-sources, single-approval-bundle with all-predicted-permissions, continuous execution, skill/MCP discovery before research, staff-engineer review before any user-facing artifact, parallel-first disposition with explicit DAG to act on it.

### `/superdev:team-code-review`

A six-phase code-review pipeline:

1. **Scope & Setup** — diff bounded, languages/frameworks/standards files identified.
2. **Specialist Review** — 7 agents in **one message**, all parallel:
   - Code Standards (team style)
   - Architecture (project rules)
   - Clean Code (Robert C. Martin's specs)
   - Simplification (delete/unify/de-abstract)
   - Market Standards (SOLID · Clean Architecture · DDD + language idioms)
   - Bug Detection
   - Security (OWASP-mapped)
3. **Staff Engineer Aggregation** — dedupe, cluster, severity-arbitrate, flag disputes.
4. **Debate (findings)** — defender + challenger per disputed finding, parallel; staff engineer adjudicates.
5. **Solution Proposal & Debate** — proposer + challenger per surviving finding, parallel; staff engineer picks team-recommended solution.
6. **Findings Checklist** — single MD artifact at `docs/code-review/<date>-<scope>.md` with `ID, Severity, File, Line, Reviewer(s), Finding, Rationale, Debate outcome, Team-recommended solution`.

**Scope syntax:** `/superdev:team-code-review [scope]` where scope is `branch | pr <n> | files <paths> | staged | commits <range>`. Defaults to `branch` (current branch vs `main`).

---

## Install

### From git (recommended)

In Claude Code:

```
/plugin marketplace add 3moeslam/superdev-skill
/plugin install superdev@superdev-skill
```

(Or the explicit URL form: `/plugin marketplace add https://github.com/3moeslam/superdev-skill.git`.)

Claude Code clones the repo, registers the marketplace, and installs the plugin. All four skills become available immediately as `/superdev:team-brainstorm`, `/superdev:team-feature-plan`, `/superdev:superdev`, and `/superdev:team-code-review`, plus the `/superdev:use-superdev` command.

**Update after the author pushes new commits:**

```
/plugin marketplace update superdev-skill
/reload-plugins
```

(Claude Code does **not** auto-detect upstream changes — run the two-line dance above.)

**Uninstall:**

```
/plugin uninstall superdev@superdev-skill
```

### Local development

Clone the repo and point Claude Code at it:

```sh
git clone https://github.com/3moeslam/superdev-skill.git
claude --plugin-dir "$(pwd)/superdev-skill"
```

Edits to `skills/*/SKILL.md` are picked up on the next `/reload-plugins`.

---

## Usage

**Brainstorm a new feature before building it:**

```
/superdev:team-brainstorm seller onboarding redesign
```

`team-brainstorm` runs Phase 1 → Phase 7 and writes a short MD at `docs/brainstorm/<date>-<feature>.md`.

**Plan the architecture and split work across engineers:**

```
/superdev:team-feature-plan seller onboarding redesign
```

`team-feature-plan` runs Phase 1 → Phase 8 and writes `architecture.md`, `plan.md`, `tasks.md`, and one `engineer<i>-tasks.md` per assigned engineer slot at `docs/<feature-slug>/`. Accepts a brainstorm doc as input or works directly from raw requirements.

**Activate `superdev` for a task:**

```
/superdev:superdev implement Amazon SP-API OAuth flow per VEN-003
```

`superdev:superdev` will then run Phase 1 → Phase 7 with a single approval pause at the Phase 3 bundle.

`/superdev:use-superdev [task]` is provided as an alias — same workflow, shorter to type when the namespace is in muscle memory.

**Run a multi-agent code review on the current branch:**

```
/superdev:team-code-review branch
```

Or on a GitHub PR:

```
/superdev:team-code-review pr 42
```

The two compose: when `superdev:superdev` finishes Phase 5, you can invoke `/superdev:team-code-review branch` for the deep multi-agent review beyond the quick Phase 6 self-review.

---

## Requirements

- **Claude Code** (CLI, IDE extension, or web app — any harness that supports the plugin system).
- **`/effort max`** is recommended before invoking `superdev:superdev` — the workflow assumes the deepest reasoning budget.
- **Git** (for repo recon and commit discipline).
- **Tools the project itself needs** — language toolchains, lint/format runners, CI tools. The `superdev:superdev` Permissions Pre-Flight predicts these from a heuristic table at Phase 3.

Optional but recommended:

- **`context7` MCP** — for current library docs during Phase 2 research.
- **GitHub CLI (`gh`)** — for PR-scoped reviews.

---

## Customization

Both skills are markdown files. Adapt them:

- **Project-specific overrides**: keep your project's `CLAUDE.md` authoritative. Each skill's `Priority Order` section explicitly defers to project rules where they conflict.
- **Language defaults**: the `Permissions Pre-Flight` heuristic table in `superdev` and the per-agent rubrics in `team-code-review` can be extended for new languages/frameworks.
- **Composition**: `superdev` references `superdev:team-code-review` and several `superpowers:*` skills. Add or remove references as your skill set evolves.

---

## How they compose

```
   /superdev:team-brainstorm <feature>
        │
        ▼
   Phases 1–3 ─── area + designs + requirements
        │
        ▼
   Phase 4 ─── 6 specialists in parallel (UI/UX, eng-A, eng-B, eng-cross, backend, QA)
        │
        ▼
   Phase 5 ─── pair-debates per disagreement
        │
        ▼
   Phase 6 ─── same-platform staff engineer + web research + synthesis
        │
        ▼
   Brainstorm Doc ─── docs/brainstorm/<date>-<feature>.md
        │
        ▼
   /superdev:team-feature-plan <feature>     (accepts brainstorm doc or raw requirements)
        │
        ▼
   Phases 1–3 ─── input + codebase grounding + per-requirement validation + clarifying questions
        │
        ▼
   Phase 4 ─── staff-engineer architecture (TDD + DDD + Clean Architecture + SOLID + interface-first DI)
        │
        ▼
   Phase 5 ─── 3 architects in parallel (Clean Arch, DDD, SOLID/Testability) + senior-architect adjudicator
        │
        ▼
   Phase 6 ─── Foundation Sprint (senior) + Parallel Frontiers + engineer headcount
        │
        ▼
   Phase 7 ─── senior-architect debate on the full package
        │
        ▼
   Planning Artifacts ─── docs/<feature-slug>/{architecture,plan,tasks,engineer<i>-tasks}.md
        │
        ▼
   /superdev:superdev <task>           (loads planning artifacts as context)
        │
        ▼
   Phase 1–2 ─── plan + research + permissions
        │
        ▼
   Phase 3 ─── staff engineer review → Approval Bundle ─── (user approves once)
        │
        ▼
   Phase 4 ─── continuous TDD execution (single track or parallel DAG)
        │
        ▼
   Phase 5 ─── parallel verify (build / test / lint / format / coverage)
        │
        ▼
   Phase 6 ─── quick self-review
        │
        ▼
   /superdev:team-code-review branch ─── 7 specialists in parallel
        │
        ▼
   Staff engineer aggregation ─── dedupe / cluster / severity-arbitrate
        │
        ▼
   Debate (findings) ─── defender + challenger per dispute
        │
        ▼
   Solution proposal + debate ─── proposer + challenger per finding
        │
        ▼
   Findings Checklist MD ─── docs/code-review/<date>-<scope>.md
```

---

## Repository layout

```
superdev-skill/
├── .claude-plugin/
│   ├── marketplace.json      # marketplace manifest (name = "superdev-skill")
│   └── plugin.json           # plugin manifest (name = "superdev")
├── skills/
│   ├── superdev/
│   │   └── SKILL.md          # /superdev:superdev
│   ├── team-brainstorm/
│   │   └── SKILL.md          # /superdev:team-brainstorm
│   ├── team-feature-plan/
│   │   └── SKILL.md          # /superdev:team-feature-plan
│   └── team-code-review/
│       └── SKILL.md          # /superdev:team-code-review
├── commands/
│   └── use-superdev.md       # /superdev:use-superdev — alias for /superdev:superdev
├── README.md
└── LICENSE
```

---

## License

MIT — see [LICENSE](./LICENSE).

---

## Contributing

PRs welcome. The bar:

- A change to a hard gate or workflow phase needs a one-paragraph rationale and at least one red-flag row covering the failure mode it prevents.
- A change to a per-agent rubric needs a concrete example finding the rubric would now catch.
- A new skill in this plugin needs to compose cleanly with the three existing ones — say where it slots in.
- Bump `version` in `.claude-plugin/plugin.json` for any release-worthy change.
