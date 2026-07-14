# Output Specification

## File naming

`{topic}-{workflow}_{YYYY-MM-DD}.md`

- `{topic}`: 2-6 字简洁主题名 (从素材推断或用户指定)
- `{workflow}`: `deep-read` / `source-dive` / `survey` (which workflow ran)
- `{YYYY-MM-DD}`: `date +%Y-%m-%d` at write time

Examples:

- `anthropic-agent-architecture-deep-read_2026-05-29.md`
- `hermes-agent-source-dive_2026-06-15.md`
- `rag-survey_2026-07-07.md`

## YAML frontmatter (required at file top)

```yaml
---
title: {主题}
date: {YYYY-MM-DD}
tags: [{workflow}, {主题标签}]
sources:
  - {source 1 URL or path}
  - {source 2 URL or path}
status: draft
---
```

Workflow-specific extra fields:

- **survey**: add `topic: {领域}` and `scope: {broad/focused}`
- **source-dive**: add `source_repo: {repo_url}` and `source_docs: {docs_url}` if applicable

## Output path priority

1. User-specified `output_dir` → use that
2. Vault config exists (`.loom/config.yaml` `vault_path`) → `<vault-root>/03_Content_Output/Longform/`
3. Otherwise → current working directory

## Context-aware impact section

The filename and YAML schema do not change when Impact Pass runs.

- Use `## 对我意味着什么` only when the Context Envelope supports a personal baseline or decision.
- Use `## 对当前问题意味着什么` with question-only context.
- When no impact passes admission, keep the applicable heading and state the `delta ~= 0` reason briefly.
- Omit the section when the user explicitly requests a pure research article without personal implications.
- Place the section after the explanatory body and before a final evidence-boundary or coverage statement when the workflow has one.

The section is finished article content, not a dump of internal fields.

## Never

- Don't change the naming pattern
- Don't omit YAML fields
- Don't put pipeline artifacts (Capability Manifest, Context Envelope, Source Brief tables, Synthesis Pack, Candidate Frame Brief, Impact Brief, Evidence Weight grids, internal notes) in the output file — only the finished article
- Don't expose raw remembered material, private memory paths, or unrelated user context
