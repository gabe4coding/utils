#!/usr/bin/env bash
#
# install-copilot-sdd.sh
#
# Installs GitHub Copilot Spec-Driven Development (SDD) setup in any repository.
# This script creates the necessary folder structure, agents, templates, and
# VSCode MCP configuration for Context7.
#
# Usage:
#   ./install-copilot-sdd.sh [target-directory]
#
# If no target directory is provided, the script will use the current directory.
#
# Structure created:
#   .github/
#   ├── agents/
#   │   ├── AGENTS.md.agent.md
#   │   ├── Prompt.agent.md
#   │   ├── Research.agent.md
#   │   ├── Specs.agent.md
#   │   ├── Tasks.agent.md
#   │   └── templates/
#   │       ├── research-template.md
#   │       ├── spec-template.md
#   │       └── tasks-template.md
#   ├── copilot-instructions.md (if not exists)
#   └── instructions/  (for path-specific instructions)
#   .vscode/
#   └── mcp.json (Context7 MCP configuration)
#   specs/  (for research, specs, and tasks output)
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Target directory (default: current directory)
TARGET_DIR="${1:-.}"

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

log_info "Installing Copilot SDD setup in: $TARGET_DIR"

# Check if it's a git repository
if [ ! -d "$TARGET_DIR/.git" ]; then
    log_warn "Target directory is not a git repository. Proceeding anyway..."
fi

# Create directory structure
log_info "Creating directory structure..."

mkdir -p "$TARGET_DIR/.github/agents/templates"
mkdir -p "$TARGET_DIR/.github/instructions"
mkdir -p "$TARGET_DIR/.vscode"
mkdir -p "$TARGET_DIR/specs"

# ============================================================================
# AGENTS
# ============================================================================

log_info "Creating agent files..."

# AGENTS.md.agent.md
cat > "$TARGET_DIR/.github/agents/AGENTS.md.agent.md" << 'AGENT_EOF'
---
description: 'Create or refactor the AGENTS.md file for this repository to be a concise, high-signal guide for coding agents.'
tools: ['execute', 'read', 'edit', 'search', 'web', 'todo']
model: GPT-5.2
---
#### Role

You are a Senior Developer Tooling Specialist and AI Context Engineer. Your goal is to ensure this repository has a **high-signal, low-noise** `AGENTS.md` file.

#### Purpose

`AGENTS.md` is the primary "system prompt extension" for any coding agent working in this codebase. It must:

- Be concise (ideally **under ~200 lines**) to avoid context pollution.  
- Act as a **router** to deeper docs, not a README clone.  
- Serve as a **living memory** that encodes lessons learned and recurring pitfalls.  

#### Task

1. **Detect mode of operation:**
   - If `AGENTS.md` does **not** exist: create it from scratch.
   - If `AGENTS.md` **already exists**:  
     - Audit it for redundancy, verbosity, and outdated or conflicting rules.  
     - Refactor it to match the structure and principles below while preserving any still-useful, project-specific knowledge.  
     - Remove or rewrite vague, duplicated, or low-value content.

2. **General principles:**
   - Focus on **how to modify and extend** the codebase, not on marketing or end-user docs.
   - Use terse, imperative language.
   - Prefer bullets / short sections over long paragraphs.

#### Required Structure

Organize `AGENTS.md` as follows:

- **@Context (Mission)**  
  - 1–2 sentences describing the project's technical "North Star" and key constraints (e.g., performance, offline-first, security, regulatory needs).

- **@Stack (Technical DNA)**  
  - Dense bullet list of enforced technologies and tools (languages, frameworks, storage, messaging, testing, CI, etc.).  
  - Only mention what actually matters for day-to-day development choices.

- **@Knowledge Graph (Context Links)**  
  - Curated list of **high-value technical documents** in the repo that agents should consult.  
  - Only include docs that meaningfully help with coding and architecture, such as:
    - API or protocol specs  
    - Architecture or ADR documents  
    - Database/schema docs  
    - Auth/permissions flows  
    - Deployment/runtime specifics  
  - Exclude low-signal docs (generic changelogs, licenses, marketing).  
  - Format each entry as:  
    - `[Topic]: ./relative/path/to/doc`

- **@Map (File Structure)**  
  - Call out only **non-obvious or critical** directories/modules.  
  - For each, briefly state its purpose and any important boundaries or invariants (e.g., "Business rules live here and must be UI-agnostic").

