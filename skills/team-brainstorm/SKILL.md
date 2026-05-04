---
name: team-brainstorm
description: Use when designing a new feature before implementation — to gather requirements, designs, and engineering perspectives through a multi-agent pipeline. Seven phases - (1) identify work area / entry points / screens, (2) acquire designs (Figma MCP, screenshots, references), (3) gather requirements per entry point and per screen, (4) fan out 6 specialist parallel agents (Senior UI/UX, two senior engineers from the current platform, one senior engineer from the opposite platform for cross-pollination, backend engineer for response-shape check, QA engineer for test cases), (5) debate disagreements with staff-engineer adjudication, (6) staff-engineer web research for current best practices and synthesis, (7) produce a short brainstorm document with feature description, short plan, open questions, and concerns. Use before /superdev:superdev when a feature is non-trivial; the brainstorm document becomes the input to superdev's plan phase.
---

# team-brainstorm — Multi-Agent Feature Brainstorming Pipeline

Operate feature design at the highest standard. The product: a **short brainstorm document** with feature description, short plan, open questions, and concerns — produced by a team of specialist agents, debated to consensus, and validated by a staff engineer with current web research.

Single-mind brainstorming misses cross-platform considerations, edge cases, market patterns, and quietly-wrong assumptions. A team of specialist agents with a debate phase doesn't.

**Violating the letter of the rules is violating the spirit of the rules.** No exceptions, no rationalizations.

---

## Hard Gates (cannot be skipped)

1. **Effort = max.** If `/effort max` is not active, instruct the user to run it once, then pause until set.
2. **Scope is bounded.** Phase 1 must produce a concrete list of entry points, screens, modules, or APIs the feature will touch. "Brainstorm a new feature" without scope is not a valid input — clarify first.
3. **Designs acquired or explicitly waived.** Phase 2 requires either design references (Figma URL, screenshot paths, hand-drawn sketches) or an explicit "no designs available — UX will be derived from requirements alone" acknowledgment from the user. Never silently proceed without designs when the work is UI-bearing.
4. **Requirements gathered per entry point and per screen.** Phase 3 produces a Requirements Note keyed by entry point / screen, not a single global blob.
5. **All six specialist agents run in parallel.** Phase 4 is one message with six `Agent` calls. Sequential dispatch of independent agents is a workflow failure.
6. **Debate before document.** Phase 5 dispatches debates for every disagreement before the final synthesis. The staff engineer adjudicates from a position of having heard both sides.
7. **Staff engineer validates with web research.** Phase 6 isn't "summarize what the agents said" — it's "research the current canonical practice and reconcile the team's positions against it."
8. **The brainstorm document is the single authoritative output.** Conversation-only summaries are addenda; the MD file at `docs/brainstorm/<date>-<feature-slug>.md` is what the team and downstream `superdev:superdev` invocation work from.

---

## When to Use / Skip

**Use** for: new feature design, screen / flow / journey design, cross-platform feature parity work, feature redesign, anything that has multiple plausible implementation shapes and benefits from cross-disciplinary input.

**Skip** for: bug fixes, refactors with no UX surface, single-file behavior tweaks, work where the implementation is mechanical (`superdev:superdev` alone is enough).

---

## Activation

Invoke via:

- `/superdev:team-brainstorm [feature-name-or-description]` — explicit invocation.
- **Implicit triggers**: user says "brainstorm a feature", "design a new screen", "let's plan a new feature", "what's the best way to add X", "I want to add a new flow for Y".
- **Composed with `superdev:superdev`**: the brainstorm document becomes the input to superdev's Phase 1. The intended pipeline is `team-brainstorm` → `superdev:superdev` → `team-code-review`.

---

## Pipeline (seven phases)

Each phase is mandatory unless explicitly waived by the user. Each agent dispatch is a separate `Agent` tool call with `subagent_type: general-purpose` (or a more specific subagent type when one fits).

### Phase 1 — Area Identification

Bound the work and identify the platform context. **All reads in this phase go in one message** as parallel tool calls.

