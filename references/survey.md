# Survey Workflow

Use Survey when the input is an open domain or research direction such as reinforcement learning, agent memory systems, or knowledge graph reasoning. Survey uses Waza Learn's research-to-writing sequence as its base and wraps that sequence with Weave's evidence, hold-out, comprehension, impact, and final-artifact gates.

This file replaces the former Survey implementation. Do not run the retired lens library, `Domain Use Contract`, `Domain Payoff`, or the `explain / map / evaluate / decide / enter` routing axis inside Survey. The user's exact question still controls scope and article promise, but the writing process below is the only Survey process.

If the user supplied concrete sources and wants those sources read closely, route to `deep-read.md`. A source bundle may seed Survey only when the research object remains the wider domain.

## Table of contents

- Mode Gate
- Learn pre-check
- Phase 1: Collect
- Phase 2: Digest
- Phase 3: Outline
- Spine Direction Gate
- Weave evidence gates
- Phase 4: Fill
- Phase 5: Refine
- Phase 5.5: Visual Pass
- Phase 6: Self-review
- Delivery contract
- Hard rules

## Mode Gate

Before research, ask the user to confirm one mode unless the request already names it. Put the recommended mode first and explain the difference in one line each.

| Mode | Goal | Entry | Exit |
|---|---|---|---|
| **Deep Research** | Understand a domain well enough to write about it | Phase 1 | Phase 6: publish-ready draft |
| **Quick Reference** | Build a working mental model fast, no article planned | Phase 2 | Phase 2: notes only |
| **Write to Learn** | Already have materials, force understanding through writing | Phase 3 | Phase 6: publish-ready draft |
| **Canonical Article** | One article that covers the declared scope as a self-contained reference | Phase 1 | Phase 6: single authoritative reference |

Recommend `Canonical Article` for requests such as “让非专业背景的人也能读懂”, “从零讲懂”, or “一篇就够”. Recommend `Deep Research` for a bounded research question. Recommend `Quick Reference` for a fast orientation. Recommend `Write to Learn` only when a usable corpus is already in scope. If the goal remains genuinely unclear, recommend `Quick Reference`.

Do not silently choose a mode. The user may explicitly delegate with wording such as “按推荐模式继续”; that counts as confirmation. In a non-interactive run, require the mode in the prompt or report that the Mode Gate is waiting.

Quick Reference's mode entry and exit are both Phase 2. When the user has only a topic and no usable material, run Phase 1 as a collection prerequisite, then enter Quick Reference at Phase 2; do not relabel collection as part of the mode's main sequence.

For `Canonical Article`, require:

- one section for every major subtopic inside the declared scope;
- for every declared objective or coverage obligation, an accurate mental model, an executable or inspectable operation, a common failure, and an evidence or version boundary; a heading or keyword match does not count as coverage;
- worked examples that carry the reasoning;
- common mistakes or tempting shortcuts where evidence supports them;
- a three-to-five-item Further Reading section;
- a final check that a reader can reconstruct the promised model without opening another article.

## Learn pre-check

Prefix the first Survey response line with 🥷 inline, not as its own paragraph. Support the user's thinking; do not replace it. Before entering the phases, check whether the host exposes installed `/read` and `/write` skills. Missing helpers degrade the run but do not block it:

- without `/read`, Phase 1 uses native search and fetch tools, and reports reduced coverage for paywalled, JavaScript-heavy, or platform-specific pages;
- without `/write`, Phase 5 uses the manual scan in `voice-pass.md` and reports that the upstream writing helper was unavailable.

Do not infer helper availability from a host name. Check actual capabilities, and keep Weave's context, evidence, hold-out, and artifact gates around the Learn base rather than treating those extensions as replacements for a Learn phase.

## Phase 1: Collect

Run `context-acquisition.md`, build the working-memory Reader Contract in `reader-model.md`, and then collect sources with `collect.md`.

For every source, preserve Learn's three ordered operations without merging them:

1. **Discover**: search and map candidate URLs first. Deep-search the two or three subtopics most likely to change the article. Discovery produces a URL list; it does not fetch or summarize content.
2. **Fetch**: send every selected URL through `/read` when installed. If `/read` is unavailable, use the native fallback and record the coverage degradation.
3. **File**: give `/read` the research source directory when one exists; otherwise use its returned session-temporary path. Index or move the fetched file into the subtopic map. Move it; do not refetch it.

