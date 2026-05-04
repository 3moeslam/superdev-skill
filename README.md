# superdev — Claude Code plugin

Two complementary [Claude Code](https://docs.claude.com/en/docs/claude-code) skills that enforce zero-compromise engineering discipline:

- **`/superdev:superdev`** — a max-effort development workflow with mandatory plan-before-code, TDD, parallel-first execution, single-bundle approval, staff-engineer review, and continuous execution between checkpoints.
- **`/superdev:team-code-review`** — a multi-agent code-review pipeline that spawns 7 specialist parallel reviewers, aggregates findings via a staff engineer, runs debate phases on disputed findings and proposed solutions, and produces a structured findings checklist with file:line references and team-recommended solutions.

The two skills compose: `superdev:superdev` ships the work, `superdev:team-code-review` reviews it.

---

## Philosophy

> *Violating the letter of the rules is violating the spirit of the rules. No exceptions, no rationalizations.*

Both skills share a few non-negotiable principles:

- **Plan before code.** No production change without a written plan and a single approval bundle.
- **Best practice = the standard.** Every non-trivial design choice cites current sources viewed through five lenses: **Modularity · DDD · SOLID · Clean Architecture · Clean Code**.
- **Parallel-first disposition.** Independent operations fan out as batched parallel tool calls or parallel subagent dispatches. Sequence only when there's a real dependency.
- **Independent review before any artifact reaches the user.** The model that drafted the plan can't reliably critique it — spawn a staff-engineer subagent.
- **Continuous execution between checkpoints.** No "should I continue?" prompts inside an approved plan.
- **Permissions are a plan deliverable.** All predicted permissions are taken in the plan phase — full set, no partials.

---

## What's included

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
/plugin install https://github.com/3moeslam/superdev-skill
```

Claude Code clones the repo and registers the plugin. Both skills become available immediately as `/superdev:superdev` and `/superdev:team-code-review`.

### Local development

Clone the repo and point Claude Code at it:

```sh
git clone https://github.com/3moeslam/superdev-skill.git
claude --plugin-dir "$(pwd)/superdev-skill"
```

Edits to `skills/*/SKILL.md` are picked up on the next `/reload-plugins`.

---

## Usage

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
   /superdev:superdev <task>
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
│   └── plugin.json           # plugin manifest (name = "superdev")
├── skills/
│   ├── superdev/
│   │   └── SKILL.md          # /superdev:superdev
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
- A new skill in this plugin needs to compose cleanly with the two existing ones — say where it slots in.
- Bump `version` in `.claude-plugin/plugin.json` for any release-worthy change.
