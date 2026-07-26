# Survey Workflow

Use Survey when the input is an open domain or research direction such as reinforcement learning, agent memory systems, or knowledge graph reasoning. Survey uses Waza Learn's research-to-writing sequence as its base and wraps that sequence with Weave's evidence, hold-out, comprehension, impact, and final-artifact gates.

This file replaces the former Survey implementation. Do not run the retired lens library, `Domain Use Contract`, `Domain Payoff`, or the `explain / map / evaluate / decide / enter` routing axis inside Survey. The user's exact question still controls scope and article promise, but the writing process below is the only Survey process.

If the user supplied concrete sources and wants those sources read closely, route to `deep-read.md`. A source bundle may seed Survey only when the research object remains the wider domain.

## Table of contents

- Mode Gate
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

| Mode | Run | Result |
|---|---|---|
| **Canonical Article** | Phase 1 through the agent preflight before Phase 6 | One self-contained article intended to be the only article a new reader needs |
| **Deep Research** | Phase 1 through the agent preflight before Phase 6 | A publishable research draft with a narrower completeness promise |
| **Quick Reference** | Phase 1 and Phase 2 only | Concise, evidence-typed reference notes, not a longform article |
| **Write to Learn** | Phase 3 through the agent preflight before Phase 6 | Turn an already collected domain corpus into an article without pretending collection was rerun |

Recommend `Canonical Article` for requests such as “让非专业背景的人也能读懂”, “从零讲懂”, or “一篇就够”. Recommend `Deep Research` for a bounded research question. Recommend `Quick Reference` for a fast orientation. Recommend `Write to Learn` only when a usable corpus is already in scope.

Do not silently choose a mode. The user may explicitly delegate with wording such as “按推荐模式继续”; that counts as confirmation. In a non-interactive run, require the mode in the prompt or report that the Mode Gate is waiting.

For `Canonical Article`, require:

- one section for every major subtopic inside the declared scope;
- worked examples that carry the reasoning;
- common mistakes or tempting shortcuts where evidence supports them;
- a three-to-five-item Further Reading section;
- a final check that a reader can reconstruct the promised model without opening another article.

## Phase 1: Collect

Run `context-acquisition.md`, build the working-memory Reader Contract in `reader-model.md`, and then collect sources with `collect.md`.

The load-bearing corpus is primary-source first:

- original papers, datasets, standards, official specifications, repositories, or first-party technical reports;
- strong systematic reviews, textbooks, and official documentation may orient coverage or historical synthesis, but must not replace primary evidence for a method, result, or limitation;
- generic explainers, product pages, SEO summaries, and community posts are discovery leads or practice signals, not load-bearing evidence.

For `Deep Research`, target 5–10 strong sources when the question is narrow. For a broad `Canonical Article`, target 15–20. Counts are coverage heuristics, not permission to pad the corpus. Stop only after targeted searches no longer add a major mechanism, disagreement, evidence type, or named subtopic.

For every admitted source:

1. Open the canonical page or full text.
2. Verify title, URL, author or institution, date, and stable identifier when one exists.
3. Record evidence type, availability, structural contribution, and which claims it can and cannot support.
4. Keep fetched Markdown in a session temporary directory when a local copy is needed. Do not leave source dumps or sidecars in the repository or article directory unless the user asks.

Field-wide prevalence, momentum, consensus, decline, or frontier-shift claims require trend-capable evidence. Representative examples prove existence, not prevalence.

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

Keep contradictions visible. When two sources use the same term for different objects, preserve the mismatch instead of normalizing it. When a load-bearing subtopic remains thin, return to Phase 1 rather than filling it from general knowledge.

`Quick Reference` stops here. Return concise notes that distinguish strong claims, background, contradictions, and source limits. Do not fabricate an outline, spine, or article.

## Phase 3: Outline

Create an outline before drafting prose.

For every planned section, record:

- the question the section answers;
- the claim or mechanism it advances;
- the admitted sources that support it;
- the worked example, comparison, or boundary it needs;
- what becomes newly understandable after the section.

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

If the section stalls, becomes generic, or needs unsupported connective tissue, stop and return to Phase 2 for that subtopic. Do not keep drafting around the gap.

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
5. Run `voice-pass.md`. Voice edits may change expression and rhythm, not evidence weight or spine direction.

If refinement exposes a research gap, return to the affected Digest or Fill step. Do not patch it with fluent general knowledge.

## Phase 5.5: Visual Pass

Scan the refined article for relationships that prose represents poorly. A figure is admitted only when removing it would make a supported relationship harder to recover.

### Match idea shape to representation

| Idea shape | Preferred representation |
|---|---|
| model architecture, data flow, module relation | structural or flow diagram |
| causal chain, training stages, state change | causal diagram or timeline |
| feedback, iteration, self-play | loop |
| distribution, scale effect, marginal change | ASCII curve |
| accuracy/cost, speed/quality, control/freedom | tradeoff curve |
| old/new method or metric comparison | small table or matrix |
| a case changing step by step | aligned example trace |
| an irreducible relationship | minimal formula plus plain-language translation |
| two or three sentences explain it fully | text only |

### Admission and placement

For every candidate figure:

1. State the relationship the figure adds.
2. Trace each node, arrow, curve, or comparison to admitted evidence or label it as Weave synthesis.
3. Delete it when it only rearranges nearby prose into boxes.
4. Place it only after the concept has been grounded in plain language and a concrete example.
5. Add one bold sentence as its caption.

Sparse is the default. A long article may legitimately contain only a few figures or none. Never create one figure per section.

Use Mermaid for structural relationships, compact Markdown tables for small comparisons, aligned text for example traces, and ASCII only when alignment is reliable. Keep ASCII within 80 columns. Avoid CJK labels inside ASCII diagrams when character width can break alignment; use short Latin labels plus a legend, Mermaid, or a table instead.

Do not generate a polished PNG by default. If a relationship genuinely needs a refined image, route that one figure to an image workflow and keep its claim boundary identical. Never leave a broken asset reference in the article.

## Phase 6: Self-review

Separate agent preflight from human review.

### Agent preflight

Before delivery:

1. Write the final Markdown with `status: draft`.
2. Run `article-integrity.md` and the executable article checker.
3. Read the serialized file back.
4. For `Canonical Article`, or any promise of a self-contained explanation, run the fresh-context Article Recoverability audit described in `learning-design.md`.
5. Repair failures, then repeat Refine, Visual Pass when affected, Voice Pass, Article Integrity, and recoverability.

Passing agent checks does not complete human Self-review.

### Human review

Deliver the draft and ask the user to read it linearly at least twice:

- **Pass 1**: thesis, evidence, missing bridge, contradiction, and scope;
- **Pass 2**: confusing terms, redundant passages, examples, visual usefulness, and final boundary.

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
- **No fake human evidence.** Agent checks establish artifact quality, not that a person understood, retained, or reused the article.
- **Stop at readiness confirmation.** Do not publish or commit unless the user separately asks.
