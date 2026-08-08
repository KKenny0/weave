# Anthropic API Course Benchmark

This is the durable benchmark contract for a Survey `Canonical Article` run over Anthropic Skilljar's current **Building with the Claude API** course:

- Course: `https://anthropic.skilljar.com/claude-with-the-anthropic-api?next=%2Fclaude-with-the-anthropic-api%2F287726`
- Public course claim: 84 lectures, 8.1 hours of video, 10 quizzes, and a certificate of completion.
- Public curriculum: seven sections whose displayed lecture counts sum to 87, not 84. Preserve that contradiction; do not silently normalize the denominator or invent which three items are excluded.
- Evidence rule: record access date and canonical public page. Login-only lesson bodies may strengthen a run when available, but this rubric never requires or invents hidden lesson titles.
- Artifact rule: exploratory drafts stay outside the repository. The immutable baseline and saturated comparison artifact are persisted as `evals/anthropic-course-baseline.md` and `evals/anthropic-course-saturated.md`; record repository paths, SHA-256 values, scores, defects, and workflow changes in the ledger.

The benchmark tests course-completion coverage, not keyword density. A draft covers an objective only when a new reader can recover the concept, perform the operation, avoid its common failure, and state its boundary from the serialized article.

## Public course inventory

| Section | Displayed lectures | Coverage obligation |
|---|---:|---|
| Getting started with Claude | 16 | API setup, requests, responses, conversations, streaming, and structured output |
| Prompt engineering & evaluation | 16 | prompt construction, datasets, automated evaluation, and grading |
| Tool use with Claude | 14 | tool definitions, execution loop, multi-tool behavior, and external services |
| Retrieval augmented generation | 10 | chunking, retrieval, hybrid search, reranking, and answer grounding |
| Model Context Protocol (MCP) | 12 | MCP concepts, tools, resources, prompts, client/server lifecycle, and data connections |
| Claude Code & Computer Use | 8 | the two application surfaces, their operating model, and supported use boundaries |
| Agents and workflows | 11 | chaining, parallelization, routing, agents with tools, environment checks, and workflow/agent choice |
| **Displayed total** | **87** | conflicts with the public 84-lecture summary and must remain visible |

The seven public objectives are:

- **O1**: Make API requests to Claude models and handle responses.
- **O2**: Implement multi-turn conversations, streaming, and structured output generation.
- **O3**: Build and evaluate prompts systematically using automated testing pipelines.
- **O4**: Create custom tools and integrate Claude with external services.
- **O5**: Design and implement RAG systems with hybrid search and reranking.
- **O6**: Use MCP to connect Claude to various data sources.
- **O7**: Understand common workflows and agent architectures.

## 100-point rubric

### A. Section coverage — 40 points

Score five binary probes for each of the seven public sections:

1. the section's load-bearing concepts form an accurate mental model;
2. at least one operation or worked example makes the model usable;
3. a common failure is demonstrated or diagnosed;
4. evidence, API-version, and applicability boundaries are explicit;
5. prerequisites and the connection to the course-wide system spine are supplied.

For section `i`, let `c_i` be its displayed lecture count and `p_i` the number of passed probes from 0 to 5. Compute `A = 40 × Σ(c_i × p_i) / (87 × 5)`, rounded once to one decimal place. Each probe is pass/fail; a named heading without a usable model scores zero on probe 1. Report the separate 84-lecture public claim beside the 87-based score.

### B. Objective completion — 25 points

Score O1–O7 as binary outcomes. An objective passes only when the article supplies its concept, an executable or inspectable operation, a common failure, and a real boundary. Compute `B = 25 × passed objectives / 7`, rounded once to one decimal place. A keyword match, copied course objective, or API snippet without explanation fails the objective; there is no partial objective credit.

### C. Correctness and evidence — 20 points

- 5 points: course identity, public statistics, section names, counts, and objectives match the opened public course page;
- 5 points: load-bearing technical claims trace to the course or current official Anthropic documentation rather than secondary summaries;
- 5 points: API-version drift, model-specific behavior, deprecated examples, and retrieval date remain visible;
- 5 points: the 84-versus-87 lecture-count conflict, unavailable evidence, applicability limits, and Weave synthesis remain explicit.