- **Restate the feature** in one sentence.
- **Detect the platform(s)** from project signals (parallel reads):
  - Android: `*.gradle.kts`, `build.gradle`, `*.kt`, `AndroidManifest.xml`.
  - iOS: `*.xcodeproj/`, `Package.swift`, `*.swift`, `Podfile`.
  - React Native / Flutter / Kotlin Multiplatform: framework markers in package files.
  - Web: `package.json` with React / Vue / Svelte / Angular / Next / Nuxt deps.
  - Backend: `Cargo.toml`, `pom.xml`, `requirements.txt`, server frameworks.
  - Multi-platform monorepo: detect and ask which platform(s) this feature targets.
- **Read project standards** in parallel: `CLAUDE.md`, `AGENTS.md`, design system docs, component library docs.
- **Identify the work area** — list every concrete touch point the feature requires:
  - **Entry points** (deep links, push notification taps, navigation source screens, API endpoints, scheduler triggers).
  - **Screens** (each screen the feature renders or modifies).
  - **Modules / packages** (which existing modules the work spans).
  - **External integrations** (APIs, SDKs, services).

**Output: a Scope Note** (≤ 12 bullets) — feature one-liner, platform(s), entry points, screens, modules, external integrations, anything unusual (greenfield vs. extending existing screens, design-system constraints, accessibility requirements). The Scope Note grounds every downstream agent.

### Phase 2 — Design Acquisition

Get the visual and UX assets. **Designs make the difference between a guessed UX and a designed one.**

Ask the user for one of:

- **Figma URL** (preferred). If a Figma MCP server is installed (`figma`, `figma-dev-mcp`, etc.), use it to fetch the design directly. Otherwise ask the user to share screenshots of the relevant frames.
- **Screenshot file paths** in the repo or attached.
- **Reference apps** (e.g. "we want it to feel like the order tracking flow in DoorDash" — note the reference and let the UI/UX agent investigate).
- **Hand-drawn sketches** or whiteboard photos.
- **Explicit "no designs"** acknowledgment — the UI/UX agent will derive a UX from requirements alone and flag this as a high-risk concern in the final document.

**Output: Design References** — list each design asset with its source, what screens it covers, and any annotations the user provided.

If designs are partial (some screens covered, others not), call this out explicitly so the team knows which screens are design-led vs. requirements-led.

### Phase 3 — Requirements Gathering

Walk every entry point and every screen from the Scope Note and capture **known** requirements. Pull from any spec docs the user has, from existing code patterns where the feature mirrors something the app already does, and from the user's own answers.

**Per entry point**, capture:
- What triggers it (user action, system event, deep link, push, scheduler).
- Required state to enter (auth, role, feature flag, prerequisite data).
- Source context (where the user came from).

**Per screen**, capture:
- Data displayed and where it comes from (API, local state, computed).
- User actions available and what each one does.
- Loading / empty / error / offline / large-data / permission-denied states.
- Navigation out (where each action sends the user).
- Analytics events to fire.

**Per shared concern**, capture:
- Auth / authorization rules.
- Localization needs.
- Accessibility (screen readers, dynamic type, contrast).
- Offline behavior.
- Telemetry / observability.

**Output: a Requirements Note** keyed by `[entry point]` and `[screen]`. Anything the user can't answer becomes an **Open Question** that flows to the final document.

### Phase 4 — Multi-Agent Specialist Brainstorm (six agents, one message, all parallel)

**Dispatch all six agents in a single message** as parallel `Agent` calls. Each agent gets a self-contained brief: the Scope Note, Design References, Requirements Note, its specialist rubric, and the output schema. Each agent has authority to run its own `Read` / `Grep` / `WebFetch` / `context7` calls.

**Per-agent output schema (mandatory, identical for all 6):**

```yaml
agent: <agent name>
plan_summary: <2-4 sentences on the agent's recommended approach>
key_decisions:
  - <decision> — <rationale>
clarifying_questions:
  - <question that would change the design if answered differently>
edge_cases:
  - <edge case + recommended handling>
risks:
  - <risk + severity + mitigation>
disagreement_points:
  - <where this agent expects to disagree with another agent or convention>
```

#### The Six Specialists

##### 1. Senior UI/UX Agent (app compatibility + market standards)

