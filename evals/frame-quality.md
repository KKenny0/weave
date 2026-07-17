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
- multiple sources: reserve the last Source Brief;
- source-dive: reserve one non-entry module connected to a core behavior path;
- survey: reserve the newest frontier-source group.

Reveal the hold-out after selecting `f*`. Pass when the frame explains the hold-out without changing its core components and reports a real miss honestly. Retrofitting the frame after reveal is a failure.

For evals, persist the Candidate Frame Brief and prediction before revealing the hold-out. Use the environment clock, then identify the later hold-out fetch/read in the execution transcript when available. Artifact content proves what was predicted; transcript order proves when. A retrospective report or handwritten timestamp alone cannot prove chronology. If access logs are unavailable, grade prediction content normally but report chronology as unverified.

## Final-article trace

Before Compose, map every planned chapter to:

- one component of `f*`;
- the evidence it uses;
- its role: establish, explain, contrast, test, bound, or apply.

Delete a chapter that does not serve the selected frame. In the final audit, verify that the article's ordering still follows this map and that the strongest counterevidence remains visible.

## Failure patterns

- Candidate labels differ but chapter maps are the same.
- A vivid metaphor replaces an evidence-backed mechanism.
- The winner is generic enough to fit any topic in the field.
- A fixed workflow template determines the answer before the evidence is read.
- The article contains the selected thesis but most chapters remain an inventory.
- The frame explains included evidence only and collapses on the hold-out.
- Runner-up candidates are obvious strawmen.
- Field-wide prevalence or momentum is inferred from representative examples rather than trend-capable evidence.
- The selected lens is named in the report but the article keeps the old top-level template.
- A survey lens reorganizes the domain but does not close its primary `orient`, `choose`, `enter`, or `evaluate` intent.
- A survey article gives unconditional advice even though its evidence ceiling supports only description or comparison.
