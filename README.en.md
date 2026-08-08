# weave

The primary project README is maintained in Chinese.

[Read the Chinese README](README.md)

[Migration from Loom](MIGRATION.md)

weave is an Agent Skill that turns source bundles, technical projects, and open domains into evidence-grounded Chinese longform. Deep Read handles prose sources, while Source Dive reconstructs technical systems and engineering judgments. Survey now uses Waza Learn's Collect, Digest, Outline, Fill, Refine, and Self-review sequence as its sole base workflow. It checks `/read` and `/write`, preserves Discover, Fetch, and File as separate collection operations, and recommends Quick Reference when the mode is genuinely unclear. After the outline, Weave admits two or three materially different spine candidates and requires the user to choose one, or explicitly delegate the recommendation, before drafting. Visual judgment starts with relationship evidence in Collect, continues through idea-shape digestion, prose-example-visual outlining, Fill, and Refine, and ends with a sparse admission pass rather than post-hoc decoration. Every retained visual has exactly one `<!-- weave-visual -->` marker, and the report's admitted count must equal the article marker count. Every ASCII visual uses a paired Org `#+begin_example` / `#+end_example` block no wider than 80 ASCII columns. Weave still supplies source verification, frame admission, hold-out testing, comprehension probes, impact, voice, serialized-file integrity, and fresh-context recoverability. Survey reports agent preflight separately from human Self-review and never treats either as evidence of later retention or reuse.
