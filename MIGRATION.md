# From Loom to weave

`KKenny0/loom-skills` is archived. `KKenny0/weave` is the maintained home for the research pipeline.

## What moved

| Loom skill | weave route |
| --- | --- |
| `deep-read` | `deep-read` route for papers, articles, interviews, reports, and book chapters |
| `source-dive` | `source-dive` route for repositories, frameworks, and technical projects |
| `survey` | `survey` route for domains and research directions |

Install the new skill with:

```bash
npx skills add KKenny0/weave --skill weave -g -y
```

For a host-specific installation, append `-a codex`, `-a claude-code`, or another supported agent identifier. Manual clone fallback and host-specific paths are documented in [README.md](README.md#安装).

## What remains archived

`debate`, `excavate`, `forge`, and `loom-maintain` remain in `loom-skills` for historical reference. They are not part of weave and do not have a one-to-one replacement in this migration. The archived repository remains readable and forkable, but receives no maintenance updates.

## Compatibility

- Existing `.loom/config.yaml` vault configuration remains a compatibility input for weave output paths.
- This migration does not rename existing vault directories or rewrite stored artifacts.
- weave's finished article is still the public output. Candidate frames, hold-out predictions, and audit notes remain internal run artifacts.

## Quality boundary

weave is a narrower product than Loom. Its quality claim is the evidence-to-frame-to-article pipeline, not the preservation of every former Loom utility. Use [`evals/smoke.md`](evals/smoke.md) to run one representative check for each route after installation.

## English summary

Loom is archived. `deep-read`, `source-dive`, and `survey` moved into weave; `debate`, `excavate`, `forge`, and `loom-maintain` remain read-only historical skills in the old repository. Existing `.loom/config.yaml` paths stay compatible for now.
