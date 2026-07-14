# Deep Read Workflow

Triggered when the user provides URLs, PDFs, files, or pasted non-code material such as papers, articles, interviews, reports, or book chapters. Output is a polished Chinese research article whose organizing frame is selected from evidence.

## Phase 1: Collect

Follow `collect.md`. Phase 1 ends when each source is fetched or its failure is reported, typed by reasoning shape, and assigned a stable identifier.

Record:

- `q`: the user's exact question or desired cognitive result
- `C`: the Context Envelope from `context-acquisition.md`
- source type and reasoning shape
- length and access status
- original key terms
- named focus areas

Length controls read scheduling only. It does not determine analytical importance.

## Phase 2: Read

Produce one isolated Source Brief per source.

### Step 1: Select reading lens

Use `reading-variants.md`. Choose a lead lens from argument and narrative, academic extraction, concept anatomy, or vertical drilling. Add a secondary lens only when it covers a concrete blind spot.

Record internally: why the lens fits `q`, what it foregrounds, its likely blind spot, and what evidence would trigger a switch. A lens must change extraction; naming a lens without changing the Source Brief is a failure.

### Step 2: Read for load-bearing evidence

Extract claims, evidence, assumptions, boundaries, distinctive terms, uncertainties, and internal tensions. Use paragraph-level structural tags only when they help locate a dense argument. Use witnessed-problem -> prior-route -> new-opening only when the source actually contains that movement.

Apply the digestion filter before adding an observation:

1. **Recurrence**: does it appear independently in at least two places? Keep a critical single point as `[single-point]`.
2. **Generative power**: can it explain what the source would say about a new case?
3. **Specificity**: is it distinctive to this source rather than generic expert knowledge?

All three pass: core evidence. Two pass: keep briefly. Zero or one pass: background or drop.

### Step 3: Build Source Brief

Each Source Brief contains:

- source identity and lead lens
- exact problem or question
- default answer or baseline, if evidenced
- core claim and distinctive move
- load-bearing evidence and its type
- method or mechanism in plain language
- assumptions and generalization conditions
- counterevidence, internal tension, or missing comparison
- key quotes with speaker attribution
- uncertainties and claims requiring verification
- lead-lens blind spot
- possible connections to the user's question

A Source Brief is an evidence library, not a source summary.

### Step 4: Multi-source reading

For three or more independent sources, read in parallel when background agents are available. Each agent reads one source only and returns an isolated Source Brief. If agents are unavailable, read serially with the same schema. Never let one source's interpretation leak into another brief.

### Step 5: Brief quality gate

Check:

- Can each core claim be distinguished from its evidence?
- Are speaker positions separated in interviews?
- Are measured findings separated from author generalization in papers?
- Did the selected lens expose something another lens would miss?
- Is at least one boundary or uncertainty explicit?

If not, re-read the weak subsection rather than the entire source set.

## Phase 3: Synthesize

Turn Source Briefs into candidate explanations and select the article frame.

### Step 1: Reserve hold-out evidence

Before candidate generation, reserve:

- the last load-bearing section for a single source; or
- the last Source Brief for multiple sources.

Do not use it to construct candidates. Reveal it after selection to test reach.

### Step 2: Generate candidate frames

Search from several directions without requiring each one to survive:

- **problem shift**: how the material changes the question or default answer
- **generator**: smallest independent mechanisms that reproduce many observations
- **tension**: conflict between claims, scales, values, or evidence types
- **boundary**: where a common explanation works and where it stops
- **reference axis**: which dimension places competing answers in a useful relation

For generator discovery: list phenomena, propose generators, remove candidates that explain nothing independently, reverse-generate the observations, then test prediction and failure conditions. Evaluate independence, necessity, generative power, simplicity, and falsifiability.

Keep only candidates that change evidence selection or chapter structure. Merge paraphrases. One strong candidate is better than three decorative ones.

Use the Candidate Frame Brief and admission gates in `frame-selection.md` when turning these directions into retained candidates.

### Step 3: Adversarial stress test

Test candidates with arguments, not theatrical personas:

- strongest rival explanation
- boundary or counterexample
- scale shift: individual/system, short/long term, local/general
- alternative evidence interpretation
- premise-removal test: what collapses if one component is removed?

Use a real historical or contemporary person's position only when their published stance is part of the source set and materially changes the test. Do not simulate authority from a name.

### Step 4: Loop back on evidence gaps

Return to Phase 2 for the affected subtopic when:

- no candidate can state an evidence-backed thesis after three attempts;
- a load-bearing finding rests on one unverified point;
- every candidate fails on the same missing comparison;
- high-risk claims cluster around one evidence gap;
- the user's named focus cannot map to evidence.

Stable subtopics do not repeat.

### Step 5: Select frame and test hold-out

Apply `frame-selection.md`. Choose the candidate that best answers `q`, has the strongest evidence, compresses the most observations with the fewest components, and states its boundary. Prefer a narrower supported claim over a broad elegant one.

Reveal the hold-out. Pass when the frame explains it without changing its core components. Record a real miss and narrow the frame when necessary; do not retrofit and claim prediction.

### Step 6: Produce Synthesis Pack

```markdown
## Synthesis Pack

### Selected Frame
{one sentence}

### Why It Won
{question fit, evidence, compression, boundary}

### Close Alternative
{only when materially different}

### Key Findings
- {finding}: {evidence}

### Conflicts and Rival Explanations
- {conflict}: {evidence on each side}

### Hold-out Result
{predicted, partial, or miss; frame adjustment if required}

### Evidence Weight
- {claim}: strong / medium / weak / disputed

### Boundaries and High-Risk Claims
- {claim}: {condition or failure mode}
```

Keep the Synthesis Pack internal and read-only during Compose.

### Step 7: Run Impact Pass

Apply `impact-pass.md` with `q`, `C`, the completed Source Brief / Synthesis evidence, and the selected frame after hold-out testing. A Source Brief's possible connection to the user's question is only an impact candidate; it cannot become a personal claim until it passes Context Envelope provenance and the Impact Pass admission gates.

Keep the resulting Impact Brief internal and read-only during Compose. Do not let a desired personal implication reopen or retrofit the selected frame.

## Phase 4: Compose

Write the research article through the selected frame.

### Step 1: Choose narrative anchor after frame selection

Use a concrete scene or example only if it reveals the selected frame. An anchor is optional. Do not let a vivid example decide the frame or force every chapter to return to it.

### Step 2: Map chapters

For every planned chapter record internally:

- selected-frame component served
- evidence used
- role: establish, explain, contrast, test, bound, or apply

Delete a chapter that does not serve the frame, or return to Phase 2 for missing evidence. Chapter count and short titles are writing heuristics, not quality gates.

### Step 3: Write and review chapter by chapter

Expose reasoning, preserve contradictions, and keep claims proportional to evidence. Use scene, comparison, formalism, or direct quotation only when it advances the selected frame. Keep speaker attribution exact and distinguish source conclusions from weave's synthesis.

Render the admitted impacts near the end of the article per `impact-pass.md`. Use `对我意味着什么` only when `C` supports a personal baseline; otherwise use `对当前问题意味着什么`. Do not turn an absent impact into generic advice.

For an interview with an accessible transcript, use at least two short exact quotes as analytical anchors, normally from different turns or speakers. Each quote must establish a claim, uncertainty, concession, or change caused by questioning; decorative quotation does not count. Preserve wording and speaker attribution. If the transcript cannot be fetched reliably, paraphrase and state that exact quotation was unavailable rather than inventing one.

### Step 4: Explicit research review

Audit without role-playing an advisor:

- **Load-bearing premise**: what must be true, and is it supported?
- **Alternative explanation**: what else fits the same evidence?
- **Counterexample**: which case strains the frame?
- **Inference chain**: where does evidence become interpretation?
- **Generalization**: what population, scale, or time range is justified?
- **Novelty**: did the article produce a material cognitive shift or only reorganize summaries?
- **Context fidelity**: does every personal baseline trace to `C`, with question-only language when it does not?
- **Impact separation**: are source findings, weave synthesis, and context-bound application still distinguishable?
- **Honesty**: are uncertainty and the hold-out result visible?
- **Interview grounding**: when applicable, do exact attributed quotes anchor the analysis rather than merely decorate it?

Revise concrete failures, then re-run the audit.

### Step 5: Voice Pass and output

Run `voice-pass.md`, then write `{topic}-deep-read_{YYYY-MM-DD}.md` per `output-spec.md`.

Delivery report: article path, word count, chapter structure, selected frame, why it won, close alternative if material, hold-out result, detected host, context source categories, admitted impact count or `delta ~= 0` reason, context degradation, Voice Pass corrections, and style reference.

Stop at publish confirmation. Do not push, post, distribute, or commit unless explicitly asked.