The load-bearing corpus uses primary or first-party sources for methods, results, mechanisms, product behavior, and limitations:

- original papers and datasets carry research methods, measured results, and experimental limitations;
- standards, official specifications and documentation, official repositories, and first-party technical blogs or reports may carry the product or API behavior they define or demonstrate;
- strong systematic reviews and textbooks may orient coverage or historical synthesis as Weave context, but cannot replace primary evidence for a method, result, mechanism, or limitation;
- generic explainers, product pages, SEO summaries, and community posts are discovery leads or practice signals, not load-bearing evidence.

For `Deep Research`, target 5–10 strong sources when the question is narrow. For a broad `Canonical Article`, target 15–20. Counts are coverage heuristics, not permission to pad the corpus. Stop only after targeted searches no longer add a major mechanism, disagreement, evidence type, or named subtopic.

For every admitted source:

1. Open the canonical page or full text.
2. Verify title, URL, author or institution, date, and stable identifier when one exists.
3. Record evidence type, availability, structural contribution, and which claims it can and cannot support.
4. Keep fetched Markdown in a session temporary directory when a local copy is needed. Do not leave source dumps or sidecars in the repository or article directory unless the user asks.

Field-wide prevalence, momentum, consensus, decline, or frontier-shift claims require trend-capable evidence. Representative examples prove existence, not prevalence.

Collect visual evidence before choosing visuals. When a source contains an architecture, flow, causal chain, loop, curve, trade-off, comparison matrix, example trace, or indispensable equation, record the exact source location, what relationship it supports, and what it does not support. This is evidence inventory, not permission to draw a figure. Do not copy a source figure whose relationship can be taught more cheaply in prose.

## Phase 2: Digest

Read every admitted source fully enough to reconstruct its argument or mechanism. Digesting is not summarizing. The purpose is to decide what can carry the article.

For each candidate claim, apply three tests:

1. Does it recur in at least two materially different contexts inside the source?
2. Does it explain, predict, or change how a new problem is handled?
3. Is it specific to this source or evidence set rather than generic background?

Score by the number of tests passed:

- **2–3**: keep for the outline;
- **1**: keep as background or a boundary;
- **0**: cut.

Build a working-memory Digest Note for each source:

- verified identity and evidence type;
- the problem or question it addresses;
- load-bearing mechanism, finding, or reasoning move;
- exact evidence that supports it;
- result of the three claim tests;
- contradiction, uncertainty, or non-transferable condition;
- article role: `outline`, `background`, `boundary`, or `cut`.

For each load-bearing relationship, also record its idea shape, the element-level evidence available for any node, arrow, curve, comparison, or formula, and the boundary that a reader must see immediately after it. Default the representation to text. A visual remains only a candidate when prose would make the relationship materially harder to recover.

Keep contradictions visible. When two sources use the same term for different objects, preserve the mismatch instead of normalizing it. When a load-bearing subtopic remains thin, return to Phase 1 rather than filling it from general knowledge.

### Conversation or review distillation

When the research object is a recent conversation, project review, scorecard, or diagnostic report, treat it as raw material rather than durable truth. Prefer already-distilled summaries first and open raw transcripts only to verify a disputed detail. Build a candidate matrix with source or project, repeated failure, transferable rule, target layer, evidence count, and redaction risk. Promote only cross-source support or a repeated failure in the same project family; remove dated line numbers, private paths, one-machine setup, and repo-specific commands unless the output is for that repository. If the user instead wants close reading of one supplied review, route to Deep Read.

`Quick Reference` stops here. Return concise notes that distinguish strong claims, background, contradictions, and source limits. Do not fabricate an outline, spine, or article.

## Phase 3: Outline

Create an outline before drafting prose.

For every planned section, record:

- the question the section answers;
- the claim or mechanism it advances;
- the admitted sources that support it;
- the worked example, comparison, or boundary it needs;
- what becomes newly understandable after the section.

When a relationship may need a visual, the section plan must preserve this teaching order:

