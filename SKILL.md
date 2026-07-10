---
name: weave
description: >
  Multi-source research pipeline that produces a polished Chinese longform article from any of: source bundle (papers/articles/interviews/reports), technical project (GitHub repo + docs), or domain name. Auto-scouts sources when the user only has a topic. Use whenever the user asks in any language to 深入研究, 研究一下, 深度阅读, source dive, 测绘领域, 写一篇 X 的深度解析, 整理成研究文章, research, deep dive, study, or wants to understand anything from "this paper" to "this domain" deeply enough to write about it. Always triggers when the user provides URLs + analysis intent, GitHub URLs + "how does this work", or domain names + "what's the state of". Even if the user doesn't explicitly say "research" — if they share material and want to understand it deeply with a written output, use this skill.
when_to_use: "深入研究, 研究一下, 深度阅读, 帮我读这篇论文, source dive, 研究这个项目源码, 测绘这个领域, 这个领域现在什么状态, 领域地图, 写一篇 X 的深度解析, 整理成研究文章, research, deep dive, study, compile sources, unfamiliar domain"
dispatch_intent: "Multi-source research producing a structured Chinese longform article"
---

# Weave: From Topic or Sources to Chinese Longform Article

Take a research target — source bundle, technical project, or domain name — and produce a polished, evidence-grounded Chinese longform article with dialectical testing and voice discipline applied.

## Outcome Contract

- **Outcome**: User gets a polished, evidence-grounded Chinese longform article on their topic, with multi-perspective debate testing, anchor-based narrative, and voice pass complete.
- **Done when**: Sources collected (auto-scouted or user-provided), contradictions surfaced explicitly, every chapter traces to a Source Brief / Synthesis Pack field, voice pass complete.
- **Evidence**: Source URLs/files, fetched content, Source Briefs, Synthesis Pack, Voice Pass diff observations.
- **Output**: Single `.md` file with YAML frontmatter (`title`, `date`, `tags`, `sources`, `status`), named `{topic}-{workflow}_{YYYY-MM-DD}.md`.
- **Boundary**: One URL that only needs fetching belongs in `/read`. Single-article summary without multi-source synthesis belongs in chat. This skill is for full-pipeline research that produces a new structured longform.

## Pre-check

- `mcp__web-reader__webReader` available? If not, auto-scout falls back to native fetch with reduced coverage on paywalled / JS-heavy / Chinese-platform pages.
- `WebSearch` available? If not, user MUST provide sources (auto-scout disabled).
- Background Agent available? If not, Phase 2 reading serializes (slower but works).
- **Fetch budget: 3 attempts max per source** across all available tools (native fetch → mcp__web-reader__webReader → web cache). If all 3 fail, stop retrying that source. Write a short fetch-failure note in the delivery report (which source, which tools tried, final error) and either continue with remaining sources or, if this source was load-bearing, follow the user-URL failure path in `references/collect.md` Case 1.

## Choose Workflow (Routing)

This skill runs one of three workflows based on what the user provided. The routing table is load-bearing — wrong route means wrong methodology applied.

| User input shape | Route to | Why |
|---|---|---|
| URL / PDF / file / pasted text (non-technical prose — papers, articles, interviews, reports, book chapters) | `references/deep-read.md` | Source bundle → dialectical article |
| Technical project name / GitHub URL / framework name | `references/source-dive.md` | Code/tech project → implementation deep-dive |
| Domain name / research direction ("RAG", "agent memory systems", "knowledge graph reasoning") | `references/survey.md` | Domain → 学案体 map |
| Ambiguous ("研究 X" with no input-type signal) | **Ask user**: "要深读具体素材、研究技术实现、还是测绘领域？" | Never guess. Wrong route = wrong methodology. |

When ambiguous, ask. Don't auto-pick — methodology choice is load-bearing.

**Implementation status**: All three workflows (`references/deep-read.md`, `references/source-dive.md`, `references/survey.md`) are implemented. The old standalone `/deep-read`, `/source-dive`, and `/survey` skills are retired; their development sources remain available for recovery.

## Shared Phases (all workflows)

Every workflow runs these shared phases. Workflow-specific phases live in `references/{workflow}.md`:

1. **Collect** — gather sources (auto-scout or user-provided). See `references/collect.md`.
2 through N-1. **Workflow-specific** — see `references/{workflow}.md`.
N. **Voice Pass** — de-AI scan + apply user-style from prior outputs. See `references/voice-pass.md`.

Output naming, paths, YAML frontmatter: see `references/output-spec.md`.

## Hard Rules

- **No fabrication.** Every claim in the final article must trace to a source. Auto-scout finds sources first, then writes.
- **No Phase N+1 before Phase N solid.** Section-source mapping must be confirmed before Compose begins — every chapter maps to a Source Brief / Synthesis Pack field, or the chapter gets cut.
- **Stop at publish confirmation.** After user confirms article is ready, do NOT push, post, distribute, or commit (unless explicitly asked).
- **Voice Pass is not optional.** Every output goes through de-AI scan + style scan.
- **Ask when routing is ambiguous.** Don't guess workflow.

## Gotchas

| What happened | Rule |
|---|---|
| Routed survey input to deep-read (treated domain as one source) | Domain names go to `references/survey.md`. deep-read needs concrete sources, not domains. |
| Auto-scout found 30 marketing pages, no primary sources | Filter: drop SEO farms / product-only pages, prefer papers / official blogs / repo docs. If <3 quality sources remain, honestly report. |
| Skipped Voice Pass because "article looked fine" | Voice Pass always runs. AI patterns are invisible to the writer-agent. |
| Routed "research transformer" to deep-read | Ambiguous input — transformer could be domain, paper, or implementation. Ask user. |
| Composed chapter doesn't trace to any Source Brief field | Either delete the chapter, or return to Phase 2 for that sub-topic. Don't write from general knowledge. |
| Fabricated a quote because auto-scout source was thin | Quote only what's in sources. If a key claim has no source, mark `[未找到源]` and surface in delivery report. |
| Auto-picked workflow when input was ambiguous | Stop and ask. Routing errors cascade into wrong methodology. |