- **Subagent type**: `general-purpose`.
- **Rubric**:
  - **App compatibility**: read 2–3 representative existing screens to learn the app's UI patterns (typography scale, spacing, component vocabulary, motion language, navigation paradigms). New screens should feel native to the app.
  - **Market standards**: research the current canonical UX for this feature category (e.g. for a checkout flow: Stripe / Shopify / Apple Pay patterns; for messaging: WhatsApp / Slack patterns). Use `WebFetch` and look at the platform's HIG (Apple Human Interface Guidelines) or Material Design 3 docs as relevant.
  - **Accessibility, localization, dark mode** — must be considered, not deferred.
- **Goal**: a UX that's both app-native and competitive with current best-in-class apps in the category.
- **Output emphasis**: `key_decisions` for layout / interaction patterns; `clarifying_questions` for ambiguities in the designs vs. requirements; `risks` for accessibility / i18n / dark-mode concerns.

##### 2. Senior Engineer, Same Platform — Engineer A

- **Subagent type**: `general-purpose`.
- **Rubric**: read 3–5 representative files in the modules the feature touches to learn the codebase's idioms. Then draft a high-level implementation plan: what new types/components/screens to introduce, how state flows, how data is fetched, how navigation is wired, what existing code to reuse vs. write fresh.
- **Independence rule**: this agent is briefed *without* awareness of Engineer B's output — they reason independently to give two genuine perspectives.
- **Edge-case mandate**: explicit instruction to enumerate edge cases beyond what the Requirements Note already lists.
- **Output emphasis**: `plan_summary` is a short architecture sketch (data flow, layers touched, key components); `clarifying_questions` are blockers for that sketch.

##### 3. Senior Engineer, Same Platform — Engineer B