1. explain the concept in plain language;
2. ground it with a concrete worked example;
3. add an optional visual only if the deletion test predicts a real comprehension loss;
4. place the supporting evidence and applicability boundary immediately after the visual.

Record the candidate idea shape and preferred representation in working memory. `text only` is a positive decision, not a missing asset. Do not draft the visual during Outline.

Cut a section with no source mapping or return to Phase 1 or Phase 2 for that subtopic. Do not preserve generic background merely because surveys usually contain it. Named subtopics are coverage obligations unless the evidence boundary makes one impossible.

For `Canonical Article`, verify that the outline covers the declared domain scope, includes worked examples and common mistakes, and ends with Further Reading. Do not draft the opening yet.

## Spine Direction Gate

Run this gate after the outline and before any Phase 4 prose. The admitted spine becomes the article's load-bearing direction, not a decorative theme added after drafting.

### Generate genuinely different candidates

Derive two or three candidates from the digested evidence and current outline. Use these emphases when they fit:

| Spine emphasis | Best fit | Required difference |
|---|---|---|
| **Throughline** | full survey, novice primer, historical evolution | one concrete object changes state across the whole article |
| **Dialectical argument** | a counterintuitive thesis with real opposing evidence | sections build and resolve a contradiction rather than tour subtopics |
| **Issue or warning center** | evidence converges on a consequential failure, risk, or claim | sections accumulate toward the issue and its boundary |

The candidates must produce materially different articles. Each candidate must change at least two of: chapter order, evidence grouping, comparison set, causal explanation, included material, excluded material, or final boundary. Paraphrased titles over the same outline count as one candidate.

Run the admission gates in `frame-selection.md` before showing candidates. Do not show an evidence-incompatible choice merely to reach a count. If fewer than two candidates survive after one evidence-repair loop, tell the user and ask whether to proceed with the single valid direction or narrow the question.

Present the surviving candidates as a single-choice decision, recommended first. For each, show only:

- spine type and one-sentence thesis;
- through-object when applicable;
- how the article would be structurally different;
- what it would cut or background;
- its main evidence boundary.

Do not expose internal scoring or Candidate Frame Brief fields.

### Require an explicit choice

Stop before Phase 4 until the user selects a candidate or explicitly delegates the recommended choice. Never infer confirmation from silence. A prompt such as “脊柱按推荐项继续” is explicit delegation.

After selection, record a compact working-memory Spine Contract:

- type;
- thesis;
- concrete through-object when applicable;
- section order;
- section-source map;
- cuts and backgrounded material;
- final boundary.

The Spine Contract is not a persisted artifact and must not appear as a field dump in the article or delivery report.

### Throughline requirements

A through-object must be a concrete noun or inspectable mechanism. Prefer “奖励信号”, “上下文窗口”, or “缓存条目” over abstractions such as “学习”, “智能”, or “效率”.

Each load-bearing body section begins with one short `📍` statement that answers:

- where the object comes from at this point;
- what state it is in;
- what changed since the previous section;
- which new problem that change creates.

The marker is a rhythm and state-tracking device. It cannot substitute for explanation or evidence.

## Weave evidence gates

Survey does not run a second frame-selection process. Its admitted spine candidates are its Candidate Frames.

After the user selects a spine and before Phase 4:

1. In audit-sensitive runs, persist the allowlisted pre-reveal artifact from `frame-selection.md` without user rationale or private context.
2. Reveal the pre-designated hold-out and test the selected spine without changing its core parts after the fact.
3. Run the four-probe Comprehension Gate in `reader-model.md`.
4. Repair the user's initial question when the evidence requires it.
5. Run `impact-pass.md` against the evidence model and selected spine. Survey has no Domain Payoff.

If a hold-out miss or comprehension repair changes the thesis, through-object, section order, or final boundary materially, invalidate the choice and present the repaired candidates again. Do not keep the user's prior selection as theater after its evidence basis has changed.

## Phase 4: Fill

Draft one section at a time through the selected Spine Contract.

Before writing a section, check:

- it serves the selected thesis;
- its load-bearing claims map to admitted sources;
- its prerequisites have already been supplied;
- its example performs reasoning rather than decoration;
- its boundary or uncertainty remains visible.

