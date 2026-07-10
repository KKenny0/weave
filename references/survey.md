# Survey Workflow

Triggered when user provides: domain name / research direction (e.g., "RAG", "agent memory systems", "knowledge graph reasoning"). Output is a 学案体 Chinese domain map covering research programs, core disputes, evolution timeline, open problems, and entry recommendations.

This workflow is for **mapping a domain**, not deep-reading specific sources. If user has specific sources, route to `deep-read.md` instead.

## Table of Contents

- Phase 1: Scout — build source catalog with structural roles (5 steps)
- Phase 2: Map — structure catalog into 5 modules (research programs / core disputes / evolution / open problems / entry recommendations)
- Phase 3: Compose — write 学案体 domain map

## Phase 1: Scout

Build a structured source catalog. Goal: identify structural roles sources play, not read every paper in depth (that's deep-read's job).

### Step 1: Parse input

topic (domain name or research direction; if too broad like "AI" or "CS", suggest narrowing to sub-field); scope (`broad` for whole-domain, `focused` for specific sub-field/problem; default `broad`); context (user's research intent — use to skip redundant work).

### Step 2: Multi-angle web search

3-5 rounds of WebSearch with different query angles. Per `SKILL.md` Pre-check fetch budget: 3 attempts max per source. Suggested rounds: (1) surveys/overviews (`"{topic}" survey OR review OR 综述 OR "state of the art"`); (2) foundational work (`"{topic}" foundational OR seminal OR "key papers" OR 经典`); (3) core disputes (`"{topic}" debate OR controversy OR "open question" OR 争议`); (4) frontier (`"{topic}" "recent advances" OR "future directions" OR "open problems"`); (5) optional Chinese resources (`"{topic}" 综述 OR 教程 OR 研究现状`).

After each round: scan titles + abstracts, drop obviously irrelevant. Keep 15-30 candidate sources.

### Step 3: Quick-read filter

For each candidate: title + abstract + intro + conclusion only. Don't full-read.

Tag structural role per source: 奠基性 (widely cited, defines core concepts/terms), 综述性 (systematic review), 桥梁性 (connects routes/sub-fields), 前沿性 (last 1-2 years, new methods/questions), 争议性 (challenges consensus). Tag domain label (which program/school, approximation OK). Tag availability: 全文可达 / 仅摘要 / 付费墙 (flag for user).

### Step 4: Deep search

Targeted searches based on Round 1-5 findings: important program but material thin → search that program's key works; core dispute found but one side thin → supplement weaker side; time gap in catalog → try to fill.

### Step 5: Build Source Catalog

```markdown
# Source Catalog — {topic}

> Domain: {topic}
> Scope: {scope}
> Date: {YYYY-MM-DD}

| ID | Title | Source | Structural role | Domain label | Availability | Key finding |
|----|-------|--------|-----------------|--------------|--------------|-------------|
| S1 | ... | URL | 奠基性 | Program A | 全文 | Defined concept X |
| ... |
```

Rules: total 15-40 sources; each research program gets at least 2-3 representatives; frontier sources ≤ 1/3 of total; if a direction is obviously thin, mark `[覆盖度有限: {direction}]` at catalog end.

**Completion check**: catalog with structural roles exists, rough impression of domain (how many main directions, where disputes live), coverage assessment (which directions well-covered, which thin).

## Phase 2: Map

Structure the catalog into a domain map. Five modules, each with concrete steps. This phase is **not** "read more sources" — it's "place existing sources into correct structural positions".

### Module 1: Research programs

A domain usually has multiple research programs simultaneously. Each program has a hard core (unquestioned basic commitment) and a positive heuristic (what followers should research next).

Group catalog sources by core commitment (are they answering the same basic question? what unquestioned premises do they share?). Each cluster is a program — usually 2-5 per domain. For each program identify:

- **Hard core**: what it considers unquestionable (infer from shared premises across multiple papers, don't extract from single-paper claims; hard core is what papers assume without arguing)
- **Protective belt**: adjustable assumptions around the hard core (when counter-examples appear, the belt adjusts first, not the core)
- **Representative work**: 2-3 most important products of the positive heuristic
- **Status**: progressive (producing new predictions/discoveries, leading field) / degenerating (mostly patching counter-examples) / neutral (mark if uncertain, don't force)

Inter-program relationships: complementary (different-layer problems, coexist) / competing (different answers to same question, exclusive) / contained (one is special case of another) / evolved (split off).

### Module 2: Core disputes

Map arguments via Issue (question needing answer) → Position (one answer) → Argument (reason for/against). Usually 2-4 core disputes only — start from program competition from Module 1.

Per dispute: phrase as a question both sides must answer (not just one side cares about). Phrase Positions in each program's own language, don't reframe in opponent's terms. Arguments must cite specific sources (Source Catalog ID), no floating claims. Assess status: active (both sides producing new evidence) / approaching consensus / deadlocked (comparable evidence, value-based) / resolved.

### Module 3: Evolution timeline

Domains go through phase transitions: normal science → anomaly accumulation → crisis → revolution. Order key works/events by time, then mark transitions:

- **Normal science**: puzzle-solving within existing framework, stable consensus, converging terminology
- **Anomaly accumulation**: more "existing methods can't solve X" cases, "why doesn't X work" papers, patch-style work increasing
- **Crisis**: "does X have a future" questioning, researchers jumping to other frameworks, workshops featuring "reflection"
- **Revolution**: new framework redefining "good questions", new terminology proliferates, old-framework work re-expressed in new terms

Locate current phase — sets map's tone (normal-science maps emphasize consensus, crisis maps emphasize tension).

### Module 4: Open problems

Identify current P2 problems (problems the previous cycle produced but hasn't solved): from frontier sources (open problems/challenges/limitations explicitly mentioned), from survey "future work" sections, from dispute sources (problems both sides acknowledge unsolved).

Per problem: one clear sentence (no jargon padding); who's attacking (teams/programs, with sources); what approach (improving existing / new tools / redefining problem); stuck where (data / theory / engineering bottleneck).

Also identify neglected problems: important but no one working on them (don't fit any program's core, or cross-program intersection where each thinks "that's their problem"). Most discovery value, most uncertain — mark `[推测，需验证]`.

### Module 5: Entry recommendations

Identify 3-5 entry-point sources for new readers via citation-network topology (no full bibliometrics needed):

| Priority | Role | Reader gains |
|---|---|---|
| 1 | 奠基性 | Terminology + basic framework |
| 2 | 桥梁性 | Global perspective |
| 3-5 | 前沿性 | Current state |

Per entry: don't just say "good paper" — what can reader understand after reading that they couldn't before? Where does it sit in the map (which program, which period)? What should they read next? If good surveys exist, prioritize one as first entry (surveys are mini domain maps).

**Module completion check**: 2-5 programs fully described; 2-4 core disputes mapped; timeline with phase transitions marked; 3-5 open problems + 1-2 neglected directions; 3-5 entry recommendations with reasons. All conclusions cite catalog sources; uncited claims marked `[待验证]`.

## Phase 3: Compose

Write Phase 2 results as a 学案体 domain map.

### 学案体 structure

学案体 originates from Chinese traditional academic history (黄宗羲《明儒学案》). Maps cleanly to domain structure: 学案 = research program, 案主 = representative work, 传授 = influence chain, 论学 = core debates, 未竟 = open problems, 著作 = entry recommendations.

### Full template

```markdown
# {topic} Domain Map

## 总案

[One paragraph: domain's core question, main routes, what's most worth watching. Reader gets global picture in 30 seconds.]

## 研究纲领

### Program A: {name}

**Hard core**: {one sentence}
**Representative work**: {S1: why important}, {S3: why important}
**Status**: progressive / degenerating / neutral
**Currently exploring**: {positive heuristic's current direction}

### Program B: {name}

{same structure}

### Inter-program relationships

{complementary / competing / contained / evolved — brief}

## 论争

### Dispute 1: {Issue — phrased as question}

**{Position A}**: {Program A's answer}
Evidence: {specific, with sources}

**{Position B}**: {Program B's answer}
Evidence: {specific, with sources}

**Current status**: active / approaching consensus / deadlocked

## 源流

| Period | Phase | Signature events/works | Paradigm state |
|--------|-------|------------------------|----------------|
| 20XX-20XX | {phase} | {event} | stable/shaking/restructuring |

**Current phase assessment**: {where domain is now in phase-transition model}

## 未竟

### Open problem 1: {one-sentence description}
- **Attackers**: {teams/programs} ({sources})
- **Approach**: {method}
- **Bottleneck**: {stuck where}

### Neglected direction
- {description} — [推测，需验证]

## 入门

| # | Resource | Type | Why read first | Where next |
|---|----------|------|----------------|------------|
| 1 | [{title}]({URL}) | 奠基 | {reason} | → {next step} |
| ... |

## 覆盖度声明

[Honest statement of coverage and limits. Which directions well-covered, which thin, which conclusions need further verification.]
```

### Writing process

Plan first: 1-2 sentences per section, ensure consistency (programs / disputes / timeline / open problems must not contradict).

Per section attention: **总案** write last (needs whole-domain judgment, only clear after everything else); **研究纲领** each program standalone in its own language; **论争** both sides need concrete evidence (mark `[证据偏少]` if thin); **源流** emphasize phase transitions, not timeline trivia — explain why this point is the shift; **未竟** open problems must have edge (specific "method Y fails under condition Z, no one knows why", not vague "more research needed"); **入门** each recommendation answers "what can reader do after reading that they couldn't before?"; **覆盖度声明** honest and specific.

Write directly, don't pause for user confirmation. List structure in delivery report. Exception: if Phase 1 coverage unusually thin (< 10 sources total), flag before writing — map will be low-confidence.

### Quality audit

Structure: missing programs? Covers most of catalog? Disputes really core or trivial? Timeline gaps?
Evidence: every claim points to source? Uncited claims marked `[待验证]`? Direction bias from uneven coverage?
Style: direct voice with judgment, no hedge. 9 Red Lines (mouth-test, no jargon, short words, one-thought-per-sentence, concrete, reasons-first, no filler, trust reader, honest). Native Chinese, no AI smell.

### Step 4: Voice Pass

See `voice-pass.md`. Mandatory. De-AI scan + style scan. 学案体-specific: hedge phrases still banned, em-dash still banned, 工整并列 bold 标题 still varies tone, 段末收尾总结句 still cut. Style scan: if user has prior survey/学案体 outputs in workspace, scan 1-2 for voice/structure preferences.

### Step 5: Write final file + delivery report

Write `.md` per `output-spec.md`. File naming: `{topic}-survey_{YYYY-MM-DD}.md`. YAML must include `topic: {领域}` and `scope: {broad/focused}`.

Delivery report (`voice-pass.md` Step 4): article path, word count, section count (总案 / 研究纲领 / 论争 / 源流 / 未竟 / 入门 / 覆盖度声明), Voice Pass execution, style reference (or skipped). **Survey-specific**: program count, dispute count, open problem count, coverage limitations flagged.

## Output

After Voice Pass, write file. **Stop at publish confirmation.** Do NOT push, post, distribute, commit unless user explicitly asks.
