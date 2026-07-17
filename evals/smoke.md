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
| `deep-read` | `帮我深度阅读这篇文章：https://www.anthropic.com/research/building-effective-agents。我正在决定一个 coding agent 应该从固定 workflow 起步，还是直接采用自主 agent loop。我目前偏向后者，但调试成本必须可控。请写成研究文章，并说明它对这个决策意味着什么。` | Select a source-specific frame, reserve a hold-out section, trace the impact back to the explicit decision context, and pass Article Integrity on the serialized file. |
| `source-dive` | `帮我 source dive 这个项目：https://github.com/tw93/waza。我正在设计一个可扩展的本地工具，想判断它的 skill、MCP 和 plugin marketplace 机制哪些可以迁移，哪些依赖它自己的宿主环境。写成技术深度文章。` | Trace at least two behavior paths, separate runtime evidence from static inference, and gate every transfer by enforcing components and boundaries. |
| `survey (orient)` | `帮我做 survey：agent memory systems。我想理解这个领域由哪些机制和争论构成，但现在不做产品或架构选型。scope 选 broad。` | Build an orient Map Use Contract, select a lens that changes a concrete distinction or failure boundary under a named condition, and do not force product advice. |
| `survey (choose)` | `帮我做 survey：agent memory systems。我想决定一个新项目应该先做短期上下文压缩、长期事实记忆，还是用户画像。scope 选 broad。` | Build a choose Map Use Contract, close a condition-dependent Map Payoff after hold-out testing, and turn the explicit decision into evidence-bounded positioning rather than field-wide advice. |

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
2. An audit/smoke run creates and reads back `.weave-frame/pre-reveal.md` before reveal. The file records only the allowed Candidate Frame Brief, provisional selection, hold-out identifier, prediction, timestamp, workflow, and non-personal topic fields. Every line, including selection rationale inside allowed fields, excludes the user, team/project, current decision, preference, goal, constraint, memory, and context-fit rationale. Without a clean file, chronology and hold-out validation fail.
3. The selected frame changes the chapter map, names a boundary, and explains the hold-out without changing its load-bearing components after reveal.
4. The final article traces its chapters to evidence and contains no Source Brief, Source Catalog, Candidate Frame Brief, or internal scoring table.
5. The delivery report distinguishes verified runtime behavior, static inference, source gaps, and chronology that is unavailable or unverified.
6. Voice Pass is reported, uses only already-scoped style references, performs no recursive discovery across home, temp, vault, project, or unrelated workspace trees, and introduces no unsupported quote, statistic, or field-wide claim.
7. Every final source title, URL, and stable identifier matches an opened canonical source page; no guessed, mismatched, duplicate, or provisional citation remains.
8. A provenance-bearing Context Envelope is built from actual capabilities and remains ephemeral; Capability Manifest, Context Envelope, renamed or paraphrased context summaries, Impact Brief, and Article Closure Contract are absent from every persisted artifact and the final article. The delivery report follows `output-spec.md`'s allowlist and contains no internal-artifact section names or schemas.
9. The delivery report names the detected host, context source categories, admitted impact count or `delta ~= 0` reason, and any degradation. It does not quote or paraphrase personal baselines, decisions, preferences, goals, constraints, raw memory, or individual admitted impacts.
10. Every personal baseline traces to explicit, provided, conversation, project, or host-memory context; project instructions are not silently rewritten as personal beliefs.
11. Impact Pass runs after hold-out testing and does not change the selected frame, suppress counterevidence, or turn weak evidence into advice.
12. An explicit first-person baseline, preference, decision, goal, or constraint renders the literal heading `## 对我意味着什么`; a genuinely question-only run renders the literal heading `## 对当前问题意味着什么`. Neither heading is paraphrased or specialized. An explicit opt-out renders neither.
13. `scripts/check-run.ps1` exits zero for the run directory and the expected `personal`, `question`, or `none` mode. A self-authored pass statement cannot substitute for this result.
14. A survey run identifies one primary `orient`, `choose`, `enter`, or `evaluate` intent before search, records an evidence ceiling after source collection, and keeps Map Use Contract and Map Payoff fields out of the final article and delivery report.
15. An `orient` survey changes a concrete distinction or failure boundary without forcing selection. A `choose` survey expresses `condition -> choice -> cost -> verification evidence`, and no survey recommendation exceeds the Map Payoff's evidence ceiling.
16. Survey Impact Pass traces to the completed Map Payoff: it may personalize or prioritize the payoff, but it does not create a recommendation or field-wide claim absent from that payoff.
17. A deep-read run builds a working-memory Article Closure Contract before Compose. The title promise is answered by the thesis and developed in at least two body locations; the contract never appears as a final-article section or report field.
18. Deep-read distinguishes direct source claims from weave synthesis, marks volatile facts by source or retrieval time, preserves internal numerical conflicts, and reopens every final source identity before delivery.
19. The serialized article passes `scripts/check-article.ps1`; the delivery report records `Article Integrity: passed`, and `scripts/check-run.ps1` rejects a self-authored report when the actual article fails.

## Record

Record `date`, detected host, exposed context capabilities, context source categories used, route, input, output path, impact count, Article Integrity result, degradation, pass/fail, and any failed gate. If the host exposes no access transcript, mark hold-out chronology as `unverified` instead of treating a handwritten timestamp as proof. If Codex or Claude Code is unavailable for a live run, record `host smoke not run`; do not substitute a simulated result.