For a declared `Canonical Article` objective, the section must also show the operation or a clearly labeled inspectable skeleton, the failure it exposes, and the boundary on what the reader can claim after completing it. If one element is missing, return to Digest or narrow the completion promise; do not call the objective covered.

Write the plain-language concept and worked example before materializing any candidate visual. A visual placeholder may name the relationship and evidence location, but it cannot contain unsupported nodes or arrows and must be deleted if the prose and example already make the relationship easy to recover.

If the section stalls, becomes generic, or needs unsupported connective tissue, stop and return to Phase 2 for that subtopic. Concrete stall signals include an opening sentence rewritten three times without settling, a single-source claim with no cross-check, a source missing from Phase 1, or a claim the writer cannot explain aloud. Do not keep drafting around the gap.

After each section:

- cut or merge material that does not serve the spine;
- verify that it adds something the previous section could not;
- for a throughline, verify that the `📍` state change is concrete and consistent;
- preserve disagreement and source attribution;
- keep the opening unwritten until the body is stable.

For `Canonical Article`, include the promised worked examples, common mistakes, and self-contained explanations. Recommended sources extend the article; they do not carry prerequisites the article promised to supply.

## Phase 5: Refine

Refine the complete draft without introducing new unsupported claims.

1. Map all headings, tables, lists, formulas, and existing figures.
2. Remove cross-section repetition, prose that merely rereads a table, and whole paragraphs that no longer serve the spine.
3. Check transitions, prerequisite order, terminology, and the continuity of the through-object.
4. Write the opening last so it promises the article that now exists.
5. Revisit every visual candidate against its digested idea shape, prose-first order, element-level evidence, and immediate boundary. Do not create new claims while redesigning a figure.
6. Invoke `/write` for AI-pattern stripping when installed, then run `voice-pass.md` for Weave-specific expression and style checks. If `/write` is unavailable, use the manual scan in `voice-pass.md` and report the degradation. Voice edits may change expression and rhythm, not evidence weight or spine direction.

If refinement exposes a research gap, return to the affected Digest or Fill step. Do not patch it with fluent general knowledge.

## Phase 5.5: Visual Pass

Finalize the visual candidates carried through Collect, Digest, Outline, Fill, and Refine. This pass is the last admission, placement, and rendering gate, not the first time the workflow thinks about visual form. A figure is admitted only when removing it would make a supported relationship harder to recover.

### Match idea shape to representation

| 论文中的思想形状 | 优先表征 |
|---|---|
| 模型架构、数据流、模块关系 | 结构图或流程图 |
| 因果链、训练过程、状态变化 | 因果图或时间轴 |
| 反馈、迭代更新、自我强化 | 回路图 |
| 分布、尺度效应、边际变化 | ASCII 曲线 |
| 准确率与成本、速度与质量 | trade-off 曲线 |
| 旧指标与新指标反复对照 | 小表格或二维矩阵 |
| 一个案例如何逐步变化 | 对齐的 example trace |
| 公式就是不可替代的核心关系 | 一个最小公式，加人话翻译 |
| 两三句话已经足够 | 纯文字 |

### Admission and placement

For every candidate figure:

1. State the relationship the figure adds.
2. Trace each node, arrow, curve, or comparison to admitted evidence or label it as Weave synthesis.
3. Delete it when it only rearranges nearby prose into boxes.
4. Place it only after the concept has been grounded in plain language and a concrete example.
5. Put exactly one standalone `<!-- weave-visual -->` marker immediately before the retained visual.
6. Add one bold sentence as its caption, then put the supporting evidence and applicability boundary immediately after it.
7. Run the standalone test: a reader who sees only the figure, caption, evidence, and boundary can say which concepts act on which others and what judgment the paper changes, but cannot infer a conclusion beyond the experiments.

Sparse is the default. A long article may legitimately contain only a few figures or none. Never create one figure per section.

