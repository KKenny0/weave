# weave

[简体中文](README.md) · [Migration](MIGRATION.md)

weave is an Agent Skill for research and longform writing. It starts from the user's question, intended readers, and desired understanding, then chooses research actions as evidence gaps appear. Papers, code, documentation, interviews, and drafts can participate in the same investigation; material types do not select fixed workflows.

Its main quality target is a useful first draft: the right emphasis, sufficient explanatory depth, necessary reader prerequisites, worked examples, and honest evidence boundaries. A complete process or a polished frame does not establish that the draft fulfills the request.

## Working model

Understand the original assignment → research consequential gaps → form and challenge a provisional explanatory frame → compose and revise → check the assignment, evidence, and actual delivered file. Return to the affected step when a check fails.

The original assignment, current research question, and provisional frame stay distinct. Evidence may overturn an initial premise, and the frame may change, but a convenient frame cannot silently remove an explicit user priority. Clear requests proceed without mode selection or sample approval. Ask only when unresolved interpretations would materially change the result.

Local methods remain available when useful: trace behavior when reading implementations, distinguish measured findings from interpretation in papers, and preserve speaker attribution in interviews. These methods do not become separate end-to-end pipelines.

## Structure

`SKILL.md` contains the executable main loop and essential boundaries. Read references as needed:

- [research.md](references/research.md): evidence collection, conflicts, stopping conditions, and local techniques.
- [composition.md](references/composition.md): framing, selection, explanations, examples, and revision.
- [review.md](references/review.md): assignment fit, article self-sufficiency, evidence, and delivery checks.
- [output-spec.md](references/output-spec.md): file format, directories, compatibility, and delivery.
- [audit.md](references/audit.md): explicitly requested hold-out and chronology evidence.

Assignment fit uses the original request and later corrections. Self-sufficiency asks what can be understood from the article itself. Mechanical file checks prove neither. Self-review, an independent reading, and human feedback are reported accurately and never impersonate one another.

Hold-out testing, detailed audit reports, multiple frame options, diagrams, and personal implications are conditional. There are no mandatory impact headings, visual markers, Org-only diagrams, or universal sentence bans. Evidence fidelity, privacy, final-file readback, and separate authorization for publishing remain required.

## Output and installation

New longform defaults to `{topic}-weave_{YYYY-MM-DD}.md` with `title`, `date`, `tags`, `sources`, and `status`. Topic tags do not select workflows. Explicit paths take precedence, followed by the existing `.loom/config.yaml` longform location, then the working directory. Existing articles and vault settings are not migrated. Discussion and read-only requests do not force article creation.

Install the remote repository with:

```bash
npx skills add KKenny0/weave --skill weave -g -y
```

Install the current local checkout with:

```bash
npx skills@1.5.17 add . --skill weave -g -y
```

A local install updates the live installation. Automated installation checks use an isolated directory instead. Unpushed local changes are not available from remote `main`; historical `v1.x` tags retain their respective workflows. See [MIGRATION.md](MIGRATION.md) for changes to goal-driven research, filenames, and checker interfaces.

## Verification

```powershell
pwsh -NoProfile -File scripts/check.ps1 -SkipInstall
pwsh -NoProfile -File scripts/check.ps1
pwsh -NoProfile -File scripts/check-article.ps1 -ArticlePath ./article-weave_2026-11-14.md
pwsh -NoProfile -File scripts/check-run.ps1 -ArticlePath ./article-weave_2026-11-14.md
```

Full checks exercise isolated installation; they do not update the live skill. `-CheckLiveInstall` additionally compares the live installation. `check-run.ps1` retains directory-based compatibility but must not guess among multiple articles. Explicit `-ArticlePath` checks do not discover potentially unrelated reports in the same directory; add `-ReportPath` to check a specific report. `-ImpactMode` is optional legacy-format checking.

[First-draft quality evaluation](evals/first-draft-quality.md) defines a closed synthetic evidence packet and controlled comparison. Historical course artifacts remain unchanged and are not evidence that the new design has already improved real-world drafts.

## License

[MIT](LICENSE).
