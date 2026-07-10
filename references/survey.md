# Survey Workflow

Triggered when the user provides a domain name or research direction such as "RAG", "agent memory systems", or "knowledge graph reasoning". Output is a Chinese domain map whose organizing lens is selected from evidence rather than imposed in advance.

This workflow maps a domain. If the user supplied concrete sources and wants those sources read closely, route to `deep-read.md`.

## Table of Contents

- Phase 1: Scout — build an evidence-typed Source Catalog
- Phase 2: Map — generate and select domain-map lenses
- Phase 3: Compose — write the map through the selected lens

## Phase 1: Scout

Build a Source Catalog that reveals the domain's structure. The catalog is an internal working-memory artifact, not a separate user-facing file unless requested.

### Step 1: Parse input

Capture:

- `topic`: domain or research direction; narrow labels that are too broad to map honestly
- `scope`: `broad` or `focused`; default `broad`
- `q`: what the user wants the map to help them understand or decide
- named subtopics: preserve each as a coverage obligation

### Step 2: Search from different angles

Run 3-5 search rounds. Use short unquoted keywords when boolean or quoted syntax fails.

Useful angles:

1. definitions and systematic reviews
2. foundational work and origin stories
3. competing methods or architectures
4. empirical comparisons and benchmarks
5. open problems, failures, and recent shifts
6. production or institutional evidence when relevant to `q`

Search syntax is not methodology. If a backend rejects a complex query, simplify it rather than retrying the same expression.

### Step 3: Type the evidence

Quick-read title, abstract or executive summary, introduction, and conclusion. Record what kind of claim each source can support:

| Evidence type | Can support | Cannot support alone |
|---|---|---|
| Primary paper / official dataset | method, result, measured limitation | whole-field consensus |
| Systematic review / strong survey | taxonomy, coverage, historical synthesis | current product behavior without verification |
| Official docs / engineering post | implementation, defaults, adoption claim by its owner | independent comparative superiority |
| Independent technical analysis | cross-source interpretation, implementation contrast | unverified proprietary facts |
| Community discussion | practice signal, vocabulary, candidate problem | prevalence, consensus, or scientific result |

Tag each source with: evidence type, domain label, availability, date, and one structural contribution. Treat product pages and SEO summaries as discovery leads, not final evidence.

Field-wide prevalence, momentum, consensus, decline, or frontier-shift claims require a systematic sample, bibliometric trend, repeated benchmark series, or a strong survey that explicitly makes that claim. Representative examples establish existence, not "most" or "the field is moving". Without trend-capable evidence, scope the sentence to `the current source set` and name the sampling limit.

### Step 4: Search until structural saturation

After the initial rounds, search specifically for:

- a thin side of an important dispute;
- an unexplained bottleneck;
- a missing method family;
- a time gap in a claimed transition;
- the user's named focus area.

Stop when two consecutive targeted rounds add no new method family, dispute axis, bottleneck, or evidence type. Source counts are a coverage heuristic, not a quality gate. Fewer than 10 strong sources requires a low-confidence warning; do not pad the catalog with weak pages.

### Step 5: Build Source Catalog

```markdown
# Source Catalog — {topic}

| ID | Title | URL | Evidence type | Structural role | Domain label | Availability | Key contribution |
|----|-------|-----|---------------|-----------------|--------------|--------------|------------------|
| S1 | ... | ... | Primary paper | Defines method X | Route A | Full text | ... |
```

Completion check:

- named focus areas covered or explicitly marked thin;
- important claims have an evidence type capable of supporting them;
- opposing sides of a dispute are represented;
- saturation rule reached or the search limitation is recorded.

## Phase 2: Map

Generate candidate ways to organize the domain. These are lenses, not mandatory sections. Keep 1-4 candidates that genuinely change what becomes foreground, how sources group, or what the map predicts. Do not manufacture alternatives to satisfy a count.

### Lens A: Research programs

Use only when multiple sources reveal stable, shared commitments that organize follow-on work.

For each program:

- **Core commitment**: premise followers repeatedly preserve
- **Adjustable assumptions**: what changes when counterevidence arrives
- **Representative work**: products of that commitment
- **Momentum evidence**: measured growth, new predictions, benchmark gains, or clear decline

Do not label a program progressive or degenerating from two representative papers. If trend evidence is insufficient, describe the observable activity without a status verdict.

### Lens B: Method or architecture families

