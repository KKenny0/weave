# Source Dive Workflow

Triggered when the user provides a technical project name, GitHub URL, framework, or library. Output is a Chinese technical deep-dive article that explains load-bearing behavior, verifies important claims, and surfaces documentation-versus-source differences.

## Phase 1: Discover

Build a source model around the user's question, not a generic repository inventory.

### Step 1: Parse the investigation

Capture:

- topic and repository URL
- official docs and papers when relevant
- `q`: what the user wants to understand or decide
- every named focus area
- available repository capabilities: local checkout, remote tree reader, file reader, background agents, shell, and safe test execution

Each focus area becomes a coverage obligation and later maps to a behavior path or a clearly labeled limitation.

### Step 2: Confirm the canonical source

Prefer evidence in this order:

1. local checkout at a known commit
2. official repository at a commit SHA or tag
3. official docs tied to a version
4. official engineering posts or papers
5. community analysis for leads only

If the official repository cannot be identified, stop and ask for the URL. Record the commit or tag used so file evidence does not float with the default branch.

### Step 3: Map the repository

Use the best available tree reader. Inspect root docs and configs, entry points, core code, tests, generators, plugin or adapter directories, and release metadata. Tool names are implementation details: if a repository MCP or background agent is unavailable, fall back to local files, native fetch, or serial main-thread reads.

Classify files on two independent axes.

#### Analysis priority

| Priority signal | Why it matters |
|---|---|
| Public entry / command / API | Starts behavior visible to users |
| State owner | Determines what persists and changes |
| Router / registry / loader | Controls extension and dispatch |
| Boundary / adapter | Defines dependencies and failure behavior |
| User focus | Directly answers `q` |
| Tests for a core path | Reveal intended invariants and edge cases |
| Generated / vendored / fixture | Usually evidence, rarely the explanatory center |

#### Read scheduling

| Size | Handling |
|---|---|
| <50KB | Main thread can read directly |
| 50-200KB | Segment or use a background agent |
| >200KB | Save or segment first; inspect only relevant regions |

Size controls reading mechanics, never analytical importance. A small state machine can outrank a large generated file.

Select 5-15 files or symbols that cover the entry, state, dispatch, boundaries, failure path, and named focus areas. Explain why each is selected.

### Step 4: Read docs as claims

Fetch overview, architecture, key guides, configuration, and extension documentation. Record every load-bearing doc statement as a claim to verify against code or behavior. Examples:

- default value or supported mode
- plugin discovery rule
- lifecycle order
- persistence promise
- error or fallback behavior
- packaging or generation claim

Docs are evidence about intended behavior. Source and runtime evidence decide actual behavior.

### Step 5: Discovery brief

Produce internal Phase 2 input:

- repository, commit, docs version
- user question and focus obligations
- selected entries, state owners, registries, boundaries, and tests
- file size only as a read-scheduling tag
- doc claims to verify
- candidate behavior paths
- safe runtime probes available
- coverage gaps

## Phase 2: Analyze

Explain how the system behaves. Files and symbols are evidence nodes inside behavior paths.

### Step 1: Trace load-bearing paths

Choose 2-5 paths that answer `q`. Use this shape:

```text
trigger -> entry -> routing -> state change -> extension/boundary -> output or failure
```

For each path capture:

- initiating command, request, hook, or API
- functions and symbols crossed
- state read and written
- defaults, thresholds, and configuration
- external boundary and fallback
- observable result
- failure propagation and recovery
- tests that assert the path

When paths share a segment, explain the shared mechanism once and show where they diverge.

### Step 2: Read in parallel when useful

Background agents may read independent medium or large regions. Dispatch them together. If unavailable, execute the same reads serially; reduced concurrency must not reduce the selected path coverage.

Agent or serial output must report behavior evidence, not a top-N symbol list. Enumerate classes or modes only when the taxonomy itself changes behavior. For an enumeration larger than 10 items, select the 5-8 items carrying the architecture or user focus, mark `[选取 N/M 项]`, and state the selection criterion.

### Step 3: Verify safe behavior

When the checkout can run without new accounts, destructive actions, or external state changes:

