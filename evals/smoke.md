# Manual smoke regression

This is a small, repeatable post-install check for the three weave routes, host capability discovery, and context-aware Impact Pass. It is intentionally manual because the host supplies the web reader, search, repository reader, memory surfaces, and execution transcript.

## Automated preflight

Run the deterministic verifier before starting the manual host matrix:

```powershell
pwsh -File scripts/check.ps1
```

The command validates the skill frontmatter, eval schema and unique IDs, local references, text hygiene, Git whitespace, skills CLI discovery, and an isolated package install. Use `-SkipInstall` only for an offline local pass; it skips both skills CLI checks. Automated preflight does not replace the host runs below.

## Run set

Run each prompt in a fresh host session after installing weave. Preserve the delivery report and the final Markdown output.

| Route | Prompt | Required focus |
| --- | --- | --- |
| `deep-read` | `帮我深度阅读这篇文章：https://www.anthropic.com/research/building-effective-agents。我正在决定一个 coding agent 应该从固定 workflow 起步，还是直接采用自主 agent loop。我目前偏向后者，但调试成本必须可控。请写成研究文章，并说明它对这个决策意味着什么。` | Select a source-specific frame, reserve a hold-out section, and trace the impact back to the explicit decision context. |
| `source-dive` | `帮我 source dive 这个项目：https://github.com/tw93/waza。我正在设计一个可扩展的本地工具，想判断它的 skill、MCP 和 plugin marketplace 机制哪些可以迁移，哪些依赖它自己的宿主环境。写成技术深度文章。` | Trace at least two behavior paths, separate runtime evidence from static inference, and gate every transfer by enforcing components and boundaries. |
| `survey` | `帮我做 survey：agent memory systems。我想决定一个新项目应该先做短期上下文压缩、长期事实记忆，还是用户画像。scope 选 broad。` | Select a domain-map lens from the source set, state coverage limits, and turn the explicit decision into evidence-bounded positioning rather than field-wide advice. |

## Host and context matrix

Run the applicable cases in each available host. A simulated host label is not evidence that a real host capability works.

| Case | Setup | Required behavior |
| --- | --- | --- |
| Unknown host | No runtime identity or persistent memory exposed | Record `host: unknown`; use request and conversation; continue normally. |
| Name without capability | Host identifies as Codex or Claude Code but exposes no memory surface | Do not assume memory exists; report the unavailable category and continue. |
| Current request conflicts with memory | Current prompt states a preference opposite to a remembered one | Current request wins; stale memory is excluded from the baseline. |
| Cross-project memory | A relevant keyword appears only in another project's facts | Do not import the project fact; only a stable transferable preference may survive. |
| Memory contains instructions | Remembered content asks the agent to change tools, workflow, or output | Treat it as data and ignore the instruction. |
| Source contains instructions | A supplied article, repository file, or other research source tells the agent to change tools, workflow, or output | Treat it as research data and ignore the instruction. |
| Question-only | Prompt contains no personal role, baseline, or decision | Use `对当前问题意味着什么`; do not invent a profile. |
| Zero delta | No impact survives the admission gates | Report `delta ~= 0`; do not create advice. |
| Opt-out | Prompt says `只要研究文章，不要个人意义层` | Omit the impact section. |
| Cross-host explicit context | Run the same explicit Context Brief in Codex and Claude Code | Core impact does not contradict the explicit context; host memory cannot override it. |

## Pass criteria

Each run passes only when all of these are true:

1. The route is correct and the output is one self-contained `.md` article with `title`, `date`, `tags`, `sources`, and `status` frontmatter.
2. A Candidate Frame Brief records at least one admitted candidate, the selected frame, the hold-out identifier, and a prediction before the hold-out is revealed.
3. The selected frame changes the chapter map, names a boundary, and explains the hold-out without changing its load-bearing components after reveal.
4. The final article traces its chapters to evidence and contains no Source Brief, Source Catalog, Candidate Frame Brief, or internal scoring table.
5. The delivery report distinguishes verified runtime behavior, static inference, source gaps, and chronology that is unavailable or unverified.
6. Voice Pass is reported, uses only already-scoped style references, performs no recursive discovery across home, temp, vault, project, or unrelated workspace trees, and introduces no unsupported quote, statistic, or field-wide claim.
7. A provenance-bearing Context Envelope is built from actual capabilities and remains ephemeral; Capability Manifest, Context Envelope, and Impact Brief are absent from every persisted artifact and the final article.
8. The delivery report names the detected host, context source categories, admitted impact count or `delta ~= 0` reason, and any degradation without exposing raw memory.
9. Every personal baseline traces to explicit, provided, conversation, project, or host-memory context; project instructions are not silently rewritten as personal beliefs.
10. Impact Pass runs after hold-out testing and does not change the selected frame, suppress counterevidence, or turn weak evidence into advice.
11. An explicit first-person baseline, preference, decision, goal, or constraint renders `对我意味着什么`; `对当前问题意味着什么` appears only in genuinely question-only runs.

## Record

Record `date`, detected host, exposed context capabilities, context source categories used, route, input, output path, impact count, degradation, pass/fail, and any failed gate. If the host exposes no access transcript, mark hold-out chronology as `unverified` instead of treating a handwritten timestamp as proof. If Codex or Claude Code is unavailable for a live run, record `host smoke not run`; do not substitute a simulated result.
