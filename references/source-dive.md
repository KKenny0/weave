# Source Dive Workflow

Triggered when the user provides a technical project name, GitHub URL, framework, or library. Output is a Chinese technical deep-dive article that reconstructs load-bearing engineering judgments from behavior, verifies important claims, and surfaces documentation-versus-source differences.

## Phase 1: Discover

Build a source model around the user's question, not a generic repository inventory.

### Step 1: Parse the investigation

Capture:

- topic and repository URL;
- official docs and papers when relevant;
- `q`: what the user wants to understand or decide;
- `C`: the Context Envelope from `context-acquisition.md`;
- `R`: the Reader Contract from `reader-model.md`, expressed as an observable tracing, prediction, or boundary-testing capability;
- primary reading intent and at most one secondary intent:
  - `understand`: explain why the project works this way;
  - `evaluate`: judge claims, quality, or applicability;
  - `learn`: absorb conditional engineering judgments;
  - `apply`: migrate, integrate, modify, or contribute;
- reading scope, independent of intent:
  - `system`: understand the complete tool or repository as a working system;
  - `subsystem`: understand one capability domain such as MCP, memory, or plugins;
  - `decision`: understand one design choice, tradeoff, or historical change;
- the phenomenon, capability, or engineering judgment that most interests the reader;
- the observable cognitive result that would make the reading complete;
- whether the request actually contains an evaluation, migration, or modification need;
- every named focus area;
- available repository capabilities: local checkout, remote tree reader, file reader, background agents, shell, and safe test execution.

Each focus area becomes a coverage obligation and later maps to a behavior path or a clearly labeled limitation. When the user only says they are interested or want to see how a project is implemented, default to `understand` with `learn` as secondary. “How is this project designed?”, “what problem does this tool solve?”, and explicit whole-repository requests default to `system`. A named module or capability defaults to `subsystem`; a named tradeoff or historical choice defaults to `decision`. Mentioning Provider, MCP, or Plugin inside a whole-system question does not silently narrow the scope. Do not infer `apply` from technical sophistication or repository access.

Intent and scope remain in working memory and control evidence selection, comprehension, and article closure. Do not render either as a final-article, pre-reveal, or delivery-report field.

### Step 2: Confirm the canonical source

Prefer evidence in this order:

1. local checkout at a known commit;
2. official repository at a commit SHA or tag;
3. official docs tied to a version;
4. official engineering posts or papers;
5. community analysis for leads only.

If the official repository cannot be identified, stop and ask for the URL. Record the commit or tag used so file evidence does not float with the default branch.

### Step 3: Map the repository

Use the best available tree reader. Inspect root docs and configs, entry points, core code, tests, generators, plugin or adapter directories, and release metadata. When the question needs design explanation, also select configuration, compatibility layers, and failure tests that expose constraints. Read ADRs, changelogs, key issues, PRs, or commits only when they can resolve a specific design or evolution question; do not perform history archaeology without a target. Tool names are implementation details: if a repository MCP or background agent is unavailable, fall back to local files, native fetch, or serial main-thread reads.

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
| Constraint / compatibility evidence | Explains why implementation choices differ |
| Targeted design history | Supports attributable motive or evolution |
| Generated / vendored / fixture | Usually evidence, rarely the explanatory center |

#### Read scheduling

| Size | Handling |
|---|---|
| <50KB | Main thread can read directly |
| 50-200KB | Segment or use a background agent |
| >200KB | Save or segment first; inspect only relevant regions |

Size controls reading mechanics, never analytical importance. A small state machine can outrank a large generated file.

Select 5-15 files or symbols that cover the entry, state, dispatch, boundaries, failure path, named focus areas, and the constraints needed to explain the design. Explain why each is selected.

For `system`, the selection must cover at least one primary user entry, one core state owner, one orchestrator or runtime core, two capability modules, one host or external boundary, and one failure, shutdown, or recovery path. A major area left unread must either be shown not to change the system model or recorded as a coverage gap. Do not begin from a list of named modules and mistake coverage for orientation.

### Step 4: Read docs and history as claims

Fetch overview, architecture, key guides, configuration, and extension documentation. Separate two claim types:

- **Behavior claim**: what the system promises to do, verified against source or runtime behavior.
- **Design claim**: why the project says it adopted a structure, requiring attributable author or maintainer evidence.

Record every load-bearing statement as a claim to verify, including defaults, supported modes, discovery rules, lifecycle order, persistence, fallbacks, packaging, and stated design reasons.

Docs are evidence about intended behavior. Source and runtime evidence decide actual behavior. Code can prove that a constraint is enforced, but cannot by itself prove the author's motive. Attribute motive only to official design notes, ADRs, maintainer issues or PRs, commit messages, or equivalent attributable material. Otherwise label the explanation as weave inference.