Use when the domain is organized by competing mechanisms, representations, or system designs. Group sources by how they solve the same task. Compare inputs, mechanism, resource assumptions, strengths, failure modes, and compatibility.

### Lens C: Bottleneck or value flow

Use when outcomes are constrained by a chain such as data → model → evaluation → deployment, or when power and value accumulate at different points. Identify where flow narrows, what controls the bottleneck, and which work tries to move it.

### Lens D: Dispute or decision axes

Use when several positions answer the same load-bearing question differently. Phrase the issue so every side must answer it. Represent each side in its own terms, cite its evidence, and state which observation would change the dispute.

### Lens E: Temporal evolution

Use only when the evidence supports real changes in questions, methods, institutions, or evaluation standards. A chronology is not automatically a paradigm transition.

For each proposed transition, require:

- a before-state;
- an observed anomaly or pressure;
- a changed practice or vocabulary;
- an after-state;
- sources from both sides of the transition.

Do not use crisis or revolution language without evidence of displaced questions or standards. If history is gradual, describe it as gradual.

### Cross-cutting modules

These modules are required evidence services, but they do not have to control the article's main frame.

#### Open problems

For each problem, record: one-sentence problem, who is working on it, approach, bottleneck, and sources. Replace "nobody studies this" with "under-covered in the current corpus" unless a systematic search supports the stronger claim.

#### Entry recommendations

Choose 3-5 sources that let a new reader enter the selected map. State what the reader can understand after each source, where it sits in the map, and what to read next.

#### Coverage statement

State which directions are well covered, which rely on weaker evidence types, which named subtopics remain thin, and which conclusions need verification.

### Select the map lens

For each surviving candidate, write internally:

- the user's question it answers;
- what it foregrounds and backgrounds;
- how it groups the same evidence differently;
- one boundary or counterexample;
- what it predicts about the held-out frontier-source group.

Use the Candidate Frame Brief and admission gates in `frame-selection.md`. Select the lens with the strongest question fit and evidence. Prefer narrower claims when two are close. The research-program lens has no default priority.

The selected lens must control the top-level body. Its load-bearing components become the main headings; method families, disputes, and chronology move inside those headings when they are supporting views. Reusing the old program / dispute / evolution skeleton is a failure unless those are themselves the selected frame's components. Confirm that the lens changes at least two of chapter order, evidence grouping, comparison set, causal explanation, or predicted boundary.

Completion check:

- selected lens changes the body structure;
- at least one real alternative was considered when evidence permits;
- field-status claims use trend-capable evidence;
- prevalence and frontier-shift claims are either trend-supported or explicitly scoped to the current source set;
- held-out frontier sources do not force a retrofit;
- open problems, entry points, and coverage limits remain available.

## Phase 3: Compose

Write the selected map as a Chinese longform article.

### Required outer structure

```markdown
# {topic} Domain Map

## 总案
{core question, selected lens, and most important current tension}

## {sections generated by the selected lens}
...

## 未竟
...

## 入门
...

## 覆盖度声明
...
```

If the research-program lens wins, a 学案体 body is appropriate. If another lens wins, let section names and order follow that lens. Do not preserve program, dispute, or revolution sections merely because the old template had them.

### Writing rules

- Write `总案` last, after the map is stable.
- Keep competing positions visible; do not manufacture consensus.
- Cite claims with Source Catalog IDs and links where useful.
- Mark unsupported synthesis `[待验证]` and weak sides `[证据偏少]`.
- A product or community source may illustrate practice but cannot establish field-wide prevalence.
- Make open problems specific: failure under condition Z, not "more research is needed".
- Avoid theory names as authority; explain the observed structure directly.

### Quality audit

Check:

- Does the body follow the selected lens rather than a seven-section template?
- Would another candidate produce materially different grouping or ordering?
- Does any phase or momentum claim outrun its evidence type?
- Do the table and prose contradict each other?
- Did the held-out frontier group fit without changing the frame?
- Are coverage limits specific and honest?

### Voice Pass and output

Run `voice-pass.md`, then write the final file per `output-spec.md` as `{topic}-survey_{YYYY-MM-DD}.md`. YAML must include `topic` and `scope`.

Delivery report: article path, word count, body structure, selected lens, close alternative if material, source count by evidence type, open-problem count, and coverage limitations.

Stop at publish confirmation. Do not push, post, distribute, or commit unless explicitly asked.
