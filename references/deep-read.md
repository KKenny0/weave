# Deep Read Workflow

Triggered when user provides: URL / PDF / file / pasted text containing non-technical prose (papers, articles, interviews, reports, book chapters). Output: polished Chinese research article with multi-perspective debate testing, generator-based analysis, academic advisor review, anchor-based narrative.

## Phase 1: Collect

See `collect.md`. For deep-read, Phase 1 ends when sources are fetched and saved, each identified by type (paper / article / interview / report / book chapter) and length bucketed (short <3000 chars / medium 3000-10000 / long >10000 — decides serial vs parallel reading). Keep original key terms; notes in Chinese.

## Phase 2: Read

Produce one Source Brief per source.

### Step 1: Choose reading method

Pick by source type. Essay with argument → narrative reading. Academic paper → extraction (methodology, claims, evidence). Single concept → anatomy. Anything where surface isn't enough → vertical drilling.

### Step 2: Execute reading

Per source: tag each paragraph as `[骨]` (load-bearing argument) / `[肌]` (evidence/data) / `[筋]` (transition/context), then extract core narrative using 亲历→旧路→新口 (witnessed problem → prior approaches → new framing). Quality check against 9 Red Lines: mouth-test, no jargon, short words, one-thought-per-sentence, concrete, reasons-first, no filler, trust reader, honest.

### Step 2.5: Digestion filter — what enters Source Brief

Before adding an observation to Source Brief, three questions:

1. **复现性**: Does this observation appear independently in ≥2 places in the same source? (≥2: core evidence. 1 but critical: keep, tag `[单点]`. 1 and marginal: background, don't add.)
2. **生成力**: Does this observation only explain one phenomenon, or can it predict what the source would say about a new problem? (Predicts: core. Explains one: background.)
3. **专属性**: Is this unique to this source, or would any expert say it? (Unique: core. Generic common knowledge: don't add — wastes reader attention.)

All three pass: core evidence, write in detail. Two pass: keep, 1-2 sentences max. Zero-one pass: drop.

Source Brief is **not** a summary of the source. It's the evidence library Compose draws on. Stuffing background material in makes Compose confuse load-bearing walls with decoration.

### Step 3: Multi-source parallel reading (when ≥3 sources)

Spawn one background agent per source in a single message (parallel, not serial). Each produces a Source Brief covering: core claim, 骨架段 [骨] (argument), 证据段 [肌] (evidence), 问题节 (亲历→旧路→新口 narrative), key quotes, tensions with other sources or internal, claims to verify, uncertainties. Chinese output, 2-3 sentences per point, keep original key terms, don't merge content across sources.

### Step 4: Source Brief isolation

One Source Brief per source, never merge. Source Brief only references its own source — cross-source analysis is Phase 3, not Source Brief.

## Phase 3: Synthesize

Build Synthesis Pack from all Source Briefs.

### Step 1: Generator discovery (internal reasoning)

When sources ≤ 2: 4-step simplified path — lay out phenomena → list candidate generators → cut ones that can't independently explain anything → reverse-generate (use survivors to reproduce phenomena).

When ≥3 sources: full 7-step — phenomena → candidates → recursive追问 (why does each candidate generate these phenomena?) → same-source merge → cut → reverse-generate → predict + variation test (what else does this candidate predict, what conditions break it).

For each surviving candidate, internally evaluate 5 criteria: independence, necessity, generative power, simplicity, falsifiability. Write brief **Analysis Summary** (3-5 sentences): which survived, which criterion is weakest.

### Step 2: Multi-perspective debate (internal reasoning)

Skip when only 1 source — run **single-source stress test** instead: invite 1-2 imaginary challengers (devil's advocate: what would the source's main claim miss, where's the boundary case? adjacent field: what would a researcher from a neighboring field complicate or question?). Each challenger must cite source evidence. Write brief Stress Test Summary: which challenges landed, which the source survived, what's now uncertain.

When ≥2 sources: invite 3-5 real historical or contemporary people related to the topic. Each has a real stake and a clear stance; together they form a tension network (not simple pro/con); at least one comes from outside the field. Each round: every person must cite Source Brief evidence (no unsourced opinions), and respond to evidence plus other people. You as host dig one deepest crack per round (don't pave breadth), prioritize truth over harmony, and surface structural assumptions (not just retell content) when synthesizing. Write brief Stress Test Summary (3-5 sentences): convergence, divergence, evidence support.

### Step 2.5: Stall signals and loopback

If any of these fire during Step 1 or Step 2, Source Briefs aren't thick enough — return to Phase 2 for that sub-topic (not the whole article):

- **Can't write Working Thesis**: 3+ attempts, still can't summarize evidence-backed conclusion in one sentence
- **Single-source承重**: a Key Finding rests on only one Source Brief, no cross-source verification
- **Debate hangs**: invited people have nothing to say on a key point because Source Briefs lack that evidence
- **High-Risk Claims cluster**: multiple High-Risk Claims all point to the same evidence gap

Other stable sub-topics don't re-do.

### Step 3: Produce Synthesis Pack

```
## Synthesis Pack

### Key Findings
- {finding 1}
- {finding 2}

### Working Thesis
{one sentence: best-supported conclusion}

### Analysis Summary
{3-5 sentences: surviving generators, weakest criterion}

### Stress Test Summary
{3-5 sentences: convergence, divergence, evidence support}

### Merged Conclusions
- {conclusion 1}: {evidence}
- {conclusion 2}: {evidence}

### Conflicts
- {conflict}: {which perspectives/sources disagree, evidence each side}

### Evidence Weight
- {claim A}: strong / medium / weak / disputed

### High-Risk Claims
- {claim}: {why risky, failure conditions}
```

Rules: don't hide unresolved conflicts, don't manufacture false consensus; distinguish source consensus from user's own claims; flag high-risk claims; Synthesis Pack is read-only in Compose.

## Phase 4: Compose

Write the full research article from Synthesis Pack.

### Step 1: Confirm anchor

Pick one concrete anchor (specific scene / example) from Synthesis Pack that runs through the whole article. Don't switch. If one anchor can't support some chapters, introduce a sub-anchor in the same problem domain.

### Step 2: Chapter planning + hard gate

Plan final chapters (each title ≤10 字, 6-8 typical, logical dependency earlier→later). **Hard gate before writing**: every chapter must trace to a Source Brief / Synthesis Pack field.

| Chapter | Maps to |
|---|---|
| {chapter 1} | {Source Brief A section / Synthesis Pack Key Finding N} |
| ... | ... |

If a chapter can't trace: either delete it, or return to Phase 2 for that sub-topic (don't write from general knowledge). "Let me try writing it" is not allowed — every word traceable.

Write directly, don't pause for user confirmation. List chapter structure in delivery report (`voice-pass.md` Step 4). Exception: if any chapter triggered Phase 2 return mid-compose, flag explicitly.

### Step 3: Write chapter by chapter

Per chapter: recall relevant Source Brief + Synthesis Pack content, write, then self-review (mouth-test, 10 AI patterns from Voice Pass, anchor consistency).

Voice: one anchor through the whole article (don't switch), morph concepts instead of defining relationships, expose reasoning (not just conclusions), end on what the reader can do (not what to rethink), cold cuts with direct speech. Argumentative sources follow a progressive cut structure (claim → first cut → deeper cut → irreducible bottom → look back); non-argumentative (interviews, reports, news) uses freer narrative but same voice rules. Use scene-over-claim, concessive bend, rhetorical-question chaining, exploratory tone, and short hammer sentences sparingly as needed.

### Step 4: Academic advisor review (博导审稿)

Switch persona: senior advisor who has supervised 20 years of grad students in this area. Audit: argument strength (every claim sourced?), foundational premise (does it hold? if it falls, does the article survive?), logic chain (leaps? circular reasoning?), counter-intuitive insight (only deep analysis finds this? if none, not deep enough), honesty (hidden uncertainty? forced conclusions?). Per issue, give concrete revision. Fix. Re-audit until pass.

### Step 5: Voice Pass

See `voice-pass.md`. Mandatory — every output goes through de-AI scan + style scan.

## Output

After Voice Pass, write the `.md` file per `output-spec.md`. Delivery report to user. **Stop at publish confirmation.** Do NOT push, post, distribute, commit unless user explicitly asks.