### D. Learnability and integration — 10 points

- 3 points: prerequisites and dependency order let a new reader enter each later section without external repair;
- 3 points: worked examples expose the operation and its failure, including implementation probes required by A and B;
- 2 points: one coherent system spine connects API basics, evaluation, tools, RAG, MCP, application surfaces, and agents/workflows;
- 2 points: common mistakes, decision conditions, and boundaries appear where the tempting shortcut arises.

### E. Artifact and visual integrity — 5 points

- 2 points: the serialized article passes Article Integrity and Article Recoverability;
- 2 points: visual judgment spans Collect, Digest, Outline, Fill, Refine, final Visual Pass, and Self-review; zero visuals is valid;
- 1 point: every retained visual follows prose and a concrete example, is immediately followed by evidence and applicability boundary, and every ASCII visual uses one paired `#+begin_example` / `#+end_example` block with no nesting or content line wider than 80 ASCII columns.

## Hard fails

Any hard fail caps the run below passing regardless of the arithmetic score:

- an invented course lesson, objective, quotation, API behavior, or completion claim;
- a missing public section or objective hidden by changing the denominator;
- the 84-versus-87 contradiction silently resolved or omitted;
- a load-bearing code example that is syntactically broken, uses an unavailable API without a version boundary, or cannot demonstrate the promised operation;
- a factual claim supported only by a secondary summary when primary course or official documentation evidence is available;
- a visual that adds unsupported nodes, arrows, curves, comparisons, or conclusions;
- Markdown-fenced, naked, nested, unclosed, or over-80-column Survey ASCII art;
- failed `scripts/check-article.ps1`, failed `scripts/check-run.ps1`, or failed fresh-context Article Recoverability;
- agent preflight reported as completed human Self-review.

## Decision thresholds

- **Pass**: at least 85/100, with no hard fail.
- **Saturation candidate**: at least 92/100, with no hard fail.
- **Saturation**: a saturation candidate whose final adversarial review finds no supported coverage gap, no failed deterministic or recoverability gate, and no proposed workflow change with a concrete defect, affected rubric row, and predicted score gain.

A fluent draft, a green static check, or lack of another idea is not saturation evidence.

## Run ledger

Never overwrite a prior row. Score the baseline before changing the workflow.

### Authoritative baseline atomic record

The binary section probes below are the auditable inputs to A. `1` means pass and `0` means fail; `p_i` is the row sum.

| Section | c_i | Mental model | Operation | Common failure | Boundary | Prerequisite/integration | p_i |
|---|---:|---:|---:|---:|---:|---:|---:|
| Getting started with Claude | 16 | 1 | 0 | 1 | 1 | 1 | 4 |
| Prompt engineering & evaluation | 16 | 1 | 1 | 1 | 1 | 1 | 5 |
| Tool use with Claude | 14 | 1 | 0 | 1 | 1 | 1 | 4 |
| Retrieval augmented generation | 10 | 1 | 0 | 1 | 1 | 1 | 4 |
| Model Context Protocol (MCP) | 12 | 1 | 0 | 1 | 1 | 1 | 4 |
| Claude Code & Computer Use | 8 | 1 | 0 | 1 | 1 | 1 | 4 |
| Agents and workflows | 11 | 1 | 1 | 1 | 1 | 1 | 5 |

Thus `Σ(c_i × p_i) = 375`, so `A = 40 × 375 / 435 = 34.5` after the specified one-decimal rounding.

The objective verdicts below are the auditable inputs to B. A pass requires all four atomic probes.

| Objective | Concept | Operation | Common failure | Boundary | Pass |
|---|---:|---:|---:|---:|---:|
| O1 | 1 | 0 | 1 | 1 | 0 |
| O2 | 1 | 0 | 1 | 1 | 0 |
| O3 | 1 | 1 | 1 | 1 | 1 |
| O4 | 1 | 0 | 1 | 1 | 0 |
| O5 | 1 | 0 | 1 | 1 | 0 |
| O6 | 1 | 0 | 1 | 1 | 0 |
| O7 | 1 | 1 | 1 | 1 | 1 |