### Step 5: Establish the system orientation

Before tracing detailed behavior paths, establish the product-facing orientation appropriate to scope. For `system`, build an internal `System Design Brief` with:

- **Product identity**: one sentence describing the tool without internal class names;
- **Target user or actor**: who uses it and in what situation;
- **Core problem**: the fragmentation, difficulty, or impossibility it removes;
- **User capabilities**: the outcomes the user gains;
- **System boundary**: what the system owns and what remains with hosts or external services;
- **Entry points**: user, remote, scheduler, CLI, API, or other entry surfaces;
- **Core state**: the durable state that drives behavior;
- **Major subsystems**: each connected as `user capability -> system responsibility -> executable mechanism`;
- **Canonical task loop**: one representative task from entry through state, orchestration, capabilities, output, and failure ownership;
- **Organizing principle**: the rule that makes the parts one system rather than a module list;
- **Evidence status**: declared product claim, implemented mechanism, runtime observation, or weave inference.

The brief stays in working memory. It is not persisted or rendered as a field table. For `subsystem` and `decision`, record only the product identity, the selected area's user-facing capability, its boundary with the wider system, and the evidence ceiling; do not pay the cost of a full-system brief.

A subsystem qualifies only when it connects user capability, system responsibility, and mechanism. Reject a brief that merely enumerates directories or classes.

### Step 6: Discovery brief

Produce internal Phase 2 input:

- repository, commit, and docs version;
- user question and focus obligations;
- primary and secondary reading intent, reading scope, foreground phenomenon or judgment, and observable completion result;
- the scope-appropriate system orientation and, for `system`, the completed System Design Brief;
- context-supported user goal, decision, and constraints; keep project instructions separate from personal baselines;
- selected entries, state owners, registries, boundaries, tests, constraint evidence, and targeted history;
- file size only as a read-scheduling tag;
- behavior claims, attributable design claims, and targeted historical questions;
- candidate behavior paths;
- safe runtime probes available;
- coverage gaps.

## Phase 2: Analyze

Explain how the system behaves, then reconstruct the engineering judgments that produced those behaviors. Files and symbols are evidence nodes inside behavior paths.

### Step 1: Trace the canonical task and load-bearing paths

For `system`, choose one real representative task as the article's main line before adding supporting paths. It must expose where the task enters, which durable state owns continuity, where orchestration and decisions occur, how at least two capabilities cooperate, what the user receives, and which component owns failure or shutdown. Every later mechanism chapter must reconnect to this task or to a named system boundary.

Choose 2-5 paths that answer `q`; the canonical task may be one of them. Use this shape:

```text
trigger -> entry -> routing -> state change -> extension/boundary -> output or failure
```

For each path capture the initiating command or API, crossed symbols, state read and written, defaults and configuration, external boundaries and fallback, observable result, failure propagation and recovery, and tests that assert the path. When paths share a segment, explain the shared mechanism once and show where they diverge.

### Step 2: Read in parallel when useful

Background agents may read independent medium or large regions. Dispatch them together. If unavailable, execute the same reads serially; reduced concurrency must not reduce selected path coverage.

Agent or serial output must report behavior evidence, not a top-N symbol list. Enumerate classes or modes only when the taxonomy itself changes behavior. For an enumeration larger than 10 items, select the 5-8 items carrying the architecture or user focus, mark `[选取 N/M 项]`, and state the selection criterion.

### Step 3: Verify safe behavior

When the checkout can run without new accounts, destructive actions, or external state changes, run existing focused tests, use check/dry-run/read-only commands, compare generated metadata with its source, or inspect a minimal local output. Do not install a new service or mutate production state for an article.

When a probe is unavailable or fails, mark the related conclusion `static inference` and include the reason. Never report inferred behavior as runtime-verified.

### Step 4: Extract invariants and design forces

Across paths, find the small set of rules and forces that explain multiple behaviors: state ownership, ordering, default-deny boundaries, replay rules, extension contracts, compatibility, performance, host, deployment, or security constraints.

For each candidate, identify the code that enforces it, the test or behavior that exposes it, and what breaks when it is removed. Retain a design force only when it changes routing, state, or a boundary; rules out an evidenced neighboring approach; explains multiple implementation details; or leaves a trace in tests, configuration, or history. Drop generic labels such as “for extensibility” or “for flexibility” when no executable mechanism supports them.

### Step 5: Build Engineering Decision Briefs

After the behavior paths are stable, build one to three internal briefs for the decisions that carry the explanation. Merge paths produced by the same decision instead of creating one brief per path. Each brief records:

- **Observed problem**: the problem the project actually responds to;
- **Design forces**: constraints that changed the implementation choice;
- **Decision**: the selected structure, boundary, or principle;
- **Executable mechanism**: symbols, configuration, state, tests, and behavior paths that implement it;
- **Consequence**: the capability it creates;
- **Cost**: complexity, restriction, coupling, or operational burden it introduces;
- **Failure boundary**: the condition under which the judgment stops holding;
- **Alternative**: only a route documented in history or explicitly excluded by the current structure;
- **Evidence status**: declared intent, historical evidence, implemented mechanism, runtime observation, or weave inference.

Every admitted brief must contain at least one problem or force, one decision, a set of executable components, one consequence, and one cost or boundary. A useful engineering judgment has the form `under constraint C -> choose D -> through mechanism M -> gain A -> pay K -> fail at B`. The briefs stay in working memory and must not appear as field tables in the article, pre-reveal artifact, or delivery report.

### Step 6: Compare docs, source, history, and runtime

Record differences explicitly:

```text
Claim: docs or history say X
Source: code at commit Y implements Z
Runtime: probe observed R, or not verified
Impact: what a reader or contributor would misunderstand
```

Source wins over prose for implemented behavior; runtime wins when environment and version match. Preserve version differences instead of calling them contradictions. Keep declared intent, historical evidence, implemented mechanism, runtime observation, and weave inference distinct. A structural explanation without motive evidence may still be useful, but must not be written as “the authors chose this because…”.

### Step 7: Generate explanatory lenses

Use the evidence to form 1-4 candidates. A candidate must reorganize behavior paths, explain more than one local fact, and connect at least two layers of `problem/force <-> decision <-> mechanism <-> consequence/boundary`. Discard a lens that only renames a module list, call chain, plugin mechanism, or state lifecycle. Use the Candidate Frame Brief and admission gates in `frame-selection.md` when retaining candidates.

For `system`, a candidate must simultaneously explain the product problem, overall system shape, canonical task, at least two load-bearing design judgments, user capabilities, and system boundary. A frame that only reorganizes Provider, MCP, Plugin, or other mechanism chapters fails even when every local claim is correct.

Discuss alternatives only when repository history contains them, the current structure clearly excludes a definable neighboring approach, or the user's question asks for comparison. Do not invent paths the authors “could have chosen” to make the analysis appear deeper.

For `apply` intent, transferable patterns require concrete enforcing symbols and configuration, why the pattern works here, what fails when a component is removed, applicable and inapplicable scenarios, and a counterexample or boundary. If evidence is thin, write `迁移素材不足` and do not admit a transfer into the Impact Brief. `understand`, `evaluate`, and `learn` runs do not fail when transfer material is absent.

### Step 8: Select the article spine

Apply `frame-selection.md`. Select the lens that best answers `q`, has the strongest verified evidence, and produces the clearest path dependency. Prefer a narrower verified explanation over a broad static one. Map every named focus area to a chapter or an explicit coverage limitation.

For the source-dive hold-out, reserve a non-entry module connected to a core behavior path. For `system`, the hold-out must test whether an unseen module can be placed inside the complete system model or exposes a missing boundary, state owner, or user capability. For `subsystem` or `decision`, check whether it supports an existing decision, exposes a missed cost, lowers confidence in attributed intent, or forces the load-bearing chain to narrow. Retrofitting the system model or decision after reveal is a hold-out failure.

Run the scope-specific Comprehension Gate in `reader-model.md` after hold-out testing. For `system`, reconstruct in plain product language what the tool is, who it serves, its capabilities, system shape, core state, and one complete task before testing a new case or counterexample. For `subsystem` and `decision`, reconstruct the relevant problem or constraint, design judgment, enforcing behavior path, capability, cost, and failure condition. Repair the initial question when implementation reveals that the apparent product category is wrong or when missing historical/runtime evidence prevents an answer.

Then build source-dive Project Takeaways through `impact-pass.md`, separate from personal impact or migration. A `system` or `learn` run needs three to five evidence-backed, project-specific judgments that a reader can restate without source names. Only after those close the project understanding should Impact Pass compute personal or question-level implications. Transfers enter the Impact Brief only for `apply` and only when their enforcing components, component-removal failure, applicable and inapplicable scenarios, and evidence are all present.

## Phase 3: Compose

Before Compose, build the source-dive Article Closure Contract in `article-integrity.md`. The finished article should complete this cognitive movement without turning it into a fixed chapter template:

```text
observable project phenomenon
  -> product identity, user capability, and system boundary
  -> canonical task and core state
  -> actual problem
  -> shaping constraints
  -> load-bearing decision
  -> executable mechanism
  -> capability, cost, and boundary
  -> added engineering possibility for the reader
```

### Structure rules

- Let the selected lens determine chapter count and order; 6-8 chapters is a heuristic, not a gate.
- Start with user-visible behavior or a load-bearing question, then trace inward.
- Use diagrams for multi-module paths and tables for real multi-dimensional comparisons.
- Do not organize the article by repository directory or read order.
- Keep modes or adapters separate when their behavior differs; merge only when they share a mechanism and failure boundary.
- Do not expose Engineering Decision Brief fields or force headings such as “design judgment” and “engineering insight”.
- Do not add migration advice when the reading intent is not `apply`.
- For `system`, use the opening fifth of the article to define the tool, actor or usage context, core problem, major user capabilities, overall system model, and canonical task. Do not front-load internal symbols before this orientation is complete.
- When a system has three or more major parts, include a compact diagram that expresses ownership and task or data flow rather than merely listing modules.
- A mechanism chapter should move from user capability and the failure without it, through the design judgment and executable mechanism, to cost and boundary.
- Render Project Takeaways as finished prose or a compact concluding sequence. They are not migration advice and do not need a fixed “takeaways” heading.

### Evidence rules

- Cite commit, path, symbol, configuration, test, or runtime probe for technical claims.
- Prefer commit-pinned permalinks when available; line numbers alone drift.
- Mark static inference, weave inference, and incomplete reads.
- Surface documentation differences where they affect understanding.
- Never turn a community explanation into source truth or infer author motive from code structure alone.

### Context-aware engineering impact

Render admitted engineering distinctions, design judgments, or validated transfers through `impact-pass.md`. When `C` contains a real engineering decision, explain which criterion changes and why. With question-only context, describe only what the mechanism changes in the reader's model. For `apply`, render validated transferable patterns instead of adding a second migration chapter. One valid impact is enough; do not pad to three.

### Quality audit

Check:

- Can each named focus area be followed through a behavior path?
- Does the article explain state changes and failure paths, not only happy-path classes?
- Did file-size scheduling accidentally become an importance ranking?
- Are runtime claims distinguished from static inference?
- Does the selected lens change the chapter structure and close at least one problem/force-decision-mechanism-consequence/cost chain?
- For `system`, can the opening explain the product, actor, problem, capabilities, system boundary, core state, and canonical task without requiring source identifiers?
- Does every major subsystem connect a user capability to a system responsibility and executable mechanism?
- Can every local mechanism reconnect to the complete system model?
- Are there three to five project-specific takeaways for `system`, distinct from transfer advice?
- Are author motives supported by attributable evidence, with structural explanations labeled weave inference?
- Do `apply` transfers survive component-removal and counterexample tests?
- Did the Comprehension Gate demonstrate the design model on a novel case without overstating the evidence ceiling?
- Was the initial question answered, reframed, dissolved, or left unresolved from evidence?
- Does every personal engineering constraint trace to `C` rather than a project instruction or host-memory guess?
- Did Impact Pass remain downstream of the verified paths and selected lens?
- When intent is not `apply`, did the article avoid forced migration advice?

### Voice Pass, Article Integrity, and output

Run `voice-pass.md`, write `{topic}-source-dive_{YYYY-MM-DD}.md` per `output-spec.md`, then run `article-integrity.md` against the serialized file and read it back before delivery.

Delivery report: article path, word count, chapter structure, selected lens, close alternative if material, commit analyzed, behavior paths traced, runtime probes passed or unavailable, doc-source-runtime differences, `Comprehension Gate: passed` or the failed probe and degradation, `Article Integrity: passed` or material degradation, detected host, context source categories, admitted impact count or `delta ~= 0` reason, context degradation, and coverage gaps. Mention transfers only for `apply` intent. Do not reproduce reading intent, reading scope, the Reader Contract, System Design Brief, Engineering Decision Briefs, closure contract, or gate probes.

For source-dive `system` evals, smokes, and audit-sensitive runs, ask an agent that did not participate in the analysis to read only the final article and answer: what the tool is, what problem it solves, what users gain, how the system is composed, how one representative task flows, which design judgments carry it, what they cost, and which three takeaways matter. If the reader must reopen source or can only repeat module names, the semantic gate fails. When an independent agent is unavailable, report the audit as unavailable; do not simulate independence.

Stop at publish confirmation. Do not push, post, distribute, or commit unless explicitly asked.

## Optional vault integration

If `loom-maintain` is installed, suggest it for vault integration. Source-dive itself does not modify the vault.
