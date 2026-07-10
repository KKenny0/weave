# Source Dive Workflow

Triggered when user provides: technical project name / GitHub URL / framework / library name. Output: Chinese technical deep-dive article on internal implementation, with doc-vs-source diffs surfaced and optionally transferable engineering patterns.

## Phase 1: Discover

Gather repo + docs + papers. Parallels `collect.md` but with technical-source specifics (GitHub API, repo structure, file-size classification).

### Step 1: Confirm input

User typically provides topic (required, like "Hermes Agent" / "LlamaIndex" / "Vite"), optional `repo_url`, optional `docs_url`, optional `paper_urls` (for academic projects), and optional focus areas. Preserve each named focus area as a dedicated analysis path and give it a dedicated chapter or clearly labeled section in the final plan.

### Step 2: Search and locate (parallel)

Run in parallel: GitHub repo (`WebSearch "{topic} github"` if `repo_url` missing, verify official/main by stars + recent activity); official docs (`WebSearch "{topic} documentation"` if `docs_url` missing); papers (optional, `WebSearch "{topic} arxiv"`); community resources (`WebSearch "{topic} deep dive"` or `"{topic} 源码分析"`).

If repo can't be found, stop and ask user for explicit `repo_url`. Don't fabricate.

### Step 3: Get repo structure

Once GitHub repo confirmed, call `mcp__zread__get_repo_structure` for directory tree. Drill into root entries (README/CONTRIBUTING/entry files), core code dirs (src/, lib/, agent/, core/), config files (pyproject.toml, package.json), doc dirs. Drill key dirs until structure is clear.

### Step 4: Fetch core docs

`mcp__web-reader__webReader` on key doc pages. Priority: Getting Started / Overview, Architecture / Design, API Reference, Key guides. Per `SKILL.md` Pre-check fetch budget: 3 attempts max per source. On 429, switch to WebFetch or add 2-3s delay.

### Step 5: Identify key source files

Based on repo structure, identify files needing deep analysis. Selection criteria: entry points (main.py / app.py / index.ts), core logic (most likely to contain primary mechanism), state management (DB / cache / session), config and constants, tool/plugin registration.

Classify by size:

| Size | Tag | Phase 2 handling |
|---|---|---|
| < 50KB | `small` | Main thread reads directly |
| 50-200KB | `medium` | Background agent |
| > 200KB | `large` | Save locally first, then background agent |

Count cap: 5-15 files. If more, rank by core-ness, take top 15.

### Step 6: Read small files in main thread

While waiting on background setup, main thread reads `small` files via `mcp__zread__read_file`. Extract: core class names + inheritance, key function signatures + responsibilities, config constants + defaults, import dependencies (module interaction hints).

### Step 7: Discovery summary

Output as Phase 2 input: topic, repo URL (stars, last commit), docs URL (N pages fetched), papers (if any), key source files (path + size + tag + one-line description), doc core content (page + 2-3 sentence summary), initial observations.

## Phase 2: Analyze

Parallel source-code analysis + knowledge map construction.

### Step 1: Prepare analysis

Split Phase 1 files: main thread group (`small`) and parallel group (`medium`/`large`).

### Step 2: Launch parallel analysis

For each `medium`/`large` file, spawn a background agent in a single message (parallel, not serial). If background agents are unavailable, read the same files serially in the main thread; reduced concurrency must not reduce coverage. Each agent or serial pass uses the best available repository reader (segmented if huge) and extracts: top 10 core classes/functions (one-sentence responsibility each), key mechanism (what + how, 2-3 sentences), module interactions (imports + who imports this), design patterns used (which + why), hardcoded constants/thresholds/defaults, non-obvious details (only visible from code, not docs), and — if the file implements an enum-style system (N layers / M stages / K modes / P adapters) — per-item: purpose, implementation mechanism (function/constant/config), trigger/scope, key differences from other items, concrete evidence.

