<p align="center">
  <img src="assets/weave-mark.svg" alt="weave logo" width="96" />
</p>

<h1 align="center">weave</h1>

<p align="center"><strong>证据决定能说什么，承重方向决定文章怎么走。</strong></p>

<p align="center">简体中文 · <a href="README.en.md">English</a></p>

weave 是一个面向深度研究的 Agent Skill。给它一组文章、一篇论文、一个技术项目，或者一个领域名称，它会产出一篇有证据、有判断、可以独立阅读的中文长文。

它不会直接把素材压成摘要。Deep Read 和 Source Dive 会根据素材与问题建立证据模型、比较取景框并测试边界；Survey 则直接采用 Learn 的 Collect、Digest、Outline、Fill、Refine、Self-review 主干，在正式写作前增加一次用户可见的 Spine Direction Gate。视觉判断从 Collect 就开始积累证据，经过 Digest、Outline、Fill 和 Refine，最后才由稀疏的 Visual Pass 决定是否保留。三条路线最后都要通过预留证据、理解检验、Voice Pass 和实际成稿检查。

```text
宿主能力 → Context Envelope C
                    ↓
素材 x + 用户问题 q → 证据路线
                    ↓
              Reader Contract
                    ↓（仅显式公开发布意图）
              Publication Reader Extension
         ├─ Deep Read / Source Dive
         │    证据模型 → 候选框 → 选框
         └─ Survey
              Mode Gate → Collect → Digest → Outline
              → 2–3 个证据准入的 Spine → 用户选择
                         ↓
              hold-out → Comprehension Gate
                         ↓
                     Impact Pass
                         ↓
         Deep/Source：Learning Spine → 成文
         Survey：Fill → Refine → Visual Pass
                         ↓
              Voice Pass → Article Integrity
                         ↓（需要时）
                  Article Recoverability
                         ↓（Survey）
                  Human Self-review
```

## 先选证据路线，再走各自方法

| 输入 | Workflow | 主要产物 |
|---|---|---|
| 论文、文章、访谈、报告、书章 | `deep-read` | 对素材的证据化深读 |
| GitHub 仓库、框架、技术项目 | `source-dive` | 从行为路径还原工程判断的源码分析 |
| 领域名称、研究方向 | `survey` | Learn-based 领域研究与成文 |

Deep Read 和 Source Dive 还会从请求中选择 `explain / map / evaluate / decide / enter` 读者结果。Survey 不再使用这条轴，也不再保留原来的 Survey lens 库、Domain Use Contract 或 Domain Payoff。

Survey 先确认 `Canonical Article / Deep Research / Quick Reference / Write to Learn` 模式。正文方向不是系统自动套出的 map 或 primer，而是在资料消化和大纲完成后，从 2–3 个证据成立、会生成不同文章的脊柱候选中由用户选择。用户也可以提前明确“按推荐项继续”，让完整流程一次跑完。

### Deep Read

Deep Read 会根据素材的推理形状，选择论证叙事、学术论文提取、概念解剖或纵向深挖。每份 Source Brief 都会重建三个层次：作者面对的 Problem World、推动结论的 Reasoning Machine，以及接受这套解释后哪些东西变得可见或仍不能迁移的 World After。访谈会保留说话人之间的差异，学术论文会把测量结果、作者解释和可推广边界分开。

多份素材先独立阅读，避免后读的文本污染先读文本的解释；参与构框的素材各自过关后才进入 Dialogue Matrix，预留素材会在选框后测试它。矩阵只保留有证据的共同地基、术语错位、前提冲突和未决问题。候选框必须解释这些关系，不能把“作者 A 说什么、作者 B 说什么”重新排成一篇文章。

### Source Dive

Source Dive 不按目录或文件大小写源码清单。它保留触发、入口、路由、状态变化、扩展边界、输出与失败恢复这条事实骨架，再从中还原项目面对的问题、塑造实现的约束、承重设计判断，以及这些判断带来的能力、代价和失效边界。

阅读目的与阅读范围分开判断：`understand / evaluate / learn / apply` 决定为什么读，`system / subsystem / decision` 决定要重建整个工具、一个能力域还是一项设计选择。系统级请求会先说明工具身份、用户问题、主要能力、核心状态和边界，再用一条代表性任务把入口、编排、两个以上能力模块、输出与失败收束串起来；不会因为问题里提到 MCP、Provider 或 Plugin 就缩成局部机制文章。

只表达“感兴趣”或“想看看怎么实现”时，默认目标是理解与学习，不会自动补一章迁移建议。系统或学习请求仍会形成三到五条项目 takeaway；只有用户明确要接入、修改、贡献或迁移时，才进入 `apply` 分支，要求执行部件、移除后果、适用与不适用条件和验证证据。作者为什么这样设计，必须由设计说明、ADR、维护者讨论或历史记录支持；仅从源码结构还原出的理由会明确标为 weave 推断。

