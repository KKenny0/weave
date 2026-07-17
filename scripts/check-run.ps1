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
    if ($isDeepRead) {
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

    $frameFiles = @(Get-ChildItem -LiteralPath (Split-Path -Parent $framePath) -File)
    Assert-True ($frameFiles.Count -eq 1 -and $frameFiles[0].Name -eq 'pre-reveal.md') 'The .weave-frame directory may persist only pre-reveal.md.'

    $forbiddenHeadings = '(?im)^#{1,3}\s+(Capability Manifest|Context Envelope|Source Brief|Source Catalog|Candidate Frame Brief|Synthesis Pack|Impact Brief|Article Closure Contract)\s*$'
    Assert-True ($reportText -notmatch $forbiddenHeadings) 'Delivery report contains a forbidden internal-artifact heading.'

    $reportPrivacy = "(?i)user's (?:decision|preference|goal|constraint|baseline)|the user (?:is deciding|prefers|wants|needs)|用户.{0,16}(?:正在|决定|决策|偏向|偏好|目标|约束|限制)|我正在|我目前|我偏向|我需要|我的(?:团队|项目|目标|约束)|调试成本必须|不能牺牲|隐私边界必须"
    Assert-True ($reportText -notmatch $reportPrivacy) 'Delivery report repeats personal context.'
    Assert-True ($reportText -notmatch '(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:Impact\s*[1-3]|影响\s*[一二三123])\b') 'Delivery report lists individual admitted impacts.'

    $requiredPatterns = @(
        '(?i)host|宿主',
        '(?i)context (?:source )?categor|背景来源类别|上下文来源类别',
        '(?i)admitted impact|impact count|影响.{0,8}(?:数量|计数)',
        '(?i)voice pass',
        '(?i)chronology|时间顺序',
        '(?i)\.weave-frame[/\\]pre-reveal\.md'
    )
    if ($isDeepRead) {
        $requiredPatterns += '(?i)article integrity|成稿完整性'
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