Agent output rules: 2-3 sentences per point, but 3-5 sentences per enum item (don't conflate different items into one paragraph); quote key code lines only, no large blocks; Chinese.

### Step 3: Main thread analyzes small files (parallel with agents)

While agents run, main thread reads `small` files. Focus: what role does this module play in the whole system? What problem does it solve? Any non-obvious implementation details?

### Step 4: Collect background agent results

Per agent: core findings (2-3), key mechanism description, module relationships, doc-undocumented details. If an agent's analysis is shallow (file too large, partial read), flag for follow-up.

### Step 5: Build knowledge map

Aggregate all analysis (main thread + agents) into a knowledge map with 6 subsections:

1. **Architecture overview**: one paragraph + ASCII module-relationship diagram
2. **Core module list**: one line per module (`{module}: {responsibility} → depends on {others}`)
3. **Key mechanism list**: one paragraph per mechanism (`**{name}**: {how}. Why designed this way.`)
4. **Doc vs source diffs**: every place docs disagree with source (`**{diff}**: docs say {X}, source actually {Y}. Impact: {Z}.`)
5. **Non-obvious findings**: only visible from reading source
6. **Transferable patterns** (prep for optional final chapter): 0-3 groups — pattern name (short memorable, e.g. "Plugin Registry"), how this project uses it (specific to modules/functions), why it works here, applicable scenarios, optional architecture formula (e.g. `plugin system = interface contract + registry + loader + lifecycle hooks`). Also 0-2 anti-patterns (over-engineered / painful / wrong, mark "don't do this" with reason).

**Quality gate**: if material is too thin to extract real patterns, output "迁移素材不足" — the optional final chapter downgrades to a brief summary.

### Step 6: Plan chapter skeleton

Based on knowledge map, plan 6-8 chapters. Each chapter = one core theme (mechanism / architecture layer / comparison set). Chapters have logical dependency (earlier sets up later). Reader's path: macro → micro, concept → implementation.

## Phase 3: Compose

Write the full technical article from the knowledge map.

### Step 1: Confirm chapter plan + optional final chapter

Each chapter title ≤10 字, one-sentence overview, logical dependency between chapters.

**Optional final chapter "Engineering Migration"**: if Phase 2 Section 5.6 produced valid transferable patterns (not "迁移素材不足"), include this chapter (reusable design patterns + architecture formulas + anti-patterns). If thin, skip.

Write directly, don't pause for user confirmation. List structure in delivery report; user can request restructure after. Exception: if any chapter needed more material mid-compose, flag explicitly.

### Step 2: Write chapter by chapter

Per chapter: recall relevant knowledge map content (mechanisms, source details, diffs, findings); optional Q-A skeleton for chapters with 3+ interrelated mechanisms (mix Q types: action / comparison / causal / boundary; bans: "what is X?", "how many steps?", "is X important?"); write following voice rules; chapter self-review (every claim sourced, doc-vs-source diffs flagged, no AI patterns).

Voice: logically rigorous, narrative progression, direct, occasional first-person, occasionally colloquial ("说白了" / "说实话" as seasoning not filler), professional but conversational, critical (cover strengths and weaknesses).

Per-chapter requirements: every technical claim cites source file / line / config value; source-over-docs (when they disagree, source wins, flag the diff); concrete > abstract (code snippets, config values, data flow); tables for multi-dimension comparison; stepwise/flow for complex mechanisms; no chapter-end summary sentences; **enumeration depth**: when a chapter has N parallel items (10 layers / 4 stages / 3 modes), each item gets its own paragraph with purpose (1 sentence), implementation mechanism (2-3 sentences with function/config names), design decision (1-2 sentences), concrete evidence (code snippet or config value). If an enumeration has more than 10 items, select the 5-8 items that carry the architecture or user focus, state `[选取 N/M 项]`, and list the selection criterion. If material is thin for a selected item, mark `[素材不足，待补充]` rather than glossing. Different items don't merge unless tightly coupled.

#### Optional final chapter: Engineering Migration

If confirmed, write from Phase 2 Section 5.6: 2-3 stealable design patterns (name + definition + how this project uses it + applicable scenarios + architecture formula if available), 0-2 anti-patterns (description + why not). Rules: no升华, only engineering facts; every pattern has source evidence; if only 1 valid pattern, write 1; chapter length ≈ half of others.

If 5.6 said "迁移素材不足", downgrades to 3-5 takeaway summary merged into existing final chapter, not standalone.

### Step 4: Voice Pass

See `voice-pass.md`. Mandatory. De-AI scan + style scan. Same 10 patterns apply. Technical-article specifics: hedge phrases still banned, em-dash still banned, 段末收尾总结句 still cut, 工整并列 bold 标题 still varies tone. Style scan: if user has prior technical articles in workspace, scan 1-2 for voice/length/structure preferences.

### Step 5: Write final file + delivery report

Write `.md` per `output-spec.md`. File naming: `{topic}-source-dive_{YYYY-MM-DD}.md`.

Delivery report (`voice-pass.md` Step 4): article path, word count, chapter count, Voice Pass execution (AI patterns caught), style reference used (or skipped). **Source-dive-specific**: doc-vs-source diffs found (count + brief), transferable patterns extracted (count + names), anti-patterns flagged (count).

## Output

After Voice Pass, write file. **Stop at publish confirmation.** Do NOT push, post, distribute, commit unless user explicitly asks.

## Optional: Vault integration suggestion

If `loom-maintain` skill is installed (check available skills), suggest user run it for vault integration. source-dive itself doesn't touch vault. If not installed, skip — output is self-contained.