### Survey

Survey 的唯一主干来自 Learn：先检查 `/read` 与 `/write` 是否可用；Collect 对每个来源严格分开 Discover、Fetch、File，并以一手证据承载方法、结果、机制与局限；Digest 完整阅读并用三条 claim test 决定保留、背景或删除；Outline 要求每一节先映射来源；Fill 按节写作，卡住就回到 Digest；Refine 只做结构与表达修正；最后把 agent preflight 和用户逐行 Self-review 分开。模式确实不明确时优先建议 Quick Reference。

两项定制插在 Learn 主干的固定位置。Outline 之后、Fill 之前运行 Spine Direction Gate：候选可以是贯穿线型、扬弃型论证或议题/警示重心，但必须由证据准入并真正改变章节顺序、材料分组、解释因果或最终边界。贯穿线必须选择“奖励信号”“上下文窗口”这类可追踪的具体对象，并用 `📍` 标记每一站的状态变化。系统不会先自动选一个 frame，再让用户选择另一个装饰性 spine。

视觉不是 Refine 后才补的装饰。Collect 记录关系与边界证据，Digest 判断思想形状，Outline 固定“人话解释 → 具体案例 → 可选图 → 紧随其后的证据与适用边界”，Fill 先写解释与案例，Refine 再做表征和删除测试；之后、Self-review 之前的 Visual Pass 只是最终准入与渲染。去掉图没有损失就删掉；只看图也必须能说清概念如何作用和论文改变了什么判断，却不能得到超出实验支持的结论。每个保留图都必须在正前方放置唯一的 `<!-- weave-visual -->` 标记，交付报告的 admitted 数量必须与成稿标记数一致。ASCII 图必须使用成对的 Org `#+begin_example` / `#+end_example` 块，每行不超过 80 个 ASCII 字符，不得使用 Markdown 围栏或缩进代码块。

## 候选框怎么过关

一副候选框需要同时满足六个条件：承重部件能回溯到证据；不能原样套到相邻主题；会改变材料取舍或章节结构；清楚说明失效条件；与其他候选产生真实的解释差异；能完成请求里的可观察能力，而不只是覆盖同一个主题。

Deep Read 和 Source Dive 不追求候选数量，只有一副通过也可以。Survey 会尝试生成 2–3 个真正不同的脊柱候选；证据修复后仍只剩一个时，它会请用户决定是接受单一方向还是收窄问题，不会编造陪跑项。

选中以后，weave 会用一部分预先留出的材料测试它。测试可以是通过、部分通过或失败。如果宿主没有访问日志，weave 会保留预测内容，同时把读取顺序标成未验证，不会把一个自写时间戳当成审计证明。

## 怎么证明研究模型成立

Reader Contract 不把“深入理解”当作完成条件。它会先定义读完以后应该能够做什么，比如重建作者为什么需要某个区分、预测框架如何处理一个新案例，或者指出结论在哪个条件下失效。用户没有提供既有判断时，起始模型保持未知，不会凭主题猜测个人基线。

取景框通过预留测试以后，Comprehension Gate 会做四次检查：不用 Source Brief 的措辞重建承重解释；处理一个没有用于构框的新案例；制造一个会移除前提或越过边界的反例；最后判断原始问题是被回答、改写、消解还是仍缺证据。这里测试的是当前生成上下文中的研究模型能否被重建和使用，hold-out 测试的则是取景框能否覆盖未见证据，两者不能互相替代。

这个结果只到 L0：研究模型成立。它不证明真实读者看懂、记住、复述、应用或回来重读；“文章蛮不错”、阅读完成、点赞和分享也不是这类证据。Deep Read 或 Source Dive 的 `explain`、Survey 的 `Canonical Article` 以及任何承诺自包含解释的成稿，会交给一个只看到最终文件的独立新上下文，检查能否恢复承重模型、处理新例、指出边界和发现前提缺口；这只到 L1 Article Recoverability。真人即时无提示复述属于 L2，延迟记忆、复用或实际回访属于 L3。

Deep Read 和 Source Dive 在 Comprehension Gate 后用 Learning Spine 控制成文；Survey 在 Outline 后用用户选中的 Spine Contract 控制 Fill。Reader Contract、Learning Spine、Digest Notes、Spine Contract、四个理解探针、视觉证据台账和 L1 审计答案都只存在于本次运行的工作记忆；报告只记录状态，不暴露内部结构。

## 公开发布意图

用户明确准备把研究成果发布到公众号、X 长文或其他公共场景时，weave 会在 Reader Contract 后运行一个轻量的 Publication Reader Extension。它只问五件事：公开读者是谁、问题在什么情境中反复出现、读者缺少哪种认知能力、热点或版本过去后还剩下什么判断，以及这些信息具体改变了哪项研究决定。