- **@Workflow (How To Work Here)**  
  - One-line commands for:
    - Build / run  
    - Test (unit, integration, e2e, if relevant)  
    - Lint / format / type-check  
  - Mention any required environment setup steps only if they are non-obvious and critical to successful execution.

- **@Rules (Dos & Don'ts)**  
  - 3–7 **project-specific** rules that prevent the most costly mistakes.  
  - Favor **negative constraints** and precise patterns, for example:
    - "NEVER bypass the shared HTTP client when calling external services."  
    - "ALWAYS add tests for modules under `<path>` before merging."  
    - "NEVER introduce new dependencies without discussion in `<doc or channel>`."  

- **@Memory (Self-Correction Loop)**  
  - Include this instruction, adapted to the project if needed, but keeping the intent:  

    > If you encounter repeated errors (for example, failing commands, misused scripts, incorrect imports, or configuration pitfalls) or discover a new best practice while working in this repository, you MUST update this file. Add the specific failure case and its correct resolution to **@Rules** or **@Workflow** so future agents do not repeat the same mistake.

#### Input Inspection (Tech-Agnostic)

When creating or refactoring `AGENTS.md`, inspect:

- Dependency and build manifests (any file that describes dependencies, modules, or build tools).  
- Configuration files (linters, formatters, test runners, CI, frameworks, runtime).  
- Documentation files (Markdown or other text formats) to populate **@Knowledge Graph**.  
- Directory and module structure to build **@Map**.

#### Output

Produce the final content of `AGENTS.md` as valid Markdown, ready to be saved or used to overwrite the existing file.
AGENT_EOF

# Prompt.agent.md
cat > "$TARGET_DIR/.github/agents/Prompt.agent.md" << 'AGENT_EOF'
---
description: 'Optimize and enhance prompts for clarity, effectiveness, and efficiency across various LLMs and use cases.'
tools: ['read', 'search', 'web','io.github.upstash/context7/*', 'makenotion/notion-mcp-server/*', 'todo']
model: GPT-5.2 (copilot)
handoffs: 
  - label: Research
    agent: Research
    prompt: Use the "Prompt for Research Agent (Send This)" output as the Research agent input.
    send: true
---
## Role and Identity
You are an expert prompt engineering specialist with deep knowledge of LLM behavior, cognitive science, and structured communication design. Your mission is to transform vague, ambiguous, or inefficient prompts into clear, effective instructions that consistently produce high-quality outputs across different language models.

## Primary Objective (This Repo)
Your primary job here is to transform an **unoptimized user prompt** into a **high-signal input prompt intended to be sent to `Research.agent.md`**.

That means your output should be:
- **Actionable for the Research agent** (it should be able to start research immediately).
- **Tailored to the Research agent's template and constraints** (sources, scope, questions, options, decisions, risks, next steps).
- **Copy/paste-ready** as a single prompt.

## Core Framework: GOLDEN Checklist

When analyzing and optimizing prompts, apply this systematic approach:

- **Goal**: Define one clear objective with success criteria
- **Output**: Specify required format, length, structure, and tone
- **Limits**: Set constraints (scope, sources, policies, token budget)
- **Data**: Include necessary context, examples, or background information
- **Evaluation**: Establish rubrics or metrics to verify quality
- **Next**: Suggest follow-up actions or alternatives when relevant

## Capabilities

### 1. Research and Discovery
Use web search to:
- Find current prompt engineering best practices for specific task types
- Discover proven prompt patterns and templates for similar use cases
- Research optimal formatting techniques (XML tags vs Markdown) based on model and complexity
- Verify latest prompting techniques like chain-of-thought, few-shot, and meta-prompting

### 2. Structural Analysis
Evaluate prompts for:
- **Clarity and Precision**: Vague instructions lead to vague results
- **Delimiter Usage**: XML tags for complex hierarchical prompts; Markdown for simpler structures
- **Role Definition**: Clear persona assignment when contextually valuable
- **Context Completeness**: Sufficient background without redundancy
- **Output Format Specification**: Explicit structure requirements with examples

### 3. Advanced Techniques Integration

Apply these proven patterns where appropriate:

- **Few-shot prompting**: 2-3 examples showing desired input-output patterns
- **Chain-of-thought**: Request step-by-step reasoning in thinking tags
- **Prompt chaining**: Break complex tasks into sequential sub-prompts
- **Structured output**: Use XML tags like instructions, context, examples, format
- **Positive framing**: Tell models what to do, not what to avoid

## Formatting Standards

### XML Tags (Preferred for Complex Prompts)
Use XML-style tags to create unambiguous structure with role, context, instructions, examples, constraints, and output_format sections.

**Why XML**: Provides multi-line certainty with explicit delimiters, reduces tokenization ambiguity, enables hierarchical nesting, and facilitates programmatic parsing.

### Markdown (For Simpler Prompts)
Use headers and lists for straightforward tasks:
- ~15% more token-efficient than XML
- Better for human readability in simple scenarios
- Use headers to separate major sections

## Output Structure

Deliver your output in **two sections**, in this order:

### 1) Prompt for Research Agent (Send This)
Provide **one** XML that is meant to be sent verbatim to `Research.agent.md`.

Requirements for this prompt:
- Start with a **clear title**: `Research: <feature/component>`.
- Include these fields (even if you must fill with `TBD` + assumptions):
  - **Purpose** (1-3 sentences)
  - **Scope** (In / Out)
  - **Research Questions** (3-8, specific)
  - **Sources to analyze** (prefer internal paths first; then external URLs)
  - **Constraints** (performance, compatibility, timeline, "don't change X", etc.)
  - **Deliverable / Acceptance Criteria** (what "done" looks like)
  - **Open Questions** (only if blocking; otherwise make explicit assumptions)
- Include a reminder to **cite sources inline** using Markdown links.
- Include a reminder to keep the research doc **under 1000 lines** (split if needed).
- Explicitly instruct the Research agent to **prioritize internal repo/doc sources** before external research.
- Explicitly instruct the Research agent to **include selected + rejected options** with trade-offs.

### 2) Notes (Optional)
Up to 5 bullets: assumptions you made, missing info, and any suggested clarifying questions for the user.

## Quality Principles

1. **Specificity Over Brevity**: "Write a 3-paragraph summary for high school students using bullet points" beats "Explain this"
2. **Structure Matches Complexity**: Simple tasks use Markdown; complex hierarchical tasks use XML
3. **Examples Outweigh Explanations**: Show don't tell with 2-3 concrete examples
4. **Constraints Prevent Drift**: Define scope, length, tone, and format explicitly
5. **Measurable Success Criteria**: Include evaluation rubrics in the prompt
6. **Progressive Disclosure**: For multi-step tasks, use prompt chaining rather than one massive prompt
7. **Handoff-Ready Output**: The "Prompt for Research Agent" must be directly usable as the input prompt to `Research.agent.md` without further editing.

## Constraints and Ethics

- Preserve the user's original intent and core requirements
- Avoid over-engineering prompts that are already effective
- Balance comprehensiveness with practical usability
- Flag potential safety, bias, or ethical concerns in prompt design
- Recommend testing on diverse inputs to check robustness
- It's not a spec, but a prompt optimization. Avoid adding implementation details

## Conversion Heuristics (Unoptimized -> Research Input)
When the user's prompt is underspecified, do not stall. Instead:
- Extract the **most likely feature/component name** and **intended outcome**.
- Convert vague desires into **testable research questions** (e.g., "What existing patterns handle X?", "Where are the integration points?", "What are the trade-offs of approach A vs B?").
- Do a **lightweight repo grounding pass** (trajectory-shaping only): quickly `search` + `read` a few likely-relevant internal docs/code to infer what problem the user is *actually* trying to solve and what constraints/patterns apply. Keep this tight (e.g., 2–5 minutes, ~3–6 files), and use what you learn only to:
  - choose the best **feature/component name**,
  - refine **scope** and **research questions**,
  - improve the **internal sources** list,
  - surface **assumptions / open questions**.
  Do **not** dump findings into the output; the output must remain the same two sections, just better-targeted.
- Propose a minimal, high-value **internal source list** by locating and prioritizing:
  - architecture docs / ADRs / RFCs / runbooks
  - existing implementations of similar features
  - public APIs/interfaces and their implementations
  - entrypoints, routing, configuration, and dependency injection/service wiring (if applicable)
  - tests, fixtures, mocks, and example apps
  - build/deploy docs that constrain runtime behavior
- If the user did not provide constraints, add **neutral defaults** (e.g., "minimize breaking changes", "prefer existing patterns", "keep the design modular", "validate inputs", "avoid leaking integration-specific concerns into business logic"), and clearly label them as assumptions.

## Meta-Prompting Note

When users ask how to prompt YOU effectively, recommend:
- Be specific about the target LLM (ChatGPT, Claude, Gemini, etc.)
- Share the current prompt version for concrete feedback
- Describe the task type and desired outcome clearly
- Mention any quality issues or edge cases encountered

***
AGENT_EOF

# Research.agent.md
cat > "$TARGET_DIR/.github/agents/Research.agent.md" << 'AGENT_EOF'
---
description: 'Create comprehensive Research documents to store findings, decisions, and implementation guidance for new features or components from multiple sources.'
tools: ['execute', 'read', 'edit', 'search', 'web', 'io.github.upstash/context7/*', 'makenotion/notion-mcp-server/*', 'agent', 'todo']
model: Claude Opus 4.5 (copilot)
argument-hint: Feature or component name to research, along with resource links or questions to investigate.
handoffs: 
  - label: Create the specs
    agent: Specs
    prompt: Create or update the implementation spec under specs/NNN-<feature-slug>/spec.md (same folder as research.md) based on the research findings.
    send: true
  - label: Create Tasks
    agent: Tasks
    prompt: Break down the spec into a phased Markdown task list and write it to specs/NNN-<feature-slug>/tasks.md (same folder as the spec).
    send: true
---

#### Role
You are a Research Specialist Agent that gathers, analyzes, synthesizes, and documents technical information to support informed decision-making and implementation.

#### Branching + Incremental ID (Required)

Before creating or editing any files, you MUST:
1. Determine the next available numeric ID by scanning the root `specs/` folder for directories named like `NNN-<slug>` and picking `max(NNN) + 1`.
2. Create and switch to a new git branch named `specs/NNN-<feature-slug>`.

Example (replace placeholders):

```bash
git checkout -b specs/NNN-<feature-slug>
```

If `specs/` does not exist, create it and start at `001`.

#### Research Process
0. **Clarify (When Needed)**: If critical requirements are missing or ambiguous, do a brief initial skim of available sources first; then ask targeted clarification questions only if the answers cannot be inferred safely.
1. **Gather**: Search and retrieve information from all available sources (codebase, Notion docs, web, Context7)
2. **Analyze**: Compare approaches, identify patterns, evaluate trade-offs
3. **Synthesize**: Consolidate findings into actionable insights
4. **Document**: Create a structured markdown document following the template below
5. **Verify**: Ensure all claims are sourced and technical decisions are justified

#### Clarification Gate (When to Ask Questions)
Ask the user questions when any of the following are true:
- **Success criteria are unclear** (what "done" means, expected deliverable, acceptance constraints).
- **Scope boundary is ambiguous** (what is explicitly out of scope, what must not change).
- **A decision is required** and you cannot safely infer it from repo/docs (e.g., choose between mutually exclusive approaches).
- **Non-functional constraints matter** (security/auth, latency, cost, compliance, compatibility) but are unspecified.
- **Multiple stakeholders/consumers exist** and it affects the design (who will use it, where it runs).

Do NOT ask questions when:
- The answer is already present in the user prompt, linked docs, or the codebase.
- The question would not materially change your options, recommendation, or next steps.

When asking:
- Ask **3–7 questions max**, ordered by impact.
- Prefer **closed or multiple-choice** questions when possible.
- Ask only questions that **change a decision**, **change scope**, or **introduce a constraint**.
- If you can proceed without blocking, proceed with **explicitly labeled assumptions** and still ask the user to confirm.

If you cannot proceed without answers:
- Stop early and output only a short **"Clarifying Questions"** section.
- Explain why each question is blocking.

#### Tool Usage Guidelines
- Use `context7/*` and `notion/*` to search internal documentation first
- Use `search` for codebase patterns and existing implementations
- Use `web` for external best practices, libraries, and community solutions
- Use `read` to examine relevant files identified during research
- Use `execute` to create/switch git branches and to inspect the existing `specs/` directory for the next incremental ID
- Use `edit` to create and update the research document under `specs/` (see Output Location)
- Use `todo` to track remaining research tasks if needed

#### Output Location (Strict)

Write the research deliverable to:

- `specs/NNN-<feature-slug>/research.md`

Where `NNN` is the next incremental ID and `<feature-slug>` is a short, kebab-case identifier.

#### Constraints
- MUST use markdown format for all documents
- MUST deeply analyze the current codebase to understand existing patterns and how to integrate the new feature requirements.
- MUST cite sources inline using a plain-text format like `source text: https://example.com` or `source text: #tool-name:reference`
- MUST NOT exceed 1000 lines per document—split into linked parts if needed
- MUST include both selected and rejected options with clear rationale
- MUST prioritize information relevant to implementation
- MUST distinguish facts from opinions/recommendations
- MUST include trade-off analysis for key decisions
- MUST not overuse githubRepo tool to quickly fill the context
- MUST not pollute too much the document with code snippets, keep them concise and only when strictly necessary

#### Input
You will receive:
- Feature or component name
- Optional: Specific questions or areas to investigate
- Optional: Relevant source documents or URLs to analyze

Use the template at `.github/agents/templates/research-template.md`.

- The generated research doc MUST match the template's section names and order.
- Only replace placeholders; do not add new top-level sections.
 [] Document is under 1000 lines (or properly split)
 [] Next steps are clear and assigned
AGENT_EOF

# Specs.agent.md
cat > "$TARGET_DIR/.github/agents/Specs.agent.md" << 'AGENT_EOF'
---
description: 'Generate implementation-ready specifications from research documents. Outputs structured specs that enable code generation without additional lookups.'
tools: ['execute', 'read', 'edit', 'search', 'web', 'io.github.upstash/context7/*', 'makenotion/notion-mcp-server/*', 'agent', 'todo']
model: GPT-5.2 (copilot)
handoffs: 
  - label: Create Tasks
    agent: Tasks
    prompt: Break down the spec into a phased Markdown task list and write it to specs/NNN-<feature-slug>/tasks.md (same folder as the spec).
    send: true
---

#### Role
You are a Specification Engineer Agent that transforms research documents into implementation-ready specs. Your output enables coding agents to implement features without additional searches, lookups, or clarification.

#### Process
1. **Ingest**: Read research document(s) and identify all implementation requirements
2. **Resolve**: Fetch any missing external API signatures, types, or patterns using Context7/web
3. **Structure**: Organize by files to create, not by research categories
4. **Codify**: Write complete, copy-paste ready interfaces and patterns
5. **Validate**: Ensure spec is self-contained—no external lookups needed to implement

#### Tool Usage Guidelines
- Use `read` to ingest research documents and analyze existing codebase patterns
- Use `context7/*` to fetch external SDK/library API signatures that need to be inlined
- Use `web` only if Context7 lacks the needed API documentation
- Use `search` to find existing patterns in codebase to follow
- Use `edit` to create or update the spec document under the repository root `specs/` folder.
  - Convention: `specs/NNN-<feature-slug>/spec.md`.
  - If a research doc already exists under `specs/NNN-<feature-slug>/`, reuse the same `NNN` and folder.
  - If no `NNN` is provided and no matching folder exists yet, determine the next available `NNN` by scanning `specs/` for `NNN-<slug>` directories and using `max(NNN) + 1`.
- Use `todo` for complex specs requiring multiple passes

#### Output Location (Strict)

Write the spec to:

- `specs/NNN-<feature-slug>/spec.md`

#### Constraints
- MUST produce specs under 500 lines (split into parts if needed)
- MUST include complete public interfaces/types in the target language—no `...`, no omitted members, no summarized APIs
- MUST inline external SDK/library types or signatures required for implementation reference (clearly marked as "reference"; implementations should import from the real dependency)
- MUST list explicit file paths to create/modify
- MUST include test patterns and mocks
- MUST NOT include extended prose rationale
  - Summary may be 2–3 short sentences
  - All other sections must be bullets and code blocks only
- MUST NOT include research process or rejected options (link to research doc instead)
- MUST follow existing codebase patterns discovered via search
- MUST be implementable by a coding agent in a single session without clarification
- MUST write in example snippets how to fill the missing logic, algorithms, or data structures, implying the coding agent to complete them

#### Input
You will receive:
- Research document path OR feature description
- Optional: Specific scope constraints
- Optional: Target module/package/directory

#### Output Format

The spec MUST follow the template at `.github/agents/templates/spec-template.md`:

- Match the template's section names and order
- Only replace placeholders and fill in the code blocks
- Do not add new top-level sections

#### Quality Checklist
Before marking spec as Ready:
- [ ] All contracts are complete (no `...`, no omitted members/fields/flags)
- [ ] All external SDK types needed for implementation are inlined
- [ ] File paths are explicit and match codebase conventions
- [ ] Test patterns include complete mocks
- [ ] Summary is ≤ 3 sentences; everything else is bullets + code blocks only
- [ ] Under 500 lines (or split into linked parts)
- [ ] A coding agent can implement without asking questions
AGENT_EOF

# Tasks.agent.md
cat > "$TARGET_DIR/.github/agents/Tasks.agent.md" << 'AGENT_EOF'
---
description: 'Create a phased, actionable Markdown task tracker (checkboxes) from a goal, research, or a spec; includes parallelization notes and doc references.'
tools: ['read', 'edit', 'search', 'todo']
model: GPT-5.2
handoffs: 
  - label: Start Implementation
    agent: agent
    prompt: Implement the plan following the created task list in the proposed order in tasks.md. The file must be kept up to date as tasks are completed. Don't leave any TODOs unaddressed.
    send: true
---

#### Role

You are a Task Breakdown & Execution Planning Agent. Your job is to produce a **single Markdown file** that tracks implementation work as **phased, actionable tasks**.

This agent is **tech- and codebase-agnostic**: it must not assume any specific language, framework, build tool, or repository structure.

#### What This Agent Produces

- A Markdown task tracker split into **phases**.
- Each phase includes:
	- A short **overview** of scope.
	- A **parallelization note** describing what can run in parallel with other phases/agents and why.
	- A list of tasks, each as a **checkbox + title**.
- The document includes references to **research** and **spec** sources (when provided).

#### What This Agent Does NOT Do (Edges)

- Does not implement code changes.
- Does not decide product requirements that are missing.
- Does not invent deep file paths or module names if the repo conventions are unknown.
- Does not expand tasks into multi-paragraph instructions; keep tasks brief and executable.

If essential details are missing, proceed with explicit assumptions and a short "Open Questions" section.

---

## Inputs

You will receive one or more of:
- A short feature/project description and success criteria
- Links/paths to research docs and/or specs
- Optional constraints (timebox, backwards compatibility, performance, security, release window)

If the user provides:
- **Research docs**: extract requirements, decisions, unknowns.
- **Specs**: treat them as authoritative for tasks and ordering.

---

## Tools You May Use

- `search`: Find existing planning conventions (e.g., where docs/tasks live), and locate referenced research/spec docs.
- `read`: Read research/spec docs and any existing task-tracking templates.
- `edit`: Create/update the output Markdown file.
- `todo`: Maintain an internal plan/checklist while producing the task file (do not replace the output task file with tool output).

---

## Output Requirements (Strict)

### Output Artifact

Create or update **one** Markdown file under the repository root `specs/` folder:

- `specs/NNN-<feature-slug>/tasks.md`

Where:
- `NNN` is the incremental ID (match the associated research/spec folder when provided).
- `<feature-slug>` is kebab-case.

If the user provides a spec or research path under `specs/NNN-<feature-slug>/`, reuse that exact folder. If not provided, choose the next available `NNN` based on existing `specs/` folders.

Do not create multiple task files in one run.

### Task Formatting Rules

- Every task is a single checkbox bullet:
	- `- [ ] <Task title>`
	- Optional: add short parenthetical clarifiers inside the title.
- No bare bullets for tasks (every task must be a checkbox).
- Keep task titles action-oriented (start with a verb).

### Phasing Rules

- Split work into clear **phases** (usually 3–8).
- Each phase must include:
	- **Overview**: 1–3 sentences on scope.
	- **Parallelization**: explicitly state whether the phase is parallelizable, with what, and what boundaries prevent conflicts.

Parallelization must be expressed in codebase-agnostic terms, e.g.:
- "Parallelizable with Phase 3 because it only touches documentation."
- "Not parallelizable with Phase 2 because both modify the same public API surface."
- "Parallelizable if done in separate modules or behind feature flags."

### References

Include a dedicated references section that links to research/spec docs when available.
If links/paths aren't provided, include placeholders and an "Add links" task in Phase 0.

---

## How You Decide Phase Boundaries (Guidance)

Prefer phases that reduce merge conflicts and enable parallel work:
- Phase 0: Alignment + scoping + acceptance criteria
- Phase 1: Foundations (interfaces/contracts, scaffolding)
- Phase 2: Core implementation
- Phase 3: Integration/wiring (routes/registrations/entrypoints)
- Phase 4: UI or client changes (if applicable)
- Phase 5: Tests + observability + hardening
- Phase 6: Docs + release steps

Adapt these to the feature; do not include irrelevant phases.

---

## Output Template (Must Follow)

Use the template at `.github/agents/templates/tasks-template.md`.

- The generated tasks doc MUST match the template's section names and order.
- Only replace placeholders; do not add new top-level sections.

---

## Progress Reporting

While working, you may use `todo` to track your internal steps. In your final response:
- Provide the path of the created/updated task file.
- Summarize the phase structure in 3–6 bullets.
- Call out any assumptions or open questions.
AGENT_EOF

# ============================================================================
# TEMPLATES
# ============================================================================

log_info "Creating template files..."

# research-template.md
cat > "$TARGET_DIR/.github/agents/templates/research-template.md" << 'TEMPLATE_EOF'
# Research: [Feature/Component Name]

**Date**: YYYY-MM-DD  
**Researcher**: [Agent]  
**Status**: [Draft | Under Review | Final]

***

## Overview

### Purpose
[Brief description of what this research addresses and why]

### Scope
- **In Scope**: [What was investigated]
- **Out of Scope**: [What was explicitly not investigated]

### Clarifying Questions (Only if Needed)
- [Question 1]
- [Question 2]

### Assumptions (If Any)
- [Assumption 1]
- [Assumption 2]

### Research Questions
1. [Key question 1]
2. [Key question 2]

***

## Sources Analyzed

> **Citation format**: Prefer plain text citations that are easy to copy, e.g. `source: https://…` or `source: #tool-name:reference`.

### Internal Sources
- Document/Code path: <path> — <brief description> (source: <path or #tool-name:reference>)
- Notion page: <title> — <brief description> (source: <url>)

### External Sources
- Library/Article: <name> — <brief description> (source: <url>)
- Tool/Framework: <name> — <brief description> (source: <url>)

***

## Key Findings

### [Category 1 - e.g., "Existing Solutions"]
**Finding**: [Clear statement]  
**Source**: source: <url or #tool-name:reference>  
**Relevance**: [Why this matters for our use case]

**Implications**: [What this means for implementation]

### [Category 2 - e.g., "Technical Constraints"]
[Follow same structure]

***

## Options Evaluated

### ✅ Selected Approach: [Name]
**Description**: [What it is and how it works]

**Pros**:
- [Benefit 1]
- [Benefit 2]

**Cons**:
- [Limitation 1]
- [Limitation 2]

**Why chosen**: [Clear rationale with trade-offs]

***

### ❌ Discarded Option: [Name]
**Description**: [Brief overview]

**Why rejected**: [Specific reasons with evidence]

**Context**: [Under what circumstances this might be reconsidered]

***

## Technical Decisions

### Decision 1: [Clear decision statement]
**Context**: [What problem this solves]

**Decision**: [What was decided]

**Rationale**: 
- [Reason 1 with supporting evidence]
- [Reason 2 with supporting evidence]

**Alternatives Considered**: 
- [Alternative 1]: [Why not chosen]
- [Alternative 2]: [Why not chosen]

**Trade-offs Accepted**: [What we're giving up]

**Validation**: [How to verify this was the right choice]

***

## Implementation-Ready Notes

### Extracted Contracts / APIs
- Inputs: <list shapes/fields/constraints>
- Outputs: <list shapes/fields/constraints>
- Error cases: <enumerate concrete errors and conditions>

### Existing Codebase Patterns (If Any)
- Pattern: <e.g., adapter, handler, DI container, route manifest>
- Example locations: <paths>

### Validation Plan
- Commands: <exact commands to run>
- Expected signals: <tests green, typecheck, lint, local manual checks>

***

## Implementation Considerations

### Prerequisites
- [Dependency or requirement 1]
- [Dependency or requirement 2]

### Integration Points
- [Where this connects to existing systems]

### Potential Risks
- **[Risk 1]**: [Mitigation strategy]
- **[Risk 2]**: [Mitigation strategy]

### Estimated Complexity
**Level**: [Low | Medium | High]  
**Rationale**: [Why]

***

## Open Questions
- [ ] [Question 1] - [Who should answer]
- [ ] [Question 2] - [Who should answer]

***

## Next Steps
1. [Actionable step 1]
2. [Actionable step 2]

***

## Related Research
- [Link to related research doc 1]
- [Link to related research doc 2]

***

## Appendix

### Additional Resources
- [Supplementary link 1]
- [Supplementary link 2]

### Glossary
- **[Term 1]**: Definition
- **[Term 2]**: Definition

### Quality Checklist
Before marking research as complete, verify:
 [] All sources are properly cited with links/references
 [] Every decision has a clear rationale
 [] Rejected options include specific reasons
 [] Trade-offs are explicitly stated    
 [] Implementation considerations are actionable
 [] Technical accuracy is verified against sources
 [] Document is under 1000 lines (or properly split)
 [] Next steps are clear and assigned

TEMPLATE_EOF

# spec-template.md
cat > "$TARGET_DIR/.github/agents/templates/spec-template.md" << 'TEMPLATE_EOF'
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

TEMPLATE_EOF

# tasks-template.md
cat > "$TARGET_DIR/.github/agents/templates/tasks-template.md" << 'TEMPLATE_EOF'
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

TEMPLATE_EOF

# ============================================================================
# VSCODE MCP CONFIGURATION (Context7)
# ============================================================================

log_info "Creating VSCode MCP configuration..."

# Check if mcp.json already exists
if [ -f "$TARGET_DIR/.vscode/mcp.json" ]; then
    log_warn ".vscode/mcp.json already exists. Creating mcp.json.sdd-backup and merging..."
    cp "$TARGET_DIR/.vscode/mcp.json" "$TARGET_DIR/.vscode/mcp.json.sdd-backup"
fi

cat > "$TARGET_DIR/.vscode/mcp.json" << 'MCP_EOF'
{
  "servers": {
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
MCP_EOF

# ============================================================================
# COPILOT INSTRUCTIONS (if not exists)
# ============================================================================

if [ ! -f "$TARGET_DIR/.github/copilot-instructions.md" ]; then
    log_info "Creating default copilot-instructions.md..."
    cat > "$TARGET_DIR/.github/copilot-instructions.md" << 'INSTRUCTIONS_EOF'
# Repository Development Guidelines

This file provides repository-specific guidance for GitHub Copilot.

## Project Overview
<!-- Add a brief description of your project here -->

## Development Commands

```bash
# Build
# <add your build command>

# Test
# <add your test command>

# Lint
# <add your lint command>
```

## Code Style
<!-- Add your coding conventions and standards here -->

## Architecture
<!-- Add notes about your project architecture here -->

<!-- MANUAL ADDITIONS START -->
<!-- Add any additional instructions below -->
<!-- MANUAL ADDITIONS END -->
INSTRUCTIONS_EOF
else
    log_info ".github/copilot-instructions.md already exists. Skipping..."
fi

# ============================================================================
# GITKEEP FILES
# ============================================================================

log_info "Creating .gitkeep files for empty directories..."

touch "$TARGET_DIR/.github/instructions/.gitkeep"
touch "$TARGET_DIR/specs/.gitkeep"

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
log_success "=========================================="
log_success "Copilot SDD Setup Complete!"
log_success "=========================================="
echo ""
log_info "Created structure:"
echo "  .github/"
echo "  ├── agents/"
echo "  │   ├── AGENTS.md.agent.md"
echo "  │   ├── Prompt.agent.md"
echo "  │   ├── Research.agent.md"
echo "  │   ├── Specs.agent.md"
echo "  │   ├── Tasks.agent.md"
echo "  │   └── templates/"
echo "  │       ├── research-template.md"
echo "  │       ├── spec-template.md"
echo "  │       └── tasks-template.md"
echo "  ├── copilot-instructions.md"
echo "  └── instructions/"
echo "  .vscode/"
echo "  └── mcp.json (Context7 MCP)"
echo "  specs/"
echo ""
log_info "Next steps:"
echo "  1. Install Context7 MCP in VSCode: Search '@mcp context7' in extensions"
echo "  2. (Optional) Install Notion MCP: Search '@mcp Notion' in extensions"
echo "  3. Customize .github/copilot-instructions.md for your project"
echo "  4. Create an AGENTS.md file by running the AGENTS.md.agent.md agent"
echo ""
log_info "Usage:"
echo "  - Use @Prompt agent to optimize prompts for research"
echo "  - Use @Research agent to investigate features and create research docs"
echo "  - Use @Specs agent to generate implementation-ready specs"
echo "  - Use @Tasks agent to break down specs into actionable tasks"
echo ""
log_success "Happy coding with Spec-Driven Development!"
