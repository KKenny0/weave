# Frame Quality Evaluation

Use this rubric in addition to the workflow-specific expectations in `evals.json`. It evaluates whether weave found a useful way to see the material, not only whether it completed the pipeline.

## Evaluation unit

- `x`: supplied or collected material
- `q`: the user's actual question or decision
- `o`: the primary Deep Read or Source Dive reader outcome
- `m`: the confirmed Survey mode and exact article promise
- `E`: the evidence model produced by the workflow
- `f`: one candidate frame
- `f*`: the selected frame
- `f*(x)`: the finished article

A frame sets the object boundary, foreground and background, load-bearing distinctions or mechanisms, and the conditions under which its explanation stops working.

## Candidate admission gates

Every retained candidate must pass all six gates. A candidate that fails is discarded before comparison.

1. **Evidence fidelity**: every load-bearing part traces to `E`; no unsupported bridge is required to make the frame work.
2. **Specificity**: the frame cannot be moved unchanged to an adjacent source, repository, or domain. It uses distinctions specific to this material.
3. **Selection effect**: choosing the frame changes at least two of: included evidence, excluded evidence, chapter order, causal explanation, comparison set, or predicted boundary.
4. **Boundary honesty**: the frame names at least one condition, counterexample, or evidence gap that limits it.
5. **Distinctness**: it is not a paraphrase of another retained candidate. Two candidates must imply materially different selection or interpretation.
6. **Outcome fit**: it supports `o` or `m`, not merely the topic. An `explain` frame generates a mechanism, prerequisite path, and transfer; a `map` frame generates coherent placement axes and an evidence boundary. A Survey spine fulfills the confirmed mode and exact article promise.

For Deep Read and Source Dive, use one candidate when only one passes. Survey attempts to admit two or three genuinely different spine candidates. If fewer than two survive after one evidence-repair loop, ask whether to use the single valid direction or narrow the question. Never lower the gates to satisfy a candidate-count target.

## Ranking criteria

Rank admitted candidates without artificial numeric weights:

- **Question and outcome fit**: directly answers `q`, supports `o` or `m`, and respects the user's named focus.
- **Compression**: a small number of load-bearing parts explains many observations without erasing contradictions.
- **Generative reach**: explains or predicts evidence not used to construct the frame.
- **Cognitive delta**: produces a concrete correction, inversion, new axis, or sharper boundary relative to the default reading.
- **Economy**: uses no decorative component; removing a load-bearing component should reduce explanatory power.

Prefer the candidate with stronger evidence and narrower claims when two candidates remain close. Deep Read and Source Dive select it. Survey places it first as the recommendation, then waits for the user to choose among the admitted candidates or explicitly delegate that recommendation. Record the runner-up only when it would produce a materially different article.

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

## Survey Learn and Spine check

Evaluate Survey as one Learn-based sequence, not as the retired lens and outcome system:

- **Mode Gate**: the user confirmed `Canonical Article`, `Deep Research`, `Quick Reference`, or `Write to Learn`, or explicitly delegated the recommendation.
- **Learn pre-check**: actual `/read` and `/write` availability is checked; a missing helper is reported as degradation rather than silently bypassed.
- **Collect**: load-bearing evidence is primary-source first; official specifications, documentation, repositories, and first-party technical reports may carry the product or API behavior they define, while reviews and textbooks remain orientation; canonical identities are verified, and broad coverage is not padded with weak sources.
- **Collect ordering**: each source preserves Discover, Fetch, and File as separate operations; fetched files are moved or indexed rather than fetched again for filing.
- **Digest**: every source is read before outlining; the three claim tests determine `outline`, `background`, `boundary`, or `cut`; contradictions remain visible.
- **Outline**: every section maps to admitted sources before prose begins.
- **Candidate consequence**: each spine changes at least two of chapter order, evidence grouping, comparison set, causal explanation, inclusion, exclusion, or boundary.
- **Explicit choice**: Fill does not begin until the user selects an admitted spine or delegates the recommendation.
- **Concrete throughline**: a through-object is an inspectable noun or mechanism, and each load-bearing section states a real `📍` change.
- **No double control**: there is no separately auto-selected Survey frame underneath the chosen spine.
- **Claim ceiling**: descriptive evidence does not become comparative superiority, and representative examples do not become field-wide guidance.
- **Classification integrity**: when classification is needed, sibling categories answer one question at one abstraction level; cross-cutting dimensions become axes or overlays, and a hybrid item can be placed without contradiction.

A Survey run fails when it drafts before explicit spine selection, generates candidates before Digest and Outline, presents paraphrases as choices, keeps sections that do not serve the selected spine, or leaks Digest Notes and Spine Contract fields into the article.

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

For Survey, reconstruction follows the selected spine. A throughline must recover the concrete object across at least two state changes; a dialectical spine must recover the conflict and resolution; an issue-centered spine must recover the evidence chain and limiting condition. A renamed source example does not count as transfer.