最后一项是准入门。如果公开读者判断不能改变来源搜索、研究范围、证据选择或候选框要求，它会在工作记忆中记为 no-op；标题、开头、节奏、平台包装和分享理由交给 Weave Editorial。普通研究请求不会自动启用这一步。

公开发布意图不会改变证据权重。weave 不会为了传播压低来源标准、隐藏反证或放大结论，也不会强迫时效性文章制造常青判断。Publication Reader Extension 不进入文章、frontmatter、pre-reveal、交付报告或独立 brief；跨 session 的 Editorial 仍从成稿和当前发布请求重新判断。

## 对我意味着什么

weave 会先识别本次运行真正暴露的能力，再获取与当前问题有关的背景。Codex、Claude Code 或其他宿主的名称只用于说明环境；是否能读取当前对话、项目上下文或持久记忆，以本次运行实际提供的能力为准。

背景会被归一化成一个带来源的内部 Context Envelope。当前请求优先于旧记忆，项目规则不会被当成个人信念，记忆里的命令也不会改变研究流程。weave 不扫描无关聊天记录或任意个人目录，不保存用户画像。

选中框通过预留证据测试以后，Impact Pass 才开始工作。它最多保留三个能回溯到证据、会改变具体判断并说明失效边界的影响点。没有可靠个人背景时，文章写“对当前问题意味着什么”；没有真实增量时，诚实报告 `delta ≈ 0`，不会为了完整感补一份建议清单。

## 安装