The remaining rubric components are also stored atomically:

| Rubric | Component 1 | Component 2 | Component 3 | Component 4 | Score |
|---|---:|---:|---:|---:|---:|
| C | 5 | 5 | 4 | 4 | 18.0 |
| D | 3 | 0 | 2 | 2 | 7.0 |
| E | 0 | 0 | 0 | - | 0.0 |

Thus `passed objectives = 2`, so `B = 25 × 2 / 7 = 7.1` after the specified one-decimal rounding. The stored total is `34.5 + 7.1 + 18.0 + 7.0 + 0.0 = 66.6`.

### Saturated comparison atomic record

The saturated artifact is scored with the same binary inputs. All section probes pass:

| Section | c_i | Mental model | Operation | Common failure | Boundary | Prerequisite/integration | p_i |
|---|---:|---:|---:|---:|---:|---:|---:|
| Getting started with Claude | 16 | 1 | 1 | 1 | 1 | 1 | 5 |
| Prompt engineering & evaluation | 16 | 1 | 1 | 1 | 1 | 1 | 5 |
| Tool use with Claude | 14 | 1 | 1 | 1 | 1 | 1 | 5 |
| Retrieval augmented generation | 10 | 1 | 1 | 1 | 1 | 1 | 5 |
| Model Context Protocol (MCP) | 12 | 1 | 1 | 1 | 1 | 1 | 5 |
| Claude Code & Computer Use | 8 | 1 | 1 | 1 | 1 | 1 | 5 |
| Agents and workflows | 11 | 1 | 1 | 1 | 1 | 1 | 5 |

Thus `Σ(c_i × p_i) = 435`, so saturated `A = 40.0`.

All objective probes also pass:

| Objective | Concept | Operation | Common failure | Boundary | Pass |
|---|---:|---:|---:|---:|---:|
| O1 | 1 | 1 | 1 | 1 | 1 |
| O2 | 1 | 1 | 1 | 1 | 1 |
| O3 | 1 | 1 | 1 | 1 | 1 |
| O4 | 1 | 1 | 1 | 1 | 1 |
| O5 | 1 | 1 | 1 | 1 | 1 |
| O6 | 1 | 1 | 1 | 1 | 1 |
| O7 | 1 | 1 | 1 | 1 | 1 |

| Rubric | Component 1 | Component 2 | Component 3 | Component 4 | Score |
|---|---:|---:|---:|---:|---:|
| C | 5 | 5 | 5 | 5 | 20.0 |
| D | 3 | 3 | 2 | 2 | 10.0 |
| E | 2 | 2 | 1 | - | 5.0 |

Thus `passed objectives = 7`, so saturated `B = 25.0`. The saturated total is `40.0 + 25.0 + 20.0 + 10.0 + 5.0 = 100.0`.

