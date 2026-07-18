#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$RunDirectory,

    [Parameter(Mandatory)]
    [ValidateSet('personal', 'question', 'none')]
    [string]$ImpactMode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$articleCheckPath = Join-Path $PSScriptRoot 'check-article.ps1'
$maxArticleBytes = 512KB

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

try {
    $runRoot = [System.IO.Path]::GetFullPath($RunDirectory)
    Assert-True (Test-Path -LiteralPath $runRoot -PathType Container) "Run directory does not exist: $runRoot"

    $reportPath = Join-Path $runRoot 'smoke-report.md'
    $framePath = Join-Path $runRoot '.weave-frame/pre-reveal.md'
    Assert-True (Test-Path -LiteralPath $reportPath -PathType Leaf) 'Missing smoke-report.md.'
    Assert-True (Test-Path -LiteralPath $framePath -PathType Leaf) 'Missing .weave-frame/pre-reveal.md.'

    $articles = @(Get-ChildItem -LiteralPath $runRoot -File -Filter '*.md' | Where-Object Name -ne 'smoke-report.md')
    Assert-True ($articles.Count -eq 1) "Expected exactly one top-level article, found $($articles.Count)."
    Assert-True (Test-Path -LiteralPath $articleCheckPath -PathType Leaf) 'Missing scripts/check-article.ps1.'
    Assert-True ($articles[0].Length -le $maxArticleBytes) 'Article exceeds the 512 KiB run-verification limit.'

    $articleText = Get-Content -LiteralPath $articles[0].FullName -Raw
    $reportText = Get-Content -LiteralPath $reportPath -Raw
    $frameText = Get-Content -LiteralPath $framePath -Raw

    $frontmatter = [regex]::Match($articleText, '\A---\r?\n(?<body>.*?)\r?\n---\r?\n', 'Singleline')
    Assert-True $frontmatter.Success 'Article is missing YAML frontmatter.'
    foreach ($field in @('title', 'date', 'tags', 'sources', 'status')) {
        Assert-True ($frontmatter.Groups['body'].Value -match "(?m)^${field}:") "Article frontmatter is missing ${field}."
    }

    $frontmatterBody = $frontmatter.Groups['body'].Value
    $tagsSection = [regex]::Match($frontmatterBody, '(?ms)^tags:\s*(?<inline>\[[^\]\r\n]*\]|[^\r\n]*)\r?\n(?<items>(?:[ \t]+-\s+[^\r\n]+\r?\n?)*)')
    $hasInlineDeepReadTag = $tagsSection.Success -and $tagsSection.Groups['inline'].Value -match '(?i)\bdeep-read\b'
    $hasBlockDeepReadTag = $tagsSection.Success -and $tagsSection.Groups['items'].Value -match '(?im)^\s*-\s*deep-read\s*$'
    $isDeepRead = $articles[0].Name -match '-deep-read_' -or $hasInlineDeepReadTag -or $hasBlockDeepReadTag
    $hasInlineSourceDiveTag = $tagsSection.Success -and $tagsSection.Groups['inline'].Value -match '(?i)\bsource-dive\b'
    $hasBlockSourceDiveTag = $tagsSection.Success -and $tagsSection.Groups['items'].Value -match '(?im)^\s*-\s*source-dive\s*$'
    $isSourceDive = $articles[0].Name -match '-source-dive_' -or $hasInlineSourceDiveTag -or $hasBlockSourceDiveTag
    $requiresArticleIntegrity = $isDeepRead -or $isSourceDive
    if ($requiresArticleIntegrity) {
        $pwsh = (Get-Command pwsh -ErrorAction Stop).Source
        $articleCheckOutput = @(& $pwsh -NoProfile -File $articleCheckPath -ArticlePath $articles[0].FullName 2>&1)
        Assert-True ($LASTEXITCODE -eq 0) "Article integrity checker failed: $($articleCheckOutput -join ' ')"
    }

    $personalHeading = ([regex]::Matches($articleText, '(?m)^## 对我意味着什么\s*$')).Count
    $questionHeading = ([regex]::Matches($articleText, '(?m)^## 对当前问题意味着什么\s*$')).Count
    switch ($ImpactMode) {
        'personal' {
            Assert-True ($personalHeading -eq 1 -and $questionHeading -eq 0) 'Personal mode requires exactly one literal 对我意味着什么 heading.'
        }
        'question' {
            Assert-True ($questionHeading -eq 1 -and $personalHeading -eq 0) 'Question mode requires exactly one literal 对当前问题意味着什么 heading.'
        }
        'none' {
            Assert-True ($personalHeading -eq 0 -and $questionHeading -eq 0) 'Opt-out mode must contain neither impact heading.'
        }
    }

    $framePrivacy = "(?i)\buser(?:'s)?\b|user context|current request|personal (?:context|baseline|preference|decision|goal|constraint)|用户|当前请求|个人(?:背景|基线|偏好|决定|决策|目标|约束)|我正在|我目前|我偏向|我的(?:团队|项目|目标|约束)|团队现有"
    Assert-True ($frameText -notmatch $framePrivacy) 'Pre-reveal artifact contains personal or contextual rationale.'

    $readerArtifactFields = '(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:Initial question|Starting model|Unsettled judgment|Target capability|Revision trigger|Route expression|Problem World|Reasoning Machine|World After|Shared ground|Term mismatch|Premise conflict|Unresolved question|Reconstruction|Novel case|Counterexample|Question repair|初始问题|起始模型|未决判断|目标能力|修正触发条件|路线表达|问题世界|推理机器|接受后的世界|共同地基|术语错位|前提冲突|未决问题|重建|新例|反例|问题修复)(?:\*\*)?\s*:'
    Assert-True ($frameText -notmatch $readerArtifactFields) 'Pre-reveal artifact contains Reader Contract, Dialogue Matrix, or Comprehension Gate fields.'

    $frameFiles = @(Get-ChildItem -LiteralPath (Split-Path -Parent $framePath) -File)
    Assert-True ($frameFiles.Count -eq 1 -and $frameFiles[0].Name -eq 'pre-reveal.md') 'The .weave-frame directory may persist only pre-reveal.md.'

    $forbiddenHeadings = '(?im)^#{1,6}\s+(Capability Manifest|Context Envelope|Reader Contract|Source Brief|Source Catalog|Dialogue Matrix|Candidate Frame Brief|Synthesis Pack|Comprehension Gate|Impact Brief|System Design Brief|Engineering Decision Brief|Article Closure Contract)(?:\s*:.*)?\s*$'
    Assert-True ($reportText -notmatch $forbiddenHeadings) 'Delivery report contains a forbidden internal-artifact heading.'

    $reportPrivacy = "(?i)user's (?:decision|preference|goal|constraint|baseline)|the user (?:is deciding|prefers|wants|needs)|用户.{0,16}(?:正在|决定|决策|偏向|偏好|目标|约束|限制)|我正在|我目前|我偏向|我需要|我的(?:团队|项目|目标|约束)|调试成本必须|不能牺牲|隐私边界必须"
    Assert-True ($reportText -notmatch $reportPrivacy) 'Delivery report repeats personal context.'
    Assert-True ($reportText -notmatch $readerArtifactFields) 'Delivery report contains Reader Contract, Dialogue Matrix, or Comprehension Gate field dumps.'
    $sourceDiveInternalFieldNames = 'Primary reading intent|Secondary reading intent|Reading intent|Primary reading scope|Secondary reading scope|Reading scope|Observed problem|Design forces|Executable mechanism|Evidence status|Core project problem|Decision chains|Attribution boundary|Version boundary|Product identity|Target user or actor|User capabilities|System boundary|Entry points|Core state|Major subsystems|Canonical task loop|Organizing principle|主要阅读意图|次要阅读意图|阅读意图|主要阅读范围|次要阅读范围|阅读范围|观察到的问题|设计力量|可执行机制|证据状态|核心项目问题|承重判断链|归属边界|版本边界|产品身份|目标用户或行动者|用户能力|系统边界|入口|核心状态|主要子系统|代表性任务循环|组织原则'
    $sourceDiveArtifactFields = "(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:$sourceDiveInternalFieldNames)(?:\*\*)?\s*:"
    $sourceDiveArtifactTableFields = "(?im)^\s*\|\s*(?:\*\*)?(?:$sourceDiveInternalFieldNames)(?:\*\*)?\s*\|"
    Assert-True ($frameText -notmatch $sourceDiveArtifactFields -and $frameText -notmatch $sourceDiveArtifactTableFields) 'Pre-reveal artifact contains source-dive internal fields.'
    Assert-True ($reportText -notmatch $sourceDiveArtifactFields -and $reportText -notmatch $sourceDiveArtifactTableFields) 'Delivery report contains source-dive internal fields.'
    Assert-True ($reportText -notmatch '(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:Impact\s*[1-3]|影响\s*[一二三123])\b') 'Delivery report lists individual admitted impacts.'
    Assert-True ($reportText -notmatch '(?m)^\s*```') 'Delivery report must not contain fenced code blocks that can hide verification fields.'

    $comprehensionPassCount = ([regex]::Matches($reportText, '(?im)^(?:Comprehension Gate:\s*passed|理解门:\s*通过|理解检验:\s*通过)\s*$')).Count
    Assert-True ($comprehensionPassCount -eq 1) 'Delivery report requires exactly one anchored Comprehension Gate pass status.'
    Assert-True ($reportText -notmatch '(?im)^(?:Comprehension Gate|理解门|理解检验):.*(?:fail|failed|unverified|失败|未验证)') 'Delivery report contains a failed or unverified Comprehension Gate status.'

    $requiredPatterns = @(
        '(?i)host|宿主',
        '(?i)context (?:source )?categor|背景来源类别|上下文来源类别',
        '(?i)admitted impact|impact count|影响.{0,8}(?:数量|计数)',
        '(?i)voice pass',
        '(?i)chronology|时间顺序',
        '(?i)\.weave-frame[/\\]pre-reveal\.md'
    )
    if ($requiresArticleIntegrity) {
        $requiredPatterns += '(?i)article integrity|成稿完整性'
        $articleIntegrityPassCount = ([regex]::Matches($reportText, '(?im)^(?:Article Integrity:\s*passed|成稿完整性:\s*通过)\s*$')).Count
        Assert-True ($articleIntegrityPassCount -eq 1) 'Deep-read and source-dive delivery reports require exactly one anchored Article Integrity pass status.'
        Assert-True ($reportText -notmatch '(?im)^(?:Article Integrity|成稿完整性):.*(?:fail|failed|manual|unverified|失败|手工|未验证)') 'Delivery report contains a failed, manual, or unverified Article Integrity status.'
    }
    foreach ($requiredPattern in $requiredPatterns) {
        Assert-True ($reportText -match $requiredPattern) "Delivery report is missing required summary pattern: $requiredPattern"
    }
    Assert-True ($reportText -notmatch '(?i)chronology.{0,24}unverified|时间顺序.{0,24}未验证') 'Audit run reports unverified chronology.'

    Write-Host "Run verification passed: $($articles[0].Name) [$ImpactMode]" -ForegroundColor Green
}
catch {
    Write-Error "Run verification failed: $($_.Exception.Message)"
    exit 1
}