Use Mermaid for structural relationships, compact Markdown tables for small comparisons, aligned text for example traces, and ASCII only when alignment is reliable. The marker applies to every retained representation, including Mermaid, visual tables, traces, formulas, images, and ASCII. Every ASCII diagram or curve must use a paired Org example block with the exact, case-insensitive delimiters `#+begin_example` and `#+end_example`; never use a Markdown code fence, an indented code block, or otherwise naked ASCII art for it. Keep every line inside the block at or below 80 ASCII columns. Do not nest Org example blocks. Avoid CJK labels inside ASCII diagrams when character width can break alignment; use short Latin labels plus a legend, Mermaid, or a table instead.

Do not generate a polished PNG by default. If a relationship genuinely needs a refined image, route that one figure to an image workflow and keep its claim boundary identical. Never leave a broken asset reference in the article.

## Phase 6: Self-review

Separate agent preflight from human review.

### Agent preflight

Before delivery:

1. Write the final Markdown with `status: draft`.
2. Run `article-integrity.md` and the executable article checker.
3. Read the serialized file back.
4. Recheck every retained visual for exactly one `<!-- weave-visual -->` marker, prose-and-example-before-placement, paired Org blocks, 80-column width, immediate evidence and boundary, and standalone evidence calibration; reconcile the article marker count with the delivery report's admitted count.
5. For `Canonical Article`, or any promise of a self-contained explanation, run the fresh-context Article Recoverability audit described in `learning-design.md`.
6. Repair failures, then repeat Refine, Visual Pass when affected, Voice Pass, Article Integrity, and recoverability.

Passing agent checks does not complete human Self-review.

### Human review

Deliver the draft and ask the user to read it linearly at least twice:

- **Pass 1**: thesis, evidence, missing bridge, contradiction, and scope;
- **Pass 2**: confusing terms, redundant passages, examples, visual usefulness, and final boundary. For every visual, read it with only its caption, evidence, and boundary: reject it if the relationship is unclear, if it merely reformats the preceding summary, or if it implies more than the cited experiments support.

Apply the user's review and rerun the affected gates. Change `status` from `draft` only after the user confirms readiness. Publication confirmation means the content is ready; it does not authorize posting, pushing, distributing, committing, or creating a release.

## Delivery contract

For a longform Survey run, write `{topic}-survey_{YYYY-MM-DD}.md` with the Survey fields in `output-spec.md`.

The delivery report states:

- Survey mode;
- article path, word count, and chapter count;
- selected spine type and through-object when applicable;
- source count by evidence type and material coverage limits;
- hold-out and Comprehension Gate status;
- Impact Pass result;
- Voice Pass result;
- Visual Pass candidate, admitted, and deleted counts;
- Article Integrity and Article Recoverability status;
- `Human Self-review: pending` or `confirmed`.

Do not reproduce the Reader Contract, Digest Notes, Spine Contract, Comprehension probes, visual evidence ledger, or recoverability answers.

## Hard rules

- **Learn is the base.** Do not restore the retired Survey lens library or dual-outcome composition system.
- **No phase skipping.** Fill never begins before the outline, spine admission, explicit user choice, hold-out, and Comprehension Gate are solid.
- **No silent mode or spine choice.** Continue only after explicit selection or delegation.
- **No unsupported spine.** User choice operates only among evidence-admitted candidates.
- **No post-hoc spine.** Do not draft first and label the result later.
- **No abstract through-object.** A throughline must track a concrete object or mechanism whose state can be named.
- **Every section serves the spine.** Cut or merge sections that do not.
- **Contradictions remain visible.** Do not smooth disagreements into a universal story.
- **Visuals are admitted, not decorated.** Delete prose reflow, unsupported arrows, premature diagrams, and overclaiming summaries.
- **Visual judgment spans every phase.** Collect evidence, Digest idea shape, Outline placement, Fill prose and example first, Refine representation, Visual Pass final admission, and Self-review evidence calibration.
- **Visual markers close the audit loop.** Every retained visual has exactly one standalone `<!-- weave-visual -->` marker immediately before it, and the report's admitted count equals the article's marker count.
- **Org ASCII is mechanical.** Every ASCII visual uses one paired `#+begin_example` / `#+end_example` block, no Markdown fence, no nesting, and no line wider than 80 ASCII columns.
- **No fake human evidence.** Agent checks establish artifact quality, not that a person understood, retained, or reused the article.
- **Stop at readiness confirmation.** Do not publish or commit unless the user separately asks.
