# Manual smoke regression

This is a small, repeatable post-install check for the three weave routes. It is intentionally manual because the host supplies the web reader, search, repository reader, and execution transcript.

## Run set

Run each prompt in a fresh host session after installing weave. Preserve the delivery report and the final Markdown output.

| Route | Prompt | Required focus |
| --- | --- | --- |
| `deep-read` | `帮我深度阅读这篇文章：https://www.anthropic.com/research/building-effective-agents。我想知道它把 agent 设计成什么问题，哪些判断有证据，哪些边界没有被验证。写成研究文章。` | Select a source-specific frame and reserve a hold-out section. |
| `source-dive` | `帮我 source dive 这个项目：https://github.com/tw93/waza。我想看 skill 系统、MCP 集成和 plugin marketplace 如何从入口流到输出与失败恢复。写成技术深度文章。` | Trace at least two behavior paths and separate runtime evidence from static inference. |
| `survey` | `帮我做 survey：agent memory systems。我想看主要方法、核心争论、演化脉络、开放问题和入门路径。scope 选 broad。` | Select a domain-map lens from the source set and state coverage limits. |

## Pass criteria

Each run passes only when all of these are true:

1. The route is correct and the output is one self-contained `.md` article with `title`, `date`, `tags`, `sources`, and `status` frontmatter.
2. A Candidate Frame Brief records at least one admitted candidate, the selected frame, the hold-out identifier, and a prediction before the hold-out is revealed.
3. The selected frame changes the chapter map, names a boundary, and explains the hold-out without changing its load-bearing components after reveal.
4. The final article traces its chapters to evidence and contains no Source Brief, Source Catalog, Candidate Frame Brief, or internal scoring table.
5. The delivery report distinguishes verified runtime behavior, static inference, source gaps, and chronology that is unavailable or unverified.
6. Voice Pass is reported, and no unsupported quote, statistic, or field-wide claim is introduced.

## Record

Record `date`, host, route, input, output path, pass/fail, and any failed gate. If the host exposes no access transcript, mark hold-out chronology as `unverified` instead of treating a handwritten timestamp as proof.