| Run | Date | Draft identifier and SHA-256 | A /40 | B /25 | C /20 | D /10 | E /5 | Total | Hard fails | Largest defects | Workflow change before next run |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---|---|
| Initial self-assessment (non-authoritative) | 2026-08-08 | `evals/anthropic-course-baseline.md`; `e0635935c77d92e5a8ed8f70ec29371370fe59ebc0ec15a6e5d12a953cf1bbc8` | 38.0 | 23.0 | 13.0 | 6.0 | 2.0 | 82.0 | silent spine; single source; no hold-out, Comprehension Gate, or Impact Pass; no auditable Voice/Visual counts; no checker or recoverability run; Human Self-review pending | weak worked implementation and unaudited process despite broad topical coverage; scores predate the reproducible binary-probe rubric | restore the complete Learn base and Weave gates, carry visual decisions across phases, add deterministic Org ASCII checks, then obtain an authoritative rescore |
| Authoritative rescore | 2026-08-08 | `evals/anthropic-course-baseline.md`; `e0635935c77d92e5a8ed8f70ec29371370fe59ebc0ec15a6e5d12a953cf1bbc8` | 34.5 | 7.1 | 18.0 | 7.0 | 0.0 | 66.6 | none established; Article Integrity, recoverability, and visual-process evidence were unverified | five of seven objectives lacked an executable operation; five sections had no worked implementation; visual and artifact gates had no auditable trail | preserve the complete Learn base, require worked operations and failures, carry visual judgment across phases, and execute integrity plus fresh-context recovery gates |
| Iteration 1 | 2026-08-08 | external compact draft; `e7638f468982e565eb79ecb08456f881426b03797d2beb1a3594321835d72955` | — | — | — | — | — | — | failed fresh-context Article Recoverability | multi-turn, tool, RAG, and MCP operations remained descriptive; the figure omitted the observation loop and workflow/agent branch condition | require every objective to expose an operation, failure, and boundary rather than accepting topical coverage |
| Iteration 2 | 2026-08-08 | external complete draft; `0ea20b1cf36d82ffae76eba2f5d3fdf6b243123293ce235d97f61c4b76c6e976` | 38.2 | 17.9 | 20.0 | 9.0 | 3.0 | 88.1 | failed fresh-context Article Recoverability | O2 and O6 lacked complete operations; Claude Code and Computer Use lacked a reproducible command or observation trace; cross-phase visual evidence was unaudited | add minimal executable or inspectable loops for streaming/schema, evals, tools, RAG, MCP, and application surfaces; preserve a cross-phase visual audit |
| Iteration 3 — saturated | 2026-08-08 | `evals/anthropic-course-saturated.md`; `5354efc7aa016fdae6a4031eedc5ec8809c538bf877475544723fce019764208` | 40.0 | 25.0 | 20.0 | 10.0 | 5.0 | 100.0 | none | no failed A or B probe; deterministic gates, fresh-context recoverability, visual count reconciliation, evidence calibration, and adversarial review passed; Human Self-review remains pending and is not reported as agent-completed | saturated within the public-evidence and minimum-teaching-experiment scope; no remaining supported defect predicts a rubric gain |

## Iteration 3 cross-phase visual audit

- **Collect** recorded four relationship candidates. The tool loop is supported by the official tool-use protocol; the workflow branch by *Building Effective AI Agents*; the course-summary map only by section presence, not causal order; the RAG curve only by three Contextual Retrieval measurements in one experimental setting.
- **Digest** classified the tool loop as a feedback relation and the workflow candidate as parallel paths meeting a gate. It rejected causal arrows for the course summary and a continuous curve for the three RAG points because those shapes exceeded the evidence.
- **Outline** placed both admitted candidates after plain-language explanation and the `T-2048` example, followed immediately by source and applicability limits. The deleted course summary stayed prose; RAG stayed a diagnostic trace and labeled pseudocode.
- **Fill** materialized no new node or claim before the prose and example were stable.
- **Refine** retained the tool loop because removal obscured request, execution, and result direction; retained the workflow branch because removal obscured the parallel join; deleted the summary map as prose reflow; deleted the RAG curve as unsupported interpolation.
- **Visual Pass** reconciled `candidates=4, admitted=2, deleted=2` with two serialized `<!-- weave-visual -->` markers.
- **Self-review** recovered the tool proposal/application execution/result loop and the workflow parallel-query/gate decision from each figure alone, while the captions prevented inferences about success rates, complete exception coverage, or agent autonomy. Agent preflight passed; Human Self-review remains pending.

## Defect analysis

For each failed or partial row, record:

- the exact missing reader capability and affected section or objective;
- whether the cause is missing evidence, weak digestion, outline order, unsupported Fill, over-aggressive Refine, visual overclaim, or final-file failure;
- the smallest workflow change predicted to improve that rubric row without weakening another;
- the rerun evidence that confirms or refutes the prediction.

Do not optimize one draft directly while leaving the workflow defect intact. Do not add a verifier for a judgment that cannot fail deterministically.

## Saturation gate

The final ledger row may say `saturated` only when it reaches at least 92 points, has no hard fail, satisfies every accessible public objective at the evidence level available, names any unavailable evidence, passes all artifact gates, and leaves no evidence-backed optimization with a predicted rubric gain.
