# Frame Quality Evaluation

Use this rubric in addition to the workflow-specific expectations in `evals.json`. It evaluates whether weave found a useful way to see the material, not only whether it completed the pipeline.

## Evaluation unit

- `x`: supplied or collected material
- `q`: the user's actual question or decision
- `E`: the evidence model produced by the workflow
- `f`: one candidate frame
- `f*`: the selected frame
- `f*(x)`: the finished article

A frame sets the object boundary, foreground and background, load-bearing distinctions or mechanisms, and the conditions under which its explanation stops working.

## Candidate admission gates

Every retained candidate must pass all five gates. A candidate that fails is discarded before comparison.

1. **Evidence fidelity**: every load-bearing part traces to `E`; no unsupported bridge is required to make the frame work.
2. **Specificity**: the frame cannot be moved unchanged to an adjacent source, repository, or domain. It uses distinctions specific to this material.
3. **Selection effect**: choosing the frame changes at least two of: included evidence, excluded evidence, chapter order, causal explanation, comparison set, or predicted boundary.
4. **Boundary honesty**: the frame names at least one condition, counterexample, or evidence gap that limits it.
5. **Distinctness**: it is not a paraphrase of another retained candidate. Two candidates must imply materially different selection or interpretation.

If only one candidate passes, use one. If none pass, return to collection or analysis. Never lower the gates to satisfy a candidate-count target.

## Ranking criteria

Rank admitted candidates without artificial numeric weights:

- **Question fit**: directly answers `q` and respects the user's named focus.
- **Compression**: a small number of load-bearing parts explains many observations without erasing contradictions.
- **Generative reach**: explains or predicts evidence not used to construct the frame.
- **Cognitive delta**: produces a concrete correction, inversion, new axis, or sharper boundary relative to the default reading.
- **Economy**: uses no decorative component; removing a load-bearing component should reduce explanatory power.

Prefer the candidate with stronger evidence and narrower claims when two candidates remain close. Record the runner-up only when it would produce a materially different article.

## Publication reader check

Apply this section only when the user explicitly requests public publication, a WeChat Official Account or X longform article, a named public readership, or broader or sustained reach.

- **Explicit trigger**: ordinary research and longform requests do not activate the extension.
- **Supported reader**: the public reader comes from the current request or remains question-level; no demographic, role, project, or account persona is invented.
- **Research consequence**: the extension changes at least one of source search, scope, evidence selection, or candidate-frame requirements. Title, opening, pacing, packaging, and shareability alone require an internal no-op and Editorial handoff.
- **Recurring-situation use**: an admitted frame produces a usable distinction, explanation, prediction, or decision frame in the reader's reproducible situation.
- **Time-boundary honesty**: durable structure is separated from launch-, version-, policy-, retrieval-, or event-bound facts; a genuinely time-bound result is accepted without an invented evergreen claim.
- **Evidence invariance**: publication intent does not lower source quality, suppress counterevidence, amplify certainty, or preselect a conclusion.
- **Artifact privacy**: Publication Reader Extension fields appear in no article, frontmatter, pre-reveal artifact, delivery report, or sidecar brief.

Fail the extension when it creates only a marketing persona, when its alleged consequence is editorial packaging, or when a topical fact is generalized into a durable claim without evidence. Failure of the optional extension does not fail an otherwise valid research run: record an internal no-op and continue under the default Reader Contract.

## Survey payoff check

For a survey candidate, structural change is necessary but not sufficient. Check it against the route's Map Use Contract:

- **Intent closure**: it changes a distinction, choice, entry sequence, or claim confidence tied to the primary intent.
- **Conditional delta**: at least one named condition changes that result; a static list of strengths and weaknesses does not pass.
- **Evidence ceiling**: descriptive evidence does not become comparative superiority, and representative examples do not become field-wide guidance.
- **No forced action**: an `orient` or `evaluate` request is not rewritten as a product-selection problem.

A survey frame fails this check when it produces an elegant taxonomy but the reader would make the same interpretation or decision under every condition. After hold-out testing, the Map Payoff must preserve the passing result without adding new evidence or changing the selected frame.

## Hold-out protocol

Choose the hold-out before candidate assembly:

- single source: reserve the last load-bearing section;
- exactly two sources: reserve one load-bearing section from each while keeping both construction briefs available for dialogue;
- three or more sources: reserve the last Source Brief;
- source-dive: reserve one non-entry module connected to a core behavior path; for `system`, test whether it fits the whole-system model or exposes a missing state owner, capability, or boundary; for narrower scopes, test whether it supports the decision, exposes a missed cost, lowers confidence in attributed intent, or forces the decision-mechanism chain to narrow;
- survey: reserve the newest frontier-source group.