推荐使用 [skills CLI](https://github.com/vercel-labs/skills)。它会发现仓库根部的 `SKILL.md`，并把 weave 安装到用户级 skills 目录。命令需要 Node.js 和 npm。

跟随 `main` 获取最新版本：

```bash
npx skills add KKenny0/weave --skill weave -g -y
```

需要可复现的稳定版本时，固定到 `v1.1.0`：

```bash
git clone --branch v1.1.0 --depth 1 https://github.com/KKenny0/weave.git
npx skills@1.5.17 add ./weave --skill weave -g -y
```

`main` 安装会随仓库继续演进；稳定安装由 Git 标签锁定 skill 内容和安装器版本。

如果要明确指定宿主：

```bash
# Codex
npx skills add KKenny0/weave --skill weave -g -a codex -y

# Claude Code
npx skills add KKenny0/weave --skill weave -g -a claude-code -y

# 同时安装到多个宿主
npx skills add KKenny0/weave --skill weave -g -a codex -a claude-code -y
```

更新已安装的 weave：

```bash
npx skills update weave -g -y
```

如果宿主没有 `npx skills`，也可以手动克隆到它能扫描的 skills 目录，确保 `SKILL.md` 位于 weave 目录根部。

Claude Code：

```bash
git clone https://github.com/KKenny0/weave.git ~/.claude/skills/weave
```

Codex：

```bash
git clone https://github.com/KKenny0/weave.git ~/.codex/skills/weave
```

其他支持 Agent Skills 结构的宿主，只需把仓库放到它能扫描的 skills 目录。

如果你从 Loom 迁移，请先看 [MIGRATION.md](MIGRATION.md)。现有 `.loom/config.yaml` 路径暂时保持兼容，不需要改写已有 vault。

## 用法

深读论文或访谈：

```text
帮我深度阅读这篇论文：<URL>
我关心它的证据真正支持了什么，哪些结论还不能推广。
```

研究技术项目：

```text
帮我 source dive 这个项目：<GitHub URL>
我想知道一次请求怎么流过核心模块，状态在哪里改变，失败怎么恢复。
```

研究领域并选择脊柱：

```text
用 Survey 的 Deep Research 模式研究 agent memory systems。
完成 Digest 和 Outline 后，给我 2–3 个真正不同的脊柱方向再继续。
```

一次完成一篇 canonical article：

```text
用 Survey 的 Canonical Article 模式研究强化学习，让非专业背景的人也能读懂。
脊柱按证据最强的推荐项继续；图只在文字不擅长表达关系时使用。
```

当“研究 X”既可能指一篇素材，也可能指技术实现或整个领域时，weave 会请求选择路线，不会静默猜测。

## 输出

默认输出一个 Markdown 文件：

```text
{topic}-{workflow}_{YYYY-MM-DD}.md
```

文件头包含 `title`、`date`、`tags`、`sources` 和 `status`。最终文章只保留成文，不混入 Capability Manifest、Context Envelope、Reader Contract、Learning Spine、Digest Notes、Spine Contract、视觉证据台账、Source Brief、Source Catalog、旧 Domain Use Contract、旧 Domain Payoff、Dialogue Matrix、Candidate Frame Brief、Comprehension Gate 探针、Article Recoverability 答案、Impact Brief、System Design Brief、Engineering Decision Brief、Article Closure Contract、阅读意图或范围字段和内部评分表。Deep Read 和 Source Dive 的交付报告记录 reader outcome；Survey 改为记录 mode、选中 spine、Visual Pass 数量和 Human Self-review 状态。

输出路径的优先级：用户指定目录；`.loom/config.yaml` 配置的知识库长文目录；当前工作目录。

## 能力要求

- 用户只给主题时，宿主需要提供网页搜索。
- URL 研究需要可用的网页抓取工具，付费墙、JavaScript 重页面和部分中文平台可能降低覆盖度。
- Background Agent 是并行加速项，缺少时会改为主线程串行阅读。
- Source Dive 需要读取仓库结构和源码。可安全运行现有测试或只读命令时，会用运行结果校验静态推断。
- 宿主提供当前对话、项目上下文或持久记忆时，weave 会按能力和相关性预算自动使用；缺少这些能力时会退化到当前请求，不影响研究流程。

## 仓库结构

```text
weave/
├── SKILL.md
├── MIGRATION.md
├── scripts/
│   ├── check.ps1
│   ├── check-article.ps1
│   └── check-run.ps1
├── references/
│   ├── article-integrity.md
│   ├── collect.md
│   ├── context-acquisition.md
│   ├── deep-read.md
│   ├── impact-pass.md
│   ├── learning-design.md
│   ├── reader-model.md
│   ├── reading-variants.md
│   ├── source-dive.md
│   ├── survey.md
│   ├── frame-selection.md
│   ├── voice-pass.md
│   └── output-spec.md
└── evals/
    ├── anthropic-course-baseline.md
    ├── anthropic-course-benchmark.md
    ├── anthropic-course-saturated.md
    ├── evals.json
    ├── frame-quality.md
    └── smoke.md
```

`evals/evals.json` 包含 26 个回归场景，除原有的素材、项目、领域和 Impact 路径外，还覆盖错误初始问题的修复、闭卷重建、新例预测、反例收缩、不强迫迁移的工程作品阅读、DeepChat 全系统理解、研究模型与真实读者证据的分层、Survey Learn 主干、Spine Direction Gate、跨阶段 Visual 协议、分类完整性，以及公开读者准入、时效边界、Editorial no-op 和反传播诱导。`evals/anthropic-course-baseline.md` 与 `evals/anthropic-course-saturated.md` 保存可复算的基线和饱和成稿，`evals/anthropic-course-benchmark.md` 定义 Anthropic API 公开课程结构与学习目标的原子评分、迭代、跨阶段视觉审计和停止证据；`evals/frame-quality.md` 定义候选框和 Survey spine 的准入、预留测试、成稿恢复性与成文追溯。
`evals/smoke.md` 提供安装后逐路线、Survey 两轮选择与一次性委托、跨宿主能力发现和背景冲突处理的人工回归协议。

维护者可以使用 PowerShell 7 从仓库根目录运行统一验证入口：

```powershell
pwsh -File scripts/check.ps1
```

它会检查 skill frontmatter、eval 数据、文档引用、机器路径泄漏、Git 空白错误和 skills CLI 发现，并在临时 HOME 中完成隔离安装与打包内容比对。离线时可加 `-SkipInstall`，但这不会验证实际安装面。

需要审计一次真实 weave 输出时，使用运行产物验证入口：

```powershell
pwsh -File scripts/check-run.ps1 -RunDirectory <output-dir> -ImpactMode personal
```

`ImpactMode` 可取 `personal`、`question` 或 `none`。它会机械检查文章 frontmatter、字面意义层标题、pre-reveal 文件及其隐私边界、Comprehension Gate、Article Integrity、Article Recoverability 和 hold-out 时间顺序状态。Deep Read 与 Source Dive 报告 reader outcome；Survey 必须报告 mode、可核对的 Visual Pass 数量和 Human Self-review 状态。三条路线都会对实际写入的 Markdown 执行 Article Integrity，并拒绝 Reader Contract、Learning Spine、Digest Note、Spine Contract、内部阅读意图、System Design Brief、Engineering Decision Brief 或 closure contract 字段泄露。

## 边界

- 当前交付语言是中文，目标产物是研究长文，不是即时查询或单篇摘要。
- 无法抓取承重来源时，weave 会报告失败或请求补充，不会用通用知识补写。
- 候选框的生成仍然受模型能力和证据质量影响，因此预留测试和失败边界是流程的一部分。
- 不同宿主暴露的背景能力可能不同；显式请求始终优先，缺少背景时只回答“对当前问题意味着什么”。
- weave 不持久化或同步用户画像，Context Envelope 和 Impact Brief 只存在于单次运行的内部工作区。
- Survey 交付时区分 agent preflight 与 Human Self-review；用户确认内容就绪也不等于授权提交、发布或分发。
