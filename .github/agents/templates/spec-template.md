# Spec: [Feature Name]

**Source**: [Link to research document]
**Date**: YYYY-MM-DD
**Status**: [Draft | Ready | Implemented]

---

## Summary
[2-3 sentences max: what this implements and why]

---

## Acceptance Criteria
- <Observable outcomes (tests green, endpoint/tool returns expected shape, UI renders, etc.)>
- <Include negative cases (invalid input returns X; dependency failure maps to Y)>

---

## Non-Goals
- <What this explicitly does not implement>

---

## Files

### Create
| Path | Purpose |
|------|---------|
| `src/<module>/types.<ext>` | Core interfaces / types |
| `src/<module>/adapter.<ext>` | Adapter implementation |

### Modify
| Path | Changes |
|------|---------|
| `src/<module>/index.<ext>` | Export new module entrypoint |

---

## Dependencies

- Provide dependency changes in the repository's native dependency format (don't force a specific ecosystem).
- Include:
  - runtime deps
  - dev/test deps (if applicable)
  - version constraints
  - any required toolchain/runtime version bumps

```text
# Examples (include ONLY the format that matches the repo; do not include unrelated formats)

# JavaScript/TypeScript (package.json snippet)
{
  "dependencies": {
    "<external-sdk>": "^<version>"
  },
  "devDependencies": {
    "<test-or-mock-lib>": "^<version>"
  }
}

# Python (requirements.txt)
<external-sdk>==<version>

# Go (go.mod)
require <module/path> v<version>

# Rust (Cargo.toml)
[dependencies]
<external_sdk> = "<version>"

# Java (Gradle)
implementation("<group>:<artifact>:<version>")
testImplementation("<group>:<artifact>:<version>")
```

---

## Validation Commands
```bash
# List the exact commands a coding agent should run to validate the change.
# Keep it repo-appropriate.

# examples
# yarn test
# yarn type-check
# yarn lint
# yarn build
```

---

## Interfaces

### [InterfaceName]
```text
# src/<module>/types.<ext>
# COMPLETE - copy directly

# Use the repository's primary language.
# Include complete contracts needed by consumers.
# If the language is untyped, provide an explicit contract such as:
# - JSON Schema / OpenAPI shapes
# - CLI flags and expected IO
# - data validation rules + examples
```

### External SDK Types (Reference)
```text
# From <external-sdk> - inlined for implementation reference
# DO NOT copy into the codebase; import from the real dependency.

# Include the full signatures/types your implementation will call.
```

---

## Implementation

### [Component/Class Name]

**File**: `src/<module>/<component>.<ext>`

**Pattern**: [Name the existing repo pattern this follows (e.g., "Adapter pattern", "Service + Repository", "CLI Command pattern").]

```text
# COMPLETE implementation skeleton in the repo's primary language.
# The skeleton must be copy-paste runnable at compile/type-check level (even if it throws or returns placeholders).
# Avoid vague placeholders like "do stuff"; use explicit TODOs and algorithm steps.
#
# MUST include:
# - imports (real package/module names)
# - constructor/init + dependency injection wiring (interfaces/types for deps)
# - method signatures (inputs/outputs fully typed)
# - input validation points (show exact schema/guard calls, and what error is thrown/returned)
# - error handling contract (what errors can happen, how they are wrapped/mapped, retryability)
# - step-by-step algorithm bullets INSIDE THIS CODE BLOCK (as comments near the relevant method)
#
# Guidance for "algorithm bullets":
# - Put them directly above the core method body as a numbered list in comments.
# - Use concrete operations (parse, normalize, call X, map Y, persist Z), not abstract goals.
# - Include branching/edge cases (empty results, timeouts, partial failures) as explicit steps.
# - Use explicit TODO markers like: TODO(spec): <what to implement>.
#
# Example structure (adapt to repo patterns):
# - validate input (schema.parse)
# - transform input -> request DTO
# - call dependency
# - map dependency response -> domain output
# - handle errors (wrap, annotate, rethrow/return tool error)
# - emit metrics/logs (if repo pattern requires)
```

### [Next Component]
[Same structure]

---

## UI Components (If Applicable)

### [ComponentName]

**File**: `<ui-root>/components/<ComponentName>.<ext>`

```text
# COMPLETE component structure in the repo's UI framework (if any).
# Must include:
# - props/inputs (fully typed if applicable)
# - rendering structure
# - events/actions
# - error/empty/loading states
```

---

## Client State / Data Access (If Applicable)

### [useHookName]

**File**: `<ui-root>/<state-or-data-layer>/<name>.<ext>`

```text
# COMPLETE state/data access implementation.
# If the UI layer has a preferred pattern (hooks, stores, services, queries), follow it.
```

---

## Tests

### Unit Test Pattern
```text
# tests/<module>/<component>.test.<ext>

# Use the repo's test framework.
# Include complete mocks/fakes and deterministic assertions.
# Cover: happy path, validation failure, dependency failure, edge cases.
```

### Mock Adapters
```text
# tests/<module>/mocks.<ext>

# Provide complete mocks/fakes for consumer tests.
```

---

## Integration Checklist

- [ ] Add new module/package according to repo conventions (build config, exports, registration)
- [ ] Wire the feature into its entrypoint (CLI/HTTP route/tool registry/UI router/etc.)
- [ ] Add/adjust configuration (with validation) if required
- [ ] Add tests to the repo's test runner and ensure they're discoverable
- [ ] Update any release/docs/changelog conventions used by the repo

---

## Rollout / Compatibility
- Backwards compatible: <yes/no; what breaks>
- Migration required: <none / steps>
- Feature flag: <name/none>

---

## Decisions Reference
[Bullet list of key decisions—link to research for rationale]

- Backwards compatibility / versioning strategy
- Public API boundaries (what is stable vs internal)
- Error contract and retry/backoff policy
- [Link to full research](<relative-path-or-url-to-research-doc>)

