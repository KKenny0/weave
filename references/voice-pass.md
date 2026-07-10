# Voice Pass

Runs after Compose phase, before final file write. Mandatory, not optional — AI patterns are invisible to the writer-agent.

## Step 1: De-AI scan (universal)

Scan the full article against the 10 AI-pattern checklist. Anything that fails goes back for revision. Re-scan after edits.

1. **段末收尾总结句** ("到这里" / "这说明" / "这本身就是" / "可以看出" 开头的短抽象句，段落最后一句比其他句短且抽象) → 删
2. **升华句** (把具体观察上升到普适人生道理) → 改成具体建议
3. **对比句式** ("不是…而是…", "X 本身没有价值，真正有用的是 Y") → 直接说结论，不用对比框架铺垫
4. **bold 小标题模式** (`**xxx**。` 独立成句) → 改为 bold 承重词 (`**xxx**，content`)，让 bold 变成修饰不是独立小标题。例外：bold 部分本身是完整句子时保留句号
5. **章节引介过渡句** (章节开头或结尾写 "上面这些模式解决的是…，下面再看…") → 删，章节标题本身已经承接
6. **空泛形容词预判** ("更干净：" / "逻辑很清晰：" 形容词抢先下判断) → 删形容词，只留后面的事实
7. **工整并列 bold 标题** (四个 bold 标题全是同一格式) → 每个点语气不同，或改成散文叙述
8. **段内重复** (同一段把同一意思用不同措辞说两遍) → 说一遍
9. **讲解腔起手** ("真拆开看" / "这背后是同一个变化" / "真正关键的问题是") → 删，直接说
10. **训人感起手** ("先问问是不是" / "你要先明白") → 改"可以先看" / "先确认"

### 句式规则

- 禁止破折号 (—)，用逗号或分号代替。破折号是最强的 AI 写作指纹
- 4-5 个句号连发、每句很短 = 打电报 → 合成长句或用逗号连
- 单独成段的一两句话，多半是上一段的收尾 → 并进去
- 不用 "首先…其次…最后"，用自然的 "先 / 然后 / 最后"

### 用词去正式化

| 不用 | 用 |
|------|-----|
| 非常 / 极其 | 很 |
| 综上所述 | 直接收尾 |
| 例如 | 比如 |
| 值得注意的是 | 直接说结论 |
| 不可否认 / 毫无疑问 / 由此可见 / 众所周知 | 直接删 |

任何一条不过，回去改。改完重新过。

## Step 2: Apply user-style (scan user's recent weave outputs)

Pattern from `/write` SKILL.md:134-141 — scan existing artifacts for style reference, no persistent profile, no trigger word.

Find user's recent weave outputs in priority order:

1. `*-workspace/iteration-*/with_skill/outputs/*.md` across all weave workspaces (most recent first by mtime)
2. User's current working directory, recent `.md` files by mtime
3. If nothing found → skip this step, use only Step 1 universal rules

Take **1-2 most recent** as style reference. Extract:

- **句长偏好**: 短句为主 / 长句为主 / 混合
- **段落结构偏好**: 小标题密度、列表 vs 散文
- **用词偏好**: 用户常用实词 vs 用户从不用的 AI 套话
- **章节组织**: 5-step 论证 / 学案体 / 自由叙事
- **具体词级偏好**: e.g. "用户偏好'明显'不用'显著'"、"用户不用'首先'"

**Output budget**: at most 5 word-level + 3 structure-level observations. Skip this step entirely if you find fewer than 3 strong patterns — empty style scan is better than generic advice like "写得更自然".

Apply observations as voice constraints for this output. Constraints must be specific (word-level or structure-level), not vague ("写得更自然").

Reference is reference, not template. Topic differs → structure may differ, but word and sentence preferences inherit.

## Step 3: Write final file

After Voice Pass, write the `.md` file. Naming / path / YAML frontmatter rules: see `output-spec.md`.

After write, use Read tool to verify the file saved correctly.

## Step 4: Delivery report

Tell user:

- Article path
- Word count (approximate)
- Chapter count
- Selected frame and why it won
- Close alternative only when it would have produced a materially different article
- Hold-out result: pass / partial / miss, with the final boundary when relevant
- Voice Pass execution: how many AI patterns caught and fixed
- Which style reference was used (path + how many preferences extracted). If no reference found, say so.

**Done ≠ Published**: Delivering a publishable draft is the boundary. Do NOT push, post, distribute, commit unless user explicitly asks.
