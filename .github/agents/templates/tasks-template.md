# Tasks: <Feature Name>

**Status**: Draft | Ready | In Progress | Done
**Last Updated**: YYYY-MM-DD

**Spec Folder**: specs/NNN-<feature-slug>/

## Agent Orchestration
<For orchestrators: describe parallel workstreams and boundaries to avoid conflicts.>

### Workstreams
- **Workstream A (Core logic)**: <Owner/agent>. Touches: <paths/modules>. Avoids: <paths/modules>.
- **Workstream B (Wiring/integration)**: <Owner/agent>. Touches: <entrypoints/routes/registries>. Avoids: <core modules>.
- **Workstream C (Tests/fixtures)**: <Owner/agent>. Touches: <tests/fixtures/mocks>. Avoids: <production code>.
- **Workstream D (Docs/release)**: <Owner/agent>. Touches: <docs/changelog>. Avoids: <code changes>.

### Conflict Rules
- Only one workstream edits the same public interface surface at a time (types, manifests, exported APIs).
- If multiple workstreams must touch the same files, sequence them and add a "rebase/sync" task.
- Prefer adding new files over editing shared files when parallelizing.

### Sync Points
- After Phase 1: sync on contracts (types/schemas) before core implementation proceeds.
- After Phase 3: sync on entrypoint wiring before integration tests are finalized.
- Before Phase N: run validation commands and agree on "done" criteria.

## Acceptance Criteria
<Bullets or short list. Define "done" in observable terms (tests passing, endpoints respond, UI renders, etc.).>

## Scope
<1–6 bullets. What is explicitly in scope?>

## Non-Goals
<1–6 bullets. What is explicitly out of scope?>

## Assumptions
<Only if needed. Keep short and explicit.>

## Constraints
<Compatibility, performance, security, rollout constraints, etc.>

## Goal
<1–3 sentences: what success looks like>

## References
- Research: <link or path>
- Spec: <link or path>

## Validation Commands
<List the exact commands to run for confidence (build/typecheck/unit/integration).>

```bash
# examples (replace with repo-appropriate commands)
# yarn test
# yarn type-check
# yarn build
```

## Open Questions (if any)
- [ ] <question phrased as a task to resolve>

---

## Phase 0 — Alignment & Setup

**Overview**: <1–3 sentences>

**Parallelization**: <Parallelizable / Not parallelizable. Explain boundaries and why.>

- [ ] Define acceptance criteria
- [ ] Confirm scope boundaries (in/out)
- [ ] Link research/spec docs in this file
- [ ] Identify high-risk areas (deps, APIs, migrations)
- [ ] Run baseline validation commands (record results)

## Phase 1 — Foundations (Contracts & Scaffolding)

**Overview**: <1–3 sentences>

**Parallelization**: <Explain which other phases can run in parallel and what code/doc boundaries avoid conflicts>

- [ ] Add/confirm public interfaces and input/output shapes
- [ ] Add/confirm config keys and defaults (if needed)
- [ ] Scaffold modules/files and wire minimal exports

## Phase 2 — Core Implementation

**Overview**: <1–3 sentences>

**Parallelization**: <...>

- [ ] Implement primary happy path
- [ ] Implement validation and error mapping
- [ ] Implement edge cases (empty/invalid/partial results)
- [ ] Add observability hooks (logs/metrics/tracing) if required

## Phase 3 — Integration & Wiring

**Overview**: <1–3 sentences>

**Parallelization**: <...>

- [ ] Register feature in entrypoints (routes/tool registry/CLI/UI router)
- [ ] Ensure configuration is wired and validated

## Phase 4 — Tests & Hardening

**Overview**: <1–3 sentences>

**Parallelization**: <Often parallelizable with docs; avoid conflicts with core code changes.>

- [ ] Add unit tests for core logic
- [ ] Add integration tests for wiring/entrypoints (if applicable)
- [ ] Add mocks/fakes/fixtures for deterministic tests
- [ ] Verify validation commands are green

## Phase N — Wrap-up

**Overview**: <1–3 sentences>

**Parallelization**: <...>

- [ ] Update documentation (README/spec notes/changelog if required)
- [ ] Verify release checklist