- run existing focused tests for a core path;
- run `--check`, dry-run, inspect, or read-only CLI commands;
- compare generated metadata with its source;
- inspect runtime defaults or a minimal local output.

Do not install a new service or mutate production state for an article. When a probe is unavailable or fails, mark the related conclusion `static inference` and include the reason. Never report inferred behavior as runtime-verified.

### Step 4: Extract invariants and constraints

Across paths, find the small set of rules that explain multiple behaviors:

- one source of truth
- state ownership
- ordering or lifecycle invariant
- default-deny or allowlist boundary
- idempotency or replay rule
- extension contract
- compatibility constraint

For each candidate invariant, identify the code that enforces it, the test or behavior that exposes it, and what breaks when it is removed.

### Step 5: Compare docs, source, and runtime

Record differences explicitly:

```text
Claim: docs say X
Source: code at commit Y implements Z
Runtime: probe observed R, or not verified
Impact: what a user or contributor would misunderstand
```

Source wins over prose for implemented behavior; runtime wins when environment and version match. Preserve version differences instead of calling them contradictions.

### Step 6: Generate explanatory lenses

Use the evidence to form 1-4 candidates. Useful lens families include:

- behavior or data flow
- state lifecycle
- core constraint or invariant
- extension and dispatch system
- failure and recovery boundary
- documentation-versus-reality delta

These are search directions, not mandatory sections. A candidate must reorganize the behavior paths and explain more than one local fact. Discard a lens that only renames the module list.

Use the Candidate Frame Brief and admission gates in `frame-selection.md` when retaining candidates.

For transferable patterns, require:

- concrete enforcing symbols and configuration;
- why the pattern works in this project;
- what fails when a component is removed;
- applicable and inapplicable scenarios;
- a counterexample or boundary.

If evidence is thin, write `迁移素材不足` and skip a standalone migration chapter.

### Step 7: Select the article spine

Apply `frame-selection.md`. Select the lens that best answers `q`, has the strongest verified evidence, and produces the clearest path dependency. Prefer a narrower verified explanation over a broad static one.

Build a chapter map. Every chapter must serve one of: establish path, explain mechanism, contrast implementation, test invariant, expose boundary, or transfer pattern. Named focus areas must map to a chapter or an explicit coverage limitation.

## Phase 3: Compose

Write the technical article from the selected lens and behavior evidence.

### Structure rules

- Let the selected lens determine chapter count and order; 6-8 chapters is a heuristic, not a gate.
- Start with the user-visible behavior or load-bearing question, then trace inward.
- Use diagrams for multi-module paths and tables for real multi-dimensional comparisons.
- Do not organize the article by repository directory or read order.
- Keep different modes or adapters separate when their behavior differs.
- Merge items only when they share a mechanism and failure boundary.

### Evidence rules

- Cite commit, path, symbol, configuration, test, or runtime probe for technical claims.
- Prefer commit-pinned permalinks when available; line numbers alone drift.
- Mark static inference and incomplete reads.
- Surface documentation differences where they affect understanding.
- Never turn a community explanation into source truth.

### Optional Engineering Migration

Include only if Phase 2 produced validated transferable patterns. For each pattern: name, definition, project mechanism, boundary, applicable scenario, inapplicable scenario, and evidence. One valid pattern is enough; do not pad to three.

### Quality audit

Check:

- Can each named focus area be followed through a behavior path?
- Does the article explain state changes and failure paths, not only happy-path classes?
- Did file-size scheduling accidentally become an importance ranking?
- Are runtime claims distinguished from static inference?
- Does the selected lens change the chapter structure?
- Do transfer patterns survive component-removal and counterexample tests?

### Voice Pass and output

Run `voice-pass.md`, then write `{topic}-source-dive_{YYYY-MM-DD}.md` per `output-spec.md`.

Delivery report: article path, word count, chapter structure, selected lens, close alternative if material, commit analyzed, behavior paths traced, runtime probes passed or unavailable, doc-source-runtime differences, transferable patterns, anti-patterns, and coverage gaps.

Stop at publish confirmation. Do not push, post, distribute, or commit unless explicitly asked.

## Optional vault integration

If `loom-maintain` is installed, suggest it for vault integration. Source-dive itself does not modify the vault.
