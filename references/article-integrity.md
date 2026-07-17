# Article Integrity Pass

Run after Voice Pass and after the final Markdown file has been written. This pass verifies the artifact the user will actually receive. It does not replace source reading, frame selection, research review, or Voice Pass.

Deep-read runs must pass all three layers below before delivery. Keep the working fields internal; render only finished prose in the article and a one-line pass/fail result in the delivery report.

## Article Closure Contract

Before Compose, record in working memory:

- **Title promise**: the question, distinction, or central term the title promises to explain.
- **Closure locations**: the thesis plus at least two body locations that jointly fulfill that promise.
- **Attribution boundary**: which load-bearing statements come directly from sources and which are weave synthesis.
- **Time boundary**: which volatile facts belong to source time, retrieval time, or a later current-state check.
- **Editorial-note policy**: whether each blockquote is a source quotation or an intentional author note; glossary explanations belong in prose.
- **Final boundary**: the condition or missing evidence that limits the article's conclusion.

This is a composition control, not a new persisted artifact. Do not add an `Article Closure Contract` section or field dump to the article or delivery report.

## Layer 1: Semantic closure

Read the final file and check:

- the title promise is answered by the thesis and developed in the named closure locations;
- a central term in the title is not mentioned once and then abandoned;
- every chapter still serves the selected frame after Voice Pass edits;
- source findings, weave synthesis, and context-bound application remain distinguishable;
- terminology explanations are integrated where the term first carries load rather than inserted as detached editorial notes;
- the final boundary is visible and consistent with the body.

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

The checker covers only unambiguous properties: required frontmatter, title/H1 agreement, duplicate sources, known malformed source shapes, fence balance, malformed punctuation, damaged blockquotes, repeated long fragments, and leaked internal-artifact headings. It ignores fenced code when scanning prose.

Then read the file once more. Mechanical success cannot prove title closure, correct attribution, temporal honesty, or good prose.

## Failure handling

- **Semantic miss**: revise the affected section or narrow the title, then rerun research review and this pass.
- **Evidence or time miss**: reopen the source, correct the claim and downstream synthesis, then rerun the affected chapter review.
- **Serialized-file miss**: fix the final Markdown and rerun Voice Pass when wording changed, followed by the executable checker.
- **Unavailable checker**: perform the same serialized-file checks manually and report `Article Integrity: manual; executable checker unavailable`. Audit-sensitive runs still require the executable gate.

The delivery report may say `Article Integrity: passed` and name material degradation. It must not reproduce the internal contract.