## Deep Read and Source Dive learning-design protocol

After the Comprehension Gate, evaluate the Learning Spine against `o`:

- **Central model**: one load-bearing mechanism, distinction, path, or set of axes controls the article.
- **Dependency order**: no term is required before the article has supplied the concept it depends on.
- **Worked reasoning**: at least one example exposes the mechanism or classification operation rather than decorating it.
- **Objective completion**: every declared Canonical Article objective includes an accurate mental model, an executable or inspectable operation, a common failure, and an evidence or version boundary; a heading or keyword match is zero coverage.
- **Misconception repair**: tempting shortcuts contradicted by the evidence are corrected where they become likely.
- **Chapter delta**: each chapter adds a named reconstruction, distinction, prediction, evaluation, or decision ability.
- **Transfer and boundary**: a materially different case follows from the model, and a real condition stops it.

For `explain`, fail an approachable inventory, detached glossary, analogy-only explanation, or reading list that carries prerequisites the article promised to supply. For `map`, fail mixed abstraction levels or mutually exclusive families that collapse when a hybrid item is tested.

## Survey Fill and cross-phase visual protocol

After the Spine Direction Gate passes:

- Collect inventories relationship evidence and support limits without requiring a visual;
- Digest records idea shape, element-level evidence, and applicability boundary, with text as the default;
- Outline orders plain-language concept, concrete example, optional visual, then immediate evidence and boundary;
- every Fill section serves the selected spine and its source map;
- a stalled section returns to Digest instead of receiving fluent unsupported connective tissue;
- Fill never materializes a visual before its explanation and example;
- Refine removes cross-section repetition, writes the opening last, and applies the visual deletion test;
- Visual Pass is final admission and rendering rather than the first visual decision, and matches relationship shape to representation;
- a retained figure adds a relationship not equally recoverable from adjacent prose;
- every node, arrow, curve, or comparison traces to evidence or is labeled Weave synthesis;
- figures appear after plain-language grounding and a concrete example, with a bold one-line caption followed immediately by supporting evidence and an applicability boundary;
- every retained figure has exactly one standalone `<!-- weave-visual -->` marker immediately before it, and the delivery report's admitted count equals the serialized article's marker count;
- sparse output, including zero figures, passes;
- every ASCII visual uses one paired, non-nested, case-insensitive `#+begin_example` / `#+end_example` Org block rather than a Markdown fence, indented block, or other naked ASCII art;
- every Org ASCII content line remains within 80 ASCII columns and avoids fragile CJK alignment;
- the delivery report's candidate, admitted, and deleted counts reconcile.

Fail a figure that merely turns prose into boxes, appears before the concept is explained, overclaims the evidence, or leaves a broken asset. During Self-review, also fail a figure when a reader limited to its caption, evidence, and boundary cannot recover the interaction and changed judgment, or can infer more than the experiments support.

## Final-article recoverability

For Deep Read or Source Dive `explain`, Survey `Canonical Article`, any self-contained explanation promise, and explicit semantic audits, give only the serialized final article to a fresh independent context. Grade whether it can recover the central model or Survey spine, use it on a new case, state a real boundary, and identify prerequisite gaps. Quoting headings or `📍` markers without operating the model fails.

This result is L1 article recoverability only. It cannot establish actual-reader understanding, retention, retelling, reuse, or return. Unavailable independence must be reported and cannot pass an audit-sensitive run; audit answers remain ephemeral.

## Final-article trace

Before Compose, map every planned chapter to:

- one component of `f*`, which is the user-selected spine for Survey;
- the evidence it uses;
- its role: establish, explain, contrast, test, bound, or apply.
- the reader capability it adds.

Delete a chapter that does not serve the selected frame or Survey spine. In the final audit, verify that the article's ordering still follows this map and that the strongest counterevidence remains visible.

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
- Survey restores the retired `explain / map / evaluate / decide / enter` router or lens library.
- Survey begins Fill before the user chooses or delegates a spine.
- Survey generates spine candidates before Digest and Outline.
- Survey candidates use different labels but produce the same article.
- A throughline tracks an abstraction such as “learning” whose state cannot be named.
- The selected spine appears in the report but most chapters remain an inventory.
- A survey taxonomy puts mechanism, data regime, feedback source, and application context into one false sibling list.
- A Survey article uses accessible language but never works a mechanism or transfers it to a new case.
- A Survey article gives unconditional advice even though its evidence supports only description or comparison.
- Every Survey section receives a diagram, or retained diagrams only reflow nearby prose.
- A Survey ASCII visual uses a Markdown fence, naked text, an unpaired or nested Org example block, or a line wider than 80 ASCII columns.
- Visual evidence and placement are first considered after Refine rather than carried through Collect, Digest, Outline, Fill, and Refine.
- Agent preflight is reported as completed human Self-review.
