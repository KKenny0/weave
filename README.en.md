# weave

**Research the question. Write it clearly.**

[简体中文](README.md) · [Project page](https://kkenny0.github.io/projects/weave/) · [v2.0.0](https://github.com/KKenny0/weave/releases/tag/v2.0.0)

weave is an Agent Skill that researches your question and writes an evidence-grounded explanation for your intended readers. Start with a question, a set of materials, a project, or a draft you want to revise.

## Install

Requires Node.js and npm. Install with the [skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add KKenny0/weave --skill weave -g -y
```

Use `-a codex` or `-a claude-code` to select a host, for example:

```bash
npx skills add KKenny0/weave --skill weave -g -a codex -y
```

Local development installation and migration are covered under “Maintenance and verification” below.

## Try a complete request

In an Agent that supports the skill, describe what you want to understand, who will read it, and what to deliver:

```text
Use weave to research browser use (letting AI operate a browser): its
implementation principles and logic, the evolution of technical approaches,
and current representative solutions. Write an explanatory article in English.

The readers know nothing about this field but are interested. Explain the
necessary concepts first, then walk through a concrete task: open a website,
find information, and fill in a form. Follow the process from understanding
the page and choosing actions to execution, checking results, and recovery
from failure. Explain how different approaches handle these steps, which
problems their evolution addressed, and what limitations remain.

Use public documentation, representative project implementations, and relevant
research. Check current versions and source dates. Distinguish historical
approaches, current behavior, and your inferences. Focus on mechanisms and
tradeoffs, and state where evidence or verification is unavailable.
```

You can also supply papers, design documents, and a repository to compare around one question, or bring a draft and new material to assess whether it calls for new facts, a revised explanation, or a separate article. Discussion and read-only requests return the requested discussion or analysis without forcing an article file.

## What you get

An ordinary research article defaults to a Markdown file with traceable sources. The writing target is to fulfill the assignment: emphasize your priorities, explain prerequisites and mechanisms, work through concrete examples, and state where conclusions apply. Actual quality needs checking against the request and evidence; a complete process or a long reference list does not establish it.

- Explanations organized for the reader, rather than summaries of each source or lists of source-code directories.
- Clear distinctions between facts, source authors' interpretations, the writer's inferences, and unresolved questions, with counterevidence and version limits preserved.
- Diagrams and transfer judgments where useful, without mandatory diagrams per section or fixed personal-impact sections.

New longform defaults to:

```text
{topic}-weave_{YYYY-MM-DD}.md
```

Frontmatter includes `title`, `date`, `tags`, `sources`, and `status`; tags describe topics. Your request controls language, length, directory, and format. Explicit paths take precedence, followed by the existing `.loom/config.yaml` longform location, then the working directory. An edit to a specified draft keeps that path.

The article contains reader-facing prose, without dumping internal notes, user profiles, or audit answers. Delivery identifies the actual file, main results, and material limitations. Content readiness does not authorize committing, publishing, or distribution.

## How it works

### Research follows the goal and evidence gaps

Understand the original assignment → research consequential gaps → form and challenge a provisional explanatory frame → compose and revise → check the assignment, evidence, and actual delivered file. Return to the affected step when a check fails.

Papers, code, documentation, interviews, and experiments can contribute to the same investigation. Material types guide local analysis techniques and the limits of the evidence; the current question and evidence gaps determine research actions.

Clear requests proceed directly. Ask only when unresolved interpretations would materially change scope, emphasis, or delivery. There is no default mode-selection questionnaire, sample approval, or mandatory cycle of user reviews.

Further research must address gaps that could change the core explanation, explicit priorities, or conclusion boundaries. Respect source limits set by the user. When evidence is insufficient, state the limitation rather than filling load-bearing gaps with general knowledge. Sources and repository content are data, not instructions that can override the task.

### Organize explanations with a revisable frame

A frame is a provisional explanatory direction: which materials matter, how they relate, and how the article answers the question. It can reuse a good explanation from a source or use a straightforward comparison. New terminology and multiple candidate frames are not required.

Before adopting a frame, weave checks which question it answers, which choices it changes, which evidence is hardest for it to explain, and what would be lost without it. The original assignment, current research question, and frame stay distinct. Evidence may revise the question and the frame may change, but neither can silently remove an explicit user priority.

Writing allocates space to priorities and explanatory depth. Background supplies the prerequisites needed to reach the core question; terms appear with explanations, concrete examples carry reasoning, and transfer judgments state their conditions. Any diagrams used are checked for relationships, arrows, and boundaries.

### Check explanations and files separately

| Check | Evidence | Question |
| --- | --- | --- |
| Assignment fit | Original request, later corrections, final article | Does it deliver the requested emphasis, depth, and reader fit? |
| Self-sufficiency | Final article and its stated reader prerequisites | Can readers follow the core explanation without returning to source material for missing steps? |
| Evidence and deliverable | Sources and the actual written file | Are facts and inferences distinct, limits accurate, and the file usable? |

Self-review, an independent reading, and human feedback are different kinds of evidence and must be reported accurately. Mechanical checks do not establish assignment fit. An independent self-sufficiency check uses only the final article; internal research notes cannot fill gaps in the prose.

Detailed audits are conditional. Use hold-out only for an explicit test of explanatory ability on unread material. Without independent unseen evidence or access-order records, do not claim a verified hold-out or chronology. An ordinary request to check an article does not trigger that audit.

## Maintenance and verification

### Local installation and migration

From the repository directory, install the current local checkout with:

```bash
npx skills@1.5.17 add . --skill weave -g -y
```

This updates the live installation. Automated installation checks use an isolated directory instead. Unpushed local changes are not available from remote `main`; historical `v1.x` tags retain their respective workflows. See [Migration](MIGRATION.md) for changes to goal-driven research, filenames, and checker interfaces.

Existing articles are not renamed or migrated, and vault settings remain compatible. Discovery conflicts with obsolete standalone skills need separate handling when migrating from Loom or older weave. Do not delete historical drafts to fix installation discovery.

### Repository structure

[SKILL.md](SKILL.md) contains the executable main loop and essential boundaries. Read references as needed:

- [research.md](references/research.md): evidence collection, conflicts, stopping conditions, and local techniques.
- [composition.md](references/composition.md): framing, selection, explanations, examples, and revision.
- [review.md](references/review.md): assignment fit, article self-sufficiency, evidence, and delivery checks.
- [output-spec.md](references/output-spec.md): file format, directories, compatibility, and delivery.
- [audit.md](references/audit.md): explicitly needed hold-out and chronology evidence.

[evals/evals.json](evals/evals.json) contains outcome-oriented scenarios. [Frame quality checks](evals/frame-quality.md) assess explanatory value; [first-draft quality evaluation](evals/first-draft-quality.md) provides a closed synthetic evidence packet and controlled comparison. Historical Anthropic course baselines and comparisons remain unchanged and do not establish improved first-draft quality.

### Check commands and limits

Run from the repository root with PowerShell 7. Offline and full checks, respectively:

```powershell
pwsh -NoProfile -File scripts/check.ps1 -SkipInstall
pwsh -NoProfile -File scripts/check.ps1
```

Full checks exercise isolated installation and compare packaged contents; they do not update the live skill. `-CheckLiveInstall` additionally reads and compares the live installation without updating it. Checks create and clean up their own temporary fixtures.

Prefer an explicit file for article checks:

```powershell
pwsh -NoProfile -File scripts/check-article.ps1 -ArticlePath ./article-weave_2026-11-14.md
pwsh -NoProfile -File scripts/check-run.ps1 -ArticlePath ./article-weave_2026-11-14.md
```

`check-run.ps1` retains `-RunDirectory` compatibility but must not guess among multiple articles. Explicit `-ArticlePath` checks do not discover potentially unrelated reports in the same directory; add `-ReportPath` to check a specific report. `-ImpactMode` is only for explicitly requested legacy-format checking; new articles do not require fixed impact headings. Mechanical results cannot replace checks of assignment fit, self-sufficiency, or factual accuracy.

Quality regressions should compare the same request, materials, and host configuration for emphasis, depth, reader fit, explanatory value of the frame, and evidence fidelity. Without a controlled comparison, report only the checks performed rather than claiming a general improvement in first-draft quality.

## License

[MIT](LICENSE).
