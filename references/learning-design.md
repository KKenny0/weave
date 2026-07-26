# Reader Outcome and Recoverability

Use the reader-outcome and Learning Spine sections for Deep Read and Source Dive. Survey now uses the Learn Mode Gate, Spine Direction Gate, and composition sequence in `survey.md`; do not route Survey through the five outcomes below. The final-article recoverability protocol remains shared by every route whose article promises a self-contained explanation.

## Select the reader outcome

Choose one primary outcome and at most one secondary outcome:

| Outcome | Use when the request asks for | Finished article must enable |
|---|---|---|
| `explain` | “讲懂”, “从零解释”, “让非专业背景也能读懂”, or a causal mental model | reconstruct the smallest mechanism, follow its dependencies, and predict a new case |
| `map` | a landscape, major routes, relationships, disputes, or field status | locate an unfamiliar item on explicit axes and name what the map cannot decide |
| `evaluate` | whether a claim, method, source, or system is supported | separate supported, contradicted, conditional, and unresolved parts |
| `decide` | a real choice between alternatives | apply `condition -> choice -> cost -> verification evidence` without universal advice |
| `enter` | where to start or how to learn/research the subject | follow a sequence in which each step removes a named uncertainty |

For Deep Read and Source Dive, evidence workflow and reader outcome are independent:

- supplied prose sources normally use `deep-read`, but may produce `explain`, `evaluate`, or `decide`;
- technical projects use `source-dive`, but may produce `explain`, `evaluate`, `decide`, or `enter`;

Open domains use `survey.md`. Their exact question shapes the outline and candidate spines without assigning one of these five outcome labels.

Infer the outcome when the request is clear. Ask one question only when two plausible outcomes require materially different evidence or article structure. A request for easier language does not lower evidence standards.

## Extend the Reader Contract

Record these fields inside the existing working-memory Reader Contract:

- **Reader outcome**: one primary outcome and an optional secondary outcome;
- **Prerequisite floor**: only knowledge explicitly supplied or safely implied by the request, such as “non-professional background”; use `unknown` rather than inventing beliefs;
- **Target capability**: the observable ability the outcome requires;
- **Transfer case**: the kind of unfamiliar case the reader should be able to handle;
- **Explanation boundary**: what the article may leave unresolved without breaking its promise.

The prerequisite floor constrains exposition, not evidence. “Non-professional” permits fewer assumed technical prerequisites; it does not imply a personal belief, occupation, or demographic profile.

## Build the Learning Spine for Deep Read and Source Dive

After the Comprehension Gate passes, create one compact working-memory Learning Spine:

- **Central model**: one causal object, mechanism, distinction, path, or set of axes that carries the article;
- **Dependency order**: the minimum sequence in which concepts must be introduced;
- **Worked examples**: one concrete construction example and, for `explain`, one materially different domain example when evidence permits;
- **Misconception repairs**: up to three tempting but evidence-incompatible shortcuts;
- **Chapter deltas**: what the reader can reconstruct, distinguish, predict, evaluate, or decide after each chapter that they could not do before it;
- **Final transfer**: one unfamiliar case and the mechanism or axes used to handle it;
- **Boundary**: the counterexample, missing evidence, or condition that stops the transfer.

Keep the spine small. One strong explanatory object is better than several parallel taxonomies. A vivid metaphor may introduce the model but cannot replace its mechanism or evidence.

The Learning Spine is a Deep Read and Source Dive composition control, not a new persisted artifact. Do not put its fields in the article, frontmatter, pre-reveal file, or delivery report. Survey instead uses its non-persisted Spine Contract.

## Outcome-specific composition

### Explain

- Establish the problem, prerequisite floor, and central model before sustained specialist vocabulary.
- Define a term where it first carries reasoning weight.
- Order chapters by conceptual dependency rather than source date or field taxonomy.
- Work through at least one mechanism step by step.
- Reuse the central model across sections, but state where it stops explaining the evidence.
- Correct the admitted misconceptions in prose without creating a generic FAQ.
- End with a new-case application and a real boundary.

Fail when the article is an inventory with friendly wording, when examples decorate rather than explain, or when the reader must open the recommended sources to acquire the promised basic model.

### Map

- Keep classification axes at the same abstraction level.
- Show cross-cutting dimensions as axes or overlays instead of pretending they are mutually exclusive families.
- Define where an unfamiliar item would be placed and what evidence is still needed.
- Preserve coverage limits and avoid teaching every component in full.

### Evaluate

- Organize around the claim and evidence needed to change its status.
- Separate measurement, source interpretation, weave synthesis, and missing comparison.
- Make the strongest rival explanation and decision-relevant uncertainty visible.

### Decide

- State the real alternatives and conditions that change the choice.
- Connect each conditional choice to cost, failure mode, and verification evidence.
- Do not turn representative examples into field-wide recommendations.

### Enter

- Order steps by prerequisite and uncertainty removal, not prestige or chronology.
- State what each source or exercise makes possible and why it must precede the next.
- Do not outsource the article's promised basic explanation to the reading list.

## Final-article recoverability

After Voice Pass, Article Integrity, and final-file readback, run a fresh-context Article Recoverability Audit for Deep Read or Source Dive `explain` outputs, Survey `Canonical Article`, any Survey article that promises a self-contained explanation, and whenever the user requests a full semantic audit. Give the independent reader only the serialized final article, not the request, evidence model, expected answer, or delivery report.

Ask the independent reader to return:

1. the central model in plain language;
2. the dependency or causal path that makes it work;
3. its application to one new case;
4. one condition where it fails or remains unresolved;
5. any term or bridge that required outside knowledge not supplied by the article.

Pass only when the answer recovers the article's load-bearing model, uses it rather than quoting headings, respects the evidence boundary, and finds no prerequisite gap that breaks the Reader Contract. Repair the affected chapter and repeat the audit after a failure.

This is L1 article recoverability, not evidence of human understanding, retention, retelling, reuse, or return. L2 and L3 still require actual-reader observation. Do not persist the audit answers or create a sidecar. The delivery report may state only `Article Recoverability: passed`, the failed dimension, or `unavailable` when no independent fresh context exists. An unavailable audit is a declared degradation; it is not a simulated pass.