Same brief as Engineer A but **dispatched independently** (no awareness of A's output). Two heads, two perspectives — convergence in Phase 5 is the signal that the plan is solid; divergence is what the debate phase exists to reconcile.

##### 4. Senior Engineer, Opposite Platform (cross-pollination)

- **Subagent type**: `general-purpose`.
- **Rubric**: take the perspective of the opposite platform.
  - On Android → opposite is iOS.
  - On iOS → opposite is Android.
  - On web → opposite is mobile (Android or iOS, whichever the org also builds; if neither, choose the platform the user names).
  - On backend-only → opposite is the dominant client platform.
- **Goal**: cross-pollinate. Identify:
  - Patterns from the opposite platform that would *improve* the current-platform plan.
  - Cross-platform API / data shape considerations (so the feature is consistent if/when the opposite platform implements it).
  - Things the current platform should *avoid* doing that would make opposite-platform implementation painful (e.g. server-side response shapes that fit one platform's idioms only).
- **Output emphasis**: `key_decisions` on cross-platform contracts; `disagreement_points` where the opposite platform's idiom conflicts with the current platform's.

##### 5. Backend Engineer (response-shape check)

- **Subagent type**: `general-purpose`.
- **Rubric**:
  - **First**: search the backend for existing endpoints that could serve this feature. Check API docs, OpenAPI specs, route definitions.
  - **If existing endpoint covers it**: confirm the response shape, list any gaps (missing fields, wrong granularity), and verify pagination / filtering / sorting fit the screen requirements.
  - **If no existing endpoint**: propose the response shape — endpoint, method, request schema, response schema, error shape, pagination model. Cite REST / GraphQL / gRPC best practices as relevant.
- **Goal**: the frontend team starts with a concrete API contract, not a guessed one.
- **Output emphasis**: `plan_summary` is the API contract (existing or proposed); `risks` cover backward compatibility, performance (N+1, large payload), caching, rate limiting.

##### 6. QA Engineer (test cases & edge cases)

- **Subagent type**: `general-purpose`.
- **Rubric**: produce test cases per screen / per entry point.
  - **Happy path** — the golden flow.
  - **Edge cases** — empty state, error state, slow network, no network, permission denied, expired session, large data, pagination boundary, concurrent updates, deep link with stale data, backgrounding mid-flow.
  - **Cross-platform** — if the feature ships on multiple platforms, parity test cases.
  - **Accessibility** — screen reader path, keyboard navigation (web), dynamic type.
  - **Manual vs. automated** — call out which cases are unit, integration, E2E, manual exploratory.
- **Goal**: the implementation team starts with a test plan, not a coverage gap.
- **Output emphasis**: `edge_cases` is heavily populated; `risks` covers untestable scenarios or test infrastructure gaps.

#### After Phase 4

**Aggregate raw outputs** into a single working object keyed by agent. Save to a working file `/tmp/brainstorm-<id>.yaml` for downstream phases.

### Phase 5 — Debate (engineering disagreements)

**Identify points of disagreement** across the six outputs:

- Engineer A and Engineer B propose materially different plans (architecture, state management, layering).
- UI/UX recommends a pattern that Engineering says is infeasible (or vice versa).
- Backend's proposed response shape doesn't match what the frontend agents need.
- Opposite-platform engineer flags a cross-platform contract issue.
- QA flags a requirement that no engineering plan handles.

For each disagreement, dispatch a 2-agent debate **in parallel across all disagreements**:

- **Position A** = the original agent. Brief: *"On point P, your position is X. The opposing position is Y, held by <other agent>. Defend or revise. Cite codebase patterns, design references, market standards, or technical constraints. If you revise, explain why."*
- **Position B** = the opposing agent. Same brief, opposite framing.

After all debates return, the staff engineer subagent (Phase 6) **adjudicates each debate** — keep position A, keep position B, or synthesize a third. Each disagreement gets a `debate_outcome` field: `"converged on A"`, `"converged on B"`, `"synthesis: <description>"`, or `"unresolved — surfaced as open question"`.

If a disagreement is genuinely unresolvable without user input, it becomes an **Open Question** in the final document — not a silent pick.

### Phase 6 — Staff Engineer Research & Synthesis (same platform)

Spawn **one staff engineer subagent** from the **same platform as the implementation work** (Android staff for an Android feature, iOS staff for iOS, etc.). Brief:

- Full Phase 4 outputs + Phase 5 debate results.
- Authority and explicit instruction to do **web research** for current best practices: `WebFetch`, `WebSearch`, `context7` for library / SDK docs. Look for blog posts, official docs, RFCs, recent patterns from leading apps in the category.
- Adjudicate the debates from Phase 5.
- **Synthesize** the team's collective wisdom into:
  - A unified short plan (the version the implementation team will run with).
  - The final list of open questions (the things still genuinely undecided after debate).
  - The final list of concerns / risks / trade-offs.
- Validate critical assumptions against current sources — cite docs / articles / specs.

**Output**: the staff engineer's synthesis, ready for the final document.

### Phase 7 — Brainstorm Document

Write the final artifact to `docs/brainstorm/<YYYY-MM-DD>-<feature-slug>.md`. Create the directory if missing. **Short by design** — target ≤ ~200 rendered lines. The document is an alignment artifact, not a design encyclopedia.

```markdown
# Feature Brainstorm — <feature name> — <YYYY-MM-DD>

## Feature Description
<2-4 sentences: what the feature is, who it's for, what problem it solves>

## Scope
- **Platform(s):** <Android | iOS | web | backend | multi>
- **Entry points:** <list>
- **Screens:** <list>
- **Modules touched:** <list>
- **External integrations:** <list>

## Design References
- <source — what it covers — annotation>
- ...

## Short Plan
<6-12 bullets: high-level approach, key architectural decisions, the API contract,
state model, navigation model, the cross-platform contract if relevant. This is
what the implementation team will pick up and run with.>

## Per-Platform Implementation Notes
### <Current Platform>
- <key implementation decisions specific to this platform>

### <Opposite Platform> (consideration only)
- <cross-platform contract notes; what the opposite-platform team should know>

## API / Backend
- **Endpoint:** <existing or proposed>
- **Request:** <schema sketch>
- **Response:** <schema sketch>
- **Error shape:** <sketch>
- **Notes:** <pagination, caching, rate limit>

## Test Strategy Outline
- **Happy path:** <one-liner>
- **Edge cases:** <bulleted list of high-priority cases>
- **Manual vs. automated:** <split>

## Open Questions
- **OQ1:** <question> — *recommended default:* <option>
- **OQ2:** ...

## Concerns / Risks / Trade-offs
- **C1:** <concern> — *severity:* <high | medium | low> — *mitigation:* <approach>
- **C2:** ...

## Sources
- <doc / article / spec the staff engineer cited>
- ...

## Pipeline
- 6 specialists: ui-ux, eng-A (<platform>), eng-B (<platform>), eng-cross (<opposite>), backend, qa
- Debates: <N disputes → outcomes>
- Staff engineer: <platform>
```

**Hand the user**: a one-paragraph summary in chat + the file path. Do not paste the whole document into chat — point at the file.

**This document is the input to `/superdev:superdev`.** When the user is ready to implement, they invoke `superdev` and the Phase 1 of that workflow loads this MD as its grounding context.

---

## Composition with Other Skills

- **`superdev:superdev`** — `team-brainstorm` is the upfront design pass; `superdev` is the implementation. The brainstorm document is the natural input to superdev's Phase 1 understanding. **Order**: `team-brainstorm` → `superdev:superdev` → `superdev:team-code-review`.
- **`superdev:team-code-review`** — reviews the implementation that came out of `superdev:superdev`.
- **`superpowers:brainstorming`** — single-pass brainstorming. Use that for quick exploratory thinking; use `team-brainstorm` for cross-disciplinary multi-agent design.
- **Figma MCP** — if installed, use during Phase 2 to pull design frames directly. Recommend installation via the Phase 2 dialog if the user has Figma but no MCP.

---

## Communication Rules

- **Short, clear, structured** — every message earns its length.
- **Phase tag** in each reply.
- **Show the dispatch** — when fanning out 6 agents, name them in one line so the user can see what's running.
- **Don't paste agent outputs into chat** — they're large. Summarize, point at the file path.
- **Verify before claiming** — the document exists at the path, all required sections are present.

---

## Red Flags — STOP and reset

| Thought | Reality |
|---|---|
| "I'll just brainstorm this myself in one pass" | The whole point is multi-agent debate. Single-pass brainstorming reproduces single-mind blind spots. Spawn the six. |
| "There are no designs — I'll proceed silently" | Either ask for designs (Phase 2 isn't optional for UI work) or get an explicit "no designs available" acknowledgment. Silent UX-from-requirements is high-risk. |
| "I'll skip Engineer B since Engineer A's plan looks good" | The whole reason for two same-platform engineers is independent perspectives. Engineer A *always* "looks good" until B disagrees. Run both. |
| "I'll skip the opposite-platform engineer — this is platform-specific" | Cross-pollination catches future-pain decisions early. Run them. The opposite-platform engineer always finds at least one cross-platform contract issue worth knowing about. |
| "I'll dispatch the six agents one at a time so the output is cleaner" | Dispatch all six in one message as parallel `Agent` calls. Sequential is a workflow failure. |
| "The agents agreed on everything — no debate needed" | If you can't find any disagreement worth debating, look harder. Even agreed plans have edge cases worth probing. |
| "I'll skip the staff engineer's web research — the team's positions are enough" | Phase 6 isn't summarization. It's reconciliation against current canonical practice. The team can be unanimously wrong. |
| "I'll dump the full agent outputs into the document" | Document is short by design. ≤ ~200 lines. Synthesis, not transcript. |
| "I'll move forward without resolving this open question" | Open Questions go in the document explicitly with recommended defaults. Don't silently pick. |
| "I'll write the brainstorm document during Phase 4 to save time" | Phase ordering matters. Phase 5 debate and Phase 6 staff engineer change the document materially. Write in Phase 7. |
| "Close enough" | If the bar isn't met, the document isn't done. |

---

## Priority Order (when rules conflict)

1. **User's explicit instructions** (highest).
2. **Project CLAUDE.md / AGENTS.md / rules files.**
3. **team-brainstorm hard gates.**
4. **team-brainstorm pipeline.**
5. **Default model behavior** (lowest).

If the user says "skip the QA agent for this internal-tools brainstorm," obey — but say once that this skill normally requires all six. Then proceed.

---

## Output Shape Per Reply

While team-brainstorm is active:

- **Phase tag** — which phase.
- **One-paragraph status** — what just ran / what was found.
- **Next-action line** — what's about to dispatch, or the path to the final document.

The only reply that ends with a question is one that hit a real blocker (no scope to brainstorm, no designs and the user must decide whether to waive, undecidable disagreement the user must arbitrate). Otherwise, keep dispatching and reporting.
