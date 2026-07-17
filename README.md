<p align="center">
  <img src="assets/weave-mark.svg" alt="weave logo" width="96" />
</p>

<h1 align="center">weave</h1>

<p align="center"><strong>证据先行，取景框决定文章。</strong></p>

<p align="center">简体中文 · <a href="README.en.md">English</a></p>

weave 是一个面向深度研究的 Agent Skill。给它一组文章、一篇论文、一个技术项目，或者一个领域名称，它会产出一篇有证据、有判断、可以独立阅读的中文长文。

它不会直接把素材压成摘要。运行开始时，它会检查当前 Agent 实际能访问哪些任务背景；接着建立证据模型，从素材里找出几种真正成立的看法，测试它们的边界，最后选一副框来组织全文。选框以后，它再判断这副框是否改变了你的认知、决策或学习路径。

```text
宿主能力 → Context Envelope C
                    ↓
素材 x + 用户问题 q
        ↓
收集来源，建立证据 E
        ↓
生成路线特定的候选框
        ↓
证据、专属性、选择力、边界、差异性检查
        ↓
用预留证据测试选中框
        ↓
Impact Pass：C + E + 选中框
        ↓
章节映射 → 成文 → Voice Pass
```

## 三条研究路线

| 输入 | Workflow | 主要产物 |
|---|---|---|
| 论文、文章、访谈、报告、书章 | `deep-read` | 对素材的证据化深读 |
| GitHub 仓库、框架、技术项目 | `source-dive` | 围绕实际行为路径的源码分析 |
| 领域名称、研究方向 | `survey` | 围绕实际用途收束判断的领域地图 |

### Deep Read

Deep Read 会根据素材的推理形状，选择论证叙事、学术论文提取、概念解剖或纵向深挖。访谈会保留说话人之间的差异，学术论文会把测量结果、作者解释和可推广边界分开。

### Source Dive

Source Dive 不按目录或文件大小写源码清单。它会追踪触发、入口、路由、状态变化、扩展边界、输出与失败恢复，并分开已经运行验证的结论和静态推断。

### Survey

Survey 会先判断这张地图要解决什么：建立方向感、做选择、安排进入顺序，还是评估一个主张。内部的 Map Use Contract 会据此明确比较对象、收益问题和可能改变结论的条件，再决定搜索角度与证据门槛。

它不预设每个领域都有研究纲领或范式革命，而是在方法族、瓶颈与价值流、争议轴、研究纲领、时间演化之间选择主体结构。候选框不能只重新排列标题，还要在明确条件下改变一个区分、选择、进入顺序或判断置信度。选中框通过预留证据测试以后，Map Payoff 才会收束出条件、代价、失败方式和下一项验证证据。建立领域地图的请求不会被强行改写成产品选型；需要做选择时，也不会得到脱离条件的通用答案。

## 候选框怎么过关

一副候选框需要同时满足五个条件：承重部件能回溯到证据；不能原样套到相邻主题；会改变材料取舍或章节结构；清楚说明失效条件；与其他候选产生真实的解释差异。

候选数量没有硬指标。只有一副通过就用一副，一副都没通过就回到证据阶段。weave 不会为了制造选择而保留同义改写或陪跑框。

选中以后，weave 会用一部分预先留出的材料测试它。测试可以是通过、部分通过或失败。如果宿主没有访问日志，weave 会保留预测内容，同时把读取顺序标成未验证，不会把一个自写时间戳当成审计证明。

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

测绘领域：

```text
帮我做 survey：agent memory systems。
我想看主要方法、真正的争论、现在的瓶颈和适合的入门路径。
```

当“研究 X”既可能指一篇素材，也可能指技术实现或整个领域时，weave 会请求选择路线，不会静默猜测。

## 输出

默认输出一个 Markdown 文件：

```text
{topic}-{workflow}_{YYYY-MM-DD}.md
```

文件头包含 `title`、`date`、`tags`、`sources` 和 `status`。最终文章只保留成文，不混入 Capability Manifest、Context Envelope、Source Brief、Source Catalog、Candidate Frame Brief、Impact Brief、Article Closure Contract 或内部评分表。交付报告会说明选中框、胜出理由、有实质差异的备选框、预留测试结果、检测到的宿主、实际使用的背景来源类别，以及 Impact Pass 的结果；deep-read 还会记录最终文件的 Article Integrity 结果。

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
│   ├── reading-variants.md
│   ├── source-dive.md
│   ├── survey.md
│   ├── frame-selection.md
│   ├── voice-pass.md
│   └── output-spec.md
└── evals/
    ├── evals.json
    ├── frame-quality.md
    └── smoke.md
```

`evals/evals.json` 包含 10 个回归场景，覆盖单素材、多素材、访谈、主题自动搜集、技术项目、领域地图、学术论文、显式决策背景、问题级降级和 Impact opt-out。`evals/frame-quality.md` 定义候选框准入、预留测试与成文追溯的评估方法。
`evals/smoke.md` 提供安装后逐路线、Survey orient/choose 双路径、跨宿主能力发现和背景冲突处理的人工回归协议。

维护者可以使用 PowerShell 7 从仓库根目录运行统一验证入口：

```powershell
pwsh -File scripts/check.ps1
```

它会检查 skill frontmatter、eval 数据、文档引用、机器路径泄漏、Git 空白错误和 skills CLI 发现，并在临时 HOME 中完成隔离安装与打包内容比对。离线时可加 `-SkipInstall`，但这不会验证实际安装面。

需要审计一次真实 weave 输出时，使用运行产物验证入口：

```powershell
pwsh -File scripts/check-run.ps1 -RunDirectory <output-dir> -ImpactMode personal
```

`ImpactMode` 可取 `personal`、`question` 或 `none`。它会机械检查文章 frontmatter、字面意义层标题、pre-reveal 文件及其隐私边界、交付报告字段和 hold-out 时间顺序状态；对于 deep-read，还会对实际写入的 Markdown 执行 Article Integrity 检查。非零退出码表示本次运行不能声明通过。

## 边界

- 当前交付语言是中文，目标产物是研究长文，不是即时查询或单篇摘要。
- 无法抓取承重来源时，weave 会报告失败或请求补充，不会用通用知识补写。
- 候选框的生成仍然受模型能力和证据质量影响，因此预留测试和失败边界是流程的一部分。
- 不同宿主暴露的背景能力可能不同；显式请求始终优先，缺少背景时只回答“对当前问题意味着什么”。
- weave 不持久化或同步用户画像，Context Envelope 和 Impact Brief 只存在于单次运行的内部工作区。
- weave 在交付文章后停止。它不会自动提交、发布或分发成品。
