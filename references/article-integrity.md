# Article Integrity Pass

Run after Voice Pass and after the final Markdown file has been written. This pass verifies the artifact the user will actually receive. It does not replace source reading, frame selection, research review, or Voice Pass.

Every deep-read, source-dive, and survey run must pass all three layers below before delivery. Keep the working fields internal; render only finished prose in the article and a one-line pass/fail result in the delivery report.

## Article Closure Contract

Before Compose, record in working memory:

- **Title promise**: the question, distinction, or central term the title promises to explain.
- **Reader outcome**: the primary Deep Read or Source Dive `explain`, `map`, `evaluate`, `decide`, or `enter` capability, or the confirmed Survey mode and exact article promise.
- **Closure locations**: the thesis plus at least two body locations that jointly fulfill that promise.
- **Learning closure**: where the central model, selected Survey spine, worked reasoning, transfer or payoff, and boundary become recoverable from the article.
- **Attribution boundary**: which load-bearing statements come directly from sources and which are weave synthesis.
- **Time boundary**: which volatile facts belong to source time, retrieval time, or a later current-state check.
- **Editorial-note policy**: whether each blockquote is a source quotation or an intentional author note; glossary explanations belong in prose.
- **Final boundary**: the condition or missing evidence that limits the article's conclusion.

This is a composition control, not a new persisted artifact. Do not add an `Article Closure Contract` section or field dump to the article or delivery report.

For source-dive, replace the generic closure locations with a route-specific contract:

- **Title promise**: the project phenomenon or engineering question the title promises to explain;
- **Core project problem**: the actual problem the implementation responds to;
- **System orientation**: for `system`, product identity, target actor, user capabilities, system boundary, core state, and canonical task;
- **Decision chains**: one to three load-bearing `problem/force -> decision -> mechanism -> consequence/cost/boundary` chains;
- **Project Takeaways**: the three to five project-specific judgments that close a `system` reading without becoming migration advice;
- **Attribution boundary**: which reasons are declared intent or historical evidence and which are weave inference;
- **Version boundary**: the commits, docs versions, and runtime environments to which claims belong;
- **Final boundary**: the condition that invalidates or narrows the conclusion.

Do not copy these fields into the article or delivery report.

## Layer 1: Semantic closure

Read the final file and check:

- the title promise is answered by the thesis and developed in the named closure locations;
- a central term in the title is not mentioned once and then abandoned;
- every chapter still serves the selected frame after Voice Pass edits;
- every chapter adds the capability promised by the Learning Spine or selected Survey spine instead of repeating background at a new level of detail;
- source findings, weave synthesis, and context-bound application remain distinguishable;
- the article answers the repaired question and renders the distinctions needed for the Reader Contract's target capability without claiming that the article has demonstrated actual-reader understanding, retention, retelling, reuse, or return;
- terminology explanations are integrated where the term first carries load rather than inserted as detached editorial notes;
- the final boundary is visible and consistent with the body.

For Deep Read or Source Dive `explain` also check:

- the motivating problem and central model appear before sustained specialist vocabulary;
- concepts arrive in dependency order, with no missing bridge that forces outside reading;
- at least one mechanism is worked through rather than merely named or analogized;
- examples carry the mechanism and include a materially different transfer case when evidence permits;
- admitted misconceptions are repaired without replacing the article with a glossary or FAQ;
- the final transfer follows from the model and stops at the stated evidence boundary;
- the result is not a field inventory rewritten in friendly language.

For Deep Read or Source Dive `map` also check:

- every sibling category answers the same classification question at the same abstraction level;
- cross-cutting dimensions are rendered as axes, overlays, or matrices;
- a hybrid method can be placed without contradictory sibling membership;
- the map states what evidence is required to place an unfamiliar item and what it cannot decide.

For survey also check:

- the Survey Visual Pass completed after Refine and before agent preflight;
- the file fulfills the confirmed Survey mode and exact article promise rather than defaulting to a domain-map template;
- the article follows the user-selected, evidence-admitted spine; there is no second lens structure competing with it;
- every load-bearing section serves the spine and maps to admitted Digest evidence;
- a throughline tracks one concrete object through consistent `📍` state changes, while a dialectical or issue-centered spine preserves its conflict or evidence chain;
- a `Canonical Article` is self-contained inside its declared scope, works examples rather than naming them, includes supported common mistakes, and closes with three to five useful Further Reading items;
- every admitted visual adds a relationship that the nearby prose does not already make equally recoverable, appears after plain-language grounding, has a bold one-line caption, and stays inside the evidence boundary;
- no visual contains unsupported nodes, arrows, comparisons, or broken asset references;
- field-wide momentum, prevalence, consensus, or decline claims have trend-capable evidence or are scoped to the current source set;
- the final coverage boundary matches the admitted corpus and claim-strength ceiling;
- Digest Note, Spine Contract, visual evidence ledger, retired Domain Use Contract, retired Domain Payoff, and Learning Spine fields do not leak into prose.

For source-dive also check:

- the article does not lose “why” after introducing mechanisms;
- author motive is not reverse-engineered from source structure;
- mechanism, capability, cost, and boundary form a closed chain;
- runtime observations remain separate from static and weave inference;
- a non-`apply` run does not force migration advice;
- reading intent and Engineering Decision Brief fields do not leak into prose.
- reading scope and System Design Brief fields do not leak into prose.

For source-dive `system` also check semantically:

- the opening answers what the tool is, who it serves, what problem it solves, and which major capabilities users gain;
- a compact system model identifies entry, core state, orchestration, capability modules, and host or external boundary;
- one representative task crosses the system end to end and owns its failure or shutdown path;
- local mechanism chapters reconnect to that system model instead of becoming isolated correct explanations;
- three to five evidence-backed Project Takeaways can be restated without source identifiers;
- Project Takeaways have not been rewritten as adoption or migration advice.

These are semantic checks. Do not treat title presence, a diagram fence, or a heading named “takeaways” as proof. For `system` eval, smoke, or audit runs, use the independent-reader audit defined in `source-dive.md` when an independent agent is available.

If the title outruns the article, deepen the missing explanation or narrow the title. Do not add a summary paragraph that merely repeats the title.

## Layer 2: Evidence and time integrity

For every source and volatile load-bearing claim:

- reopen the canonical page and confirm title, URL, author or repository, and stable identifier agree;
- distinguish the source's publication-time state from a repository or document checked later;
- label numerical claims by source time when the value can drift;
- preserve internal source conflicts instead of silently choosing one number;
- use direct attribution only for what the source actually states; introduce derived diagrams or mechanisms as weave synthesis;
- keep unsupported comparisons, private outcomes, and current-state extrapolations outside the conclusion.

Search snippets, redirect guesses, provisional URLs, and a source author's own benchmark headline are not independent verification.

## Layer 3: Serialized-file integrity

Run the executable checker against the written file when PowerShell 7 is available:

```powershell
pwsh -NoProfile -File <weave-skill-root>/scripts/check-article.ps1 -ArticlePath <article.md>
```

Resolve `<weave-skill-root>` from the installed skill location; do not assume the article's working directory contains weave's `scripts/` folder.

The executable gate rejects files larger than 512 KiB before reading the full Markdown. This is a safety bound for the serialized-article scanner, not a target article size.

The checker covers only unambiguous properties: required frontmatter, title/H1 agreement, duplicate sources, known malformed source shapes, fence balance, malformed punctuation, damaged blockquotes, repeated long fragments, and leaked internal-artifact headings. It ignores fenced code when scanning prose and excludes a final Further Reading or reference appendix from repeated-fragment detection, because a source title may legitimately recur there.

Then read the file once more. Mechanical success cannot prove title closure, correct attribution, temporal honesty, or good prose.

## Failure handling

- **Semantic miss**: revise the affected section or narrow the title, then rerun research review and this pass.
- **Evidence or time miss**: reopen the source, correct the claim and downstream synthesis, then rerun the affected chapter review.
- **Serialized-file miss**: fix the final Markdown and rerun Voice Pass when wording changed, followed by the executable checker.
- **Unavailable checker**: perform the same serialized-file checks manually and report `Article Integrity: manual; executable checker unavailable`. Audit-sensitive runs still require the executable gate.

The delivery report may say `Article Integrity: passed` and name material degradation. It must not reproduce the internal contract. This status is required for every route.