Reveal the hold-out after selecting `f*`. Pass when the frame explains the hold-out without changing its core components and reports a real miss honestly. Retrofitting the frame after reveal is a failure.

For evals, persist the Candidate Frame Brief and prediction before revealing the hold-out. Use the environment clock, then identify the later hold-out fetch/read in the execution transcript when available. Artifact content proves what was predicted; transcript order proves when. A retrospective report or handwritten timestamp alone cannot prove chronology. If access logs are unavailable, grade prediction content normally but report chronology as unverified.

## Deep-read dialogue protocol

For two or more construction sources, verify that each Source Brief first reconstructs Problem World, Reasoning Machine, and World After in isolation. Then admit only Dialogue Matrix rows that identify evidence on both sides and change interpretation through shared ground, term mismatch, premise conflict, or an unresolved question.

A matrix fails when it normalizes vocabulary before establishing what each author means, records topical overlap as agreement, labels different conclusions as conflict without locating the premise difference, or appears as a field dump in the final article. In multi-source deep-read, a candidate frame must explain at least one admitted relationship or justify why one source's mechanism legitimately organizes the others.

## Comprehension protocol

After hold-out testing and before Compose, evaluate the four probes in `references/reader-model.md`:

1. **Reconstruction**: the problem, load-bearing explanation, strongest evidence, and boundary can be rebuilt without copying the evidence-model schema.
2. **Novel case**: a genuinely new case receives a prediction or classification through the selected mechanism, with weave synthesis labeled.
3. **Counterexample**: removing a premise or crossing a boundary either confirms the stated limit or narrows the frame.
4. **Question repair**: the initial question is explicitly answered, reframed, dissolved, or left unresolved from evidence.

The gate fails when fluent restatement substitutes for mechanism, a source example is renamed as a novel case, the counterexample strains no component, or question repair is manufactured without evidence. A surviving initial model may still pass; cognitive value does not require forced disagreement.

For source-dive, reconstruction must connect a problem or design force to a load-bearing decision, its executable behavior path, capability, cost, and failure boundary. A candidate frame must connect at least two layers of `problem/force <-> decision <-> mechanism <-> consequence/boundary`; relabeling a call chain, plugin system, state lifecycle, or module relation does not qualify. The counterexample removes an enforcing component or changes a shaping force. Author intent requires attributable evidence; structure-only explanations remain weave inference.

For source-dive `system`, candidate admission additionally requires one frame to explain the product problem, overall shape, canonical task, at least two load-bearing judgments, user capabilities, and system boundary together. Reconstruction must identify the tool and actor in product language, the core state, the system structure, and one representative task before naming implementation symbols. The finished article fails when local mechanisms are correct but the reader cannot recover the whole system or three project-specific takeaways.

In a source-dive `system` eval, smoke, or audit, an independent reader agent sees only the final article and answers the eight system-understanding questions in `source-dive.md`. Grade the answers for product identity, problem, capabilities, system composition, task flow, design judgments, costs, and three takeaways. This rubric is semantic; no regex or required heading substitutes for it.

## Final-article trace

Before Compose, map every planned chapter to:

- one component of `f*`;
- the evidence it uses;
- its role: establish, explain, contrast, test, bound, or apply.

Delete a chapter that does not serve the selected frame. In the final audit, verify that the article's ordering still follows this map and that the strongest counterevidence remains visible.

## Failure patterns

- Candidate labels differ but chapter maps are the same.
- Multi-source synthesis stacks conclusions without reconstructing author worlds or explaining a Dialogue Matrix relationship.
- A vivid metaphor replaces an evidence-backed mechanism.
- The winner is generic enough to fit any topic in the field.
- A fixed workflow template determines the answer before the evidence is read.
- The article contains the selected thesis but most chapters remain an inventory.
- The frame explains included evidence only and collapses on the hold-out.
- Runner-up candidates are obvious strawmen.
- Field-wide prevalence or momentum is inferred from representative examples rather than trend-capable evidence.
- The selected lens is named in the report but the article keeps the old top-level template.
- The hold-out passes, but the run cannot reconstruct the mechanism or use it on a novel case.
- The initial question is preserved after the evidence invalidates its categories.
- A decorative counterexample is listed without removing a premise, crossing a boundary, or narrowing the frame.
- A survey lens reorganizes the domain but does not close its primary `orient`, `choose`, `enter`, or `evaluate` intent.
- A survey article gives unconditional advice even though its evidence ceiling supports only description or comparison.
