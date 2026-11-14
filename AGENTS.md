# Maintaining Weave

## Read before changing

- Read SKILL.md for the runtime workflow and README.md for repository context. Keep the runtime, documentation, evaluation cases, and checker behavior consistent in the same change.
- Read the relevant references/ document before changing its guidance. Read MIGRATION.md when changing installation or legacy compatibility.

## Runtime boundaries

- Maintain one integrated skill: the user's original request and subsequent corrections control focus, depth, reader prerequisites, and deliverable. Research actions follow evidence gaps; material types supply local analysis reminders, not mandatory routes.
- Preserve the distinction between the user's goal, the current research question, and the provisional frame. Replacing a frame cannot silently remove explicit user priorities; explain how contrary evidence affects the original goal.
- Keep SKILL.md executable on its own with references read on demand. The five references are research.md, composition.md, review.md, output-spec.md, and audit.md. Special audits require an explicit need for audit evidence; ordinary completeness checks do not imply hold-out.
- Make first-draft quality the writer's responsibility: sufficient depth on user priorities, load-bearing mechanisms and examples, necessary prerequisites, and clear transfer conditions. Do not add default sample approval or human-review gates.
- Preserve source attribution, fact/inference separation, counterevidence, version limits, privacy, resistance to instructions embedded in sources, final-file readback, and separate publication authorization.
- Do not persist user briefs, raw private conversations, profiles, or internal schemas. Do not fabricate unread evidence, runtime verification, access order, fresh-context review, or human understanding.
- Preserve user-path precedence and .loom/config.yaml compatibility. New default articles use {topic}-weave_{YYYY-MM-DD}.md and title/date/tags/sources/status; tags describe topics. Do not migrate historical drafts.
- Keep changes within task ownership. Never modify unrelated untracked plans or drafts, or change the license as incidental cleanup. Do not restore obsolete route-reference stubs or standalone route skills.

## Verification

- Review changed Markdown for valid local links, consistent instructions, exact output requirements, and preserved evidence/privacy boundaries. Check the actual diff and final files.
- When a behavioral rule changes, coordinate corresponding docs, regression cases, and checker updates with their owners. Do not edit files owned by another concurrent task.
- Run repository checks from the repository root with PowerShell 7: `pwsh -NoProfile -File scripts/check.ps1 -SkipInstall` for offline validation and `pwsh -NoProfile -File scripts/check.ps1` for full validation including isolated installation. Tests create workspace-local fixtures and must clean them without modifying the live skill installation.
- Article checks use `scripts/check-article.ps1 -ArticlePath`. Run checks use `scripts/check-run.ps1 -ArticlePath`; explicit files do not auto-associate reports. Use `-ReportPath` for a specific report. Keep `RunDirectory` compatibility and the explicitly requested legacy `ImpactMode` checks.
- Historical course artifacts and first-draft trial outputs are evidence fixtures. Preserve their original contents; record later corrections or limitations separately rather than rewriting a baseline to improve its score.
- Report checks actually performed, contract incompatibilities, and remaining unverified behavior. Markdown consistency does not prove runtime article quality or integration readiness.
