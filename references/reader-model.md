# Reader Model

Use this protocol across all three workflows. It defines the cognitive change the run should produce before research begins and tests that change before composition. The final article remains the public output; the Reader Contract and Comprehension Gate stay in working memory.

## Reader Contract

Build the contract after Context Acquisition and routing, before source collection or repository discovery. Its job is to turn a topic request into a falsifiable reading target without treating the user's initial framing as settled truth.

Record:

- **Initial question**: the exact question or decision the user brought;
- **Starting model**: the supported distinction, explanation, prediction, or uncertainty the user currently holds; use `unknown` when no baseline is available;
- **Unsettled judgment**: the part of the starting model most likely to change;
- **Target capability**: what the reader should be able to reconstruct, distinguish, predict, transfer, or evaluate after reading;
- **Revision trigger**: the evidence or contradiction that would require the initial question or model to be reframed;
- **Route expression**: how that capability appears in the selected workflow.

Use only context already admitted by `context-acquisition.md`. Do not infer a personal baseline from the topic, project rules, or generic expert behavior. When the request supplies no baseline, define a question-level target capability and keep the starting model `unknown`.

The target capability must be observable. Reject goals such as “understand deeply” or “gain insight” unless they are rewritten as an ability, for example:

- explain why the source needs a distinction and where it fails;
- trace an unfamiliar input through a system and predict its state changes;
- place a new method on the domain map and name the evidence still needed;
- revise an initial either-or question when the evidence reveals a different controlling variable.

The contract stays in working memory. Do not persist it, place it in frontmatter, reproduce it in a delivery report, or add it to `.weave-frame/`. The starting model is a hypothesis to test, not a conclusion to confirm.

## Keep the question revisable

Carry the initial question through evidence collection without forcing every observation into it. Record a possible reframing when any of these occurs:

- the alternatives in the question are not mutually exclusive;
- the source answers a different upstream question;
- a hidden variable explains more than the user's original distinction;
- the requested decision requires evidence the source set cannot supply;
- the original premise is contradicted or remains unsupported.

Do not rewrite the question immediately to make the run look insightful. Preserve the initial wording until the Comprehension Gate can compare it with the completed evidence model.

## Comprehension Gate

Run after frame selection and hold-out testing, before Impact Pass and Compose. This gate tests understanding rather than article quality. It is separate from the hold-out: the hold-out tests whether the selected frame reaches unseen evidence; the Comprehension Gate tests whether the completed model can be reconstructed and used.

Temporarily set aside the structured evidence fields. Without copying their wording, produce four short internal probes, then reopen the evidence model and verify each one.

### 1. Reconstruction

Rebuild the load-bearing explanation in plain language:

- the problem being answered;
- the smallest mechanism, distinctions, or path that carries the answer;
- the strongest evidence;
- the condition where the explanation stops.

Fail when the reconstruction is only a topic summary, omits a load-bearing component, or turns weave synthesis into a source claim.

### 2. Novel case

Use the selected frame on one case not used to construct it. State the prediction or classification, the mechanism that produces it, and whether this is a source-supported extension or weave synthesis.

Fail when the case is a renamed source example, the prediction does not follow from the mechanism, or the evidence ceiling does not permit the transfer.

### 3. Counterexample

Construct one case that removes a required premise, crosses a stated boundary, or makes the frame predict incorrectly. State whether it confirms the existing boundary or requires the frame to narrow.

Fail when the counterexample is decorative, contradicts no component, or is silently absorbed by changing the frame after the fact.

### 4. Question repair

Classify the initial question as one of:

- **answered**: its terms survived and the evidence resolves it;
- **reframed**: a better distinction or controlling variable replaced part of it;
- **dissolved**: a premise or opposition in the question did not survive;
- **unresolved**: the required evidence is absent or disputed.

State the repaired question or the unresolved evidence. A changed question must follow from the evidence model, not from a desire to manufacture cognitive delta.

## Route expressions

- **deep-read**: reconstruct the author's problem and reasoning move; predict how the frame treats a new case; expose one non-transferable case.
- **source-dive**: reconstruct a load-bearing behavior path; predict a new input, configuration, or failure; remove one enforcing component and trace the break.
- **survey**: reconstruct the selected map distinction; place an unfamiliar method or claim conditionally; identify a case the current evidence ceiling cannot locate or decide.

## Pass and failure handling

Pass only when all four probes trace back to the completed evidence model and the Reader Contract's target capability is demonstrated or honestly bounded. Record `Comprehension Gate: passed` in the delivery report without dumping the probes or Reader Contract.

On failure, return only to the affected stage:

- weak reconstruction -> reread the missing evidence or mechanism;
- invalid novel case -> narrow the transfer or collect the required comparison;
- ineffective counterexample -> revisit the frame boundary;
- unsupported question repair -> restore the initial question or mark it unresolved.

If any repair changes the selected frame's load-bearing components, claim, or boundary after the hold-out was revealed, invalidate the previous hold-out result. Designate a fresh unopened hold-out, persist a new pre-reveal prediction when the run is audit-sensitive, and repeat frame selection, hold-out testing, and the Comprehension Gate. When no fresh hold-out exists, report chronology and prediction as unverified; an audit-sensitive run fails. Never reuse revealed evidence to validate the repaired frame.

`delta ~= 0` remains valid. A gate can pass when the initial model survives, provided the reconstruction, novel case, counterexample, and evidence boundary are all sound.
