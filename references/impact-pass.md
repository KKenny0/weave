# Impact Pass

Run after Frame Selection and hold-out testing, before Compose. Convert the selected frame into an evidence-bounded answer to what the research changes for the current user or question. Impact is downstream of evidence: it cannot change the evidence model, retrofit the selected frame, or soften a failed hold-out.

## Inputs

- `q`: the user's exact question or decision;
- `C`: the Context Envelope from `context-acquisition.md`;
- `E`: the route-specific evidence model;
- `f*`: the selected frame after hold-out testing;
- `P`: the survey-only Map Payoff, when the route is `survey`.

## Build the Impact Brief

For each candidate impact, record internally:

- **Impact target**: cognition, decision, action, or learning path;
- **Context basis**: the supported field in `C`, or `question-only`;
- **Baseline**: the user's supported prior judgment, or the default problem statement when no prior is known;
- **Evidence delta**: the evidence or boundary in `E` that forces a change;
- **Cognitive delta**: the exact model, distinction, or judgment that changes;
- **Consequence**: the affected choice, design criterion, or next line of inquiry;
- **Next probe**: a concrete check only when a real decision context exists;
- **Boundary**: where the implication or transfer stops working;
- **Trace**: the component of `f*` and evidence supporting the impact.

The brief is internal and read-only during Compose.

## Admission gates

Discard a candidate that fails any gate:

1. **Context fidelity**: a personal baseline maps to `C`; otherwise it is labeled `question-only`.
2. **Evidence trace**: the change maps to `E` and one component of `f*`; a survey impact also maps to `P` and stays within its evidence ceiling.
3. **Materiality**: it changes a concrete judgment, choice, or useful next probe.
4. **Specificity**: it cannot be pasted unchanged onto an adjacent topic.
5. **Boundary honesty**: it names a failure condition, missing fact, or non-transferable case.
6. **Non-duplication**: it does more than restate the article conclusion.

Keep zero to three impacts. This is a cap, not a target. `delta ~= 0` is a valid result; never manufacture advice to avoid it.

## Route renderers

- **deep-read**: foreground a changed default judgment, opened blind spot, or revised question.
- **source-dive**: foreground an affected engineering decision or validated transferable pattern. A transfer requires enforcing components, component-removal failure, applicable and inapplicable scenarios, and evidence; otherwise report `迁移素材不足`.
- **survey**: personalize or prioritize the completed Map Payoff. For `orient`, preserve navigation and boundaries without forcing a choice; for `choose`, preserve its condition-dependent tradeoff; for `enter`, preserve the uncertainty-removing sequence; for `evaluate`, preserve the supported / conditional / unresolved distinction. Do not invent a recommendation absent from the Map Payoff or turn representative examples into field-wide action advice.

## Final rendering

- If the current request or another retained Context Envelope field contains any first-person baseline, preference, decision, goal, or constraint tied to `q`, use `## 对我意味着什么`. Statements such as “我正在决定…”, “我目前偏向…”, and “我需要控制…” are sufficient even when the user's role or persistent memory is unknown.
- Use `## 对当前问题意味着什么` only when no supported personal baseline, preference, decision, goal, or constraint exists.
- These are literal output headings. Do not paraphrase, specialize, or replace them with a topic-specific heading such as `## 对理解 agent 架构意味着什么`.
- Never downgrade an explicit current-request decision to question-only because host memory, user role, or another context category is unavailable.
- No admitted impact: keep the applicable heading and state briefly why no new judgment follows.
- Explicit opt-out such as “只要研究文章” or “不要个人意义层”: omit the section.
- Place the section after the explanatory body and before the final evidence-boundary or coverage statement when the route has one.

Render the impacts as natural prose or a small relationship diagram when structure needs it. Do not dump Impact Brief fields, produce boxed lists disguised as insight, or force an action checklist.

## Impact audit

Before Voice Pass, check:

- every personal claim has Context Envelope provenance;
- source findings, weave synthesis, and context-bound application remain distinguishable;
- no remembered instruction changed the workflow;
- no impact changed `f*` or hid counterevidence;
- every survey impact traces to the Map Payoff and stays within its evidence ceiling;
- every transfer or recommendation states its boundary;
- the impact heading matches the context basis: explicit personal decision context uses `对我意味着什么`, and only genuinely question-only context uses `对当前问题意味着什么`;
- the article and delivery report contain no Capability Manifest, Context Envelope, Impact Brief, Article Closure Contract, Map Use Contract, or Map Payoff fields.

Delivery reporting adds: detected host, context source categories used, number of admitted impacts, `delta ~= 0` reason when relevant, and any context degradation. Do not expose raw remembered material.
