#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ArticlePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$maxArticleBytes = 512KB

function Add-Failure {
    param(
        [System.Collections.Generic.List[string]]$Failures,
        [string]$Message
    )
    $Failures.Add($Message)
}

function Get-ProseText {
    param([string]$Text)

    $lines = $Text -split "`r?`n"
    $result = [System.Collections.Generic.List[string]]::new()
    $inFence = $false
    $fenceMarker = $null
    $fenceLength = 0

    foreach ($line in $lines) {
        if (-not $inFence) {
            $fence = [regex]::Match($line, '^\s{0,3}(?<marker>`{3,}|~{3,})')
            if ($fence.Success) {
                $markerText = $fence.Groups['marker'].Value
                $inFence = $true
                $fenceMarker = $markerText.Substring(0, 1)
                $fenceLength = $markerText.Length
                $result.Add('')
                continue
            }
        }
        else {
            $closingPattern = '^\s{0,3}' + [regex]::Escape($fenceMarker) + '{' + $fenceLength + ',}\s*$'
            if ($line -match $closingPattern) {
                $inFence = $false
                $fenceMarker = $null
                $fenceLength = 0
            }
            $result.Add('')
            continue
        }

        if ($inFence) {
            $result.Add('')
        }
        else {
            $result.Add($line)
        }
    }

    return [pscustomobject]@{
        Text = $result -join "`n"
        FenceClosed = -not $inFence
    }
}

function Find-RepeatedFragment {
    param(
        [string]$Text,
        [int]$Window = 24
    )

    $paragraphs = [regex]::Split($Text, '(?:\r?\n){2,}')
    $firstLocations = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)
    for ($paragraphIndex = 0; $paragraphIndex -lt $paragraphs.Count; $paragraphIndex++) {
        $paragraph = $paragraphs[$paragraphIndex]
        $plain = $paragraph
        $plain = [regex]::Replace($plain, '\]\([^)]+\)', ']')
        $plain = [regex]::Replace($plain, 'https?://\S+', '')
        $plain = [regex]::Replace($plain, '`[^`]*`', '')
        $plain = [regex]::Replace($plain, '(?m)^\s{0,3}(?:#{1,6}|[-*+] |\d+\. )', '')
        $plain = [regex]::Replace($plain, '\s+', '')

        if ($plain.Length -lt $Window) {
            continue
        }

        for ($index = 0; $index -le $plain.Length - $Window; $index++) {
            $fragment = $plain.Substring($index, $Window)
            if ($fragment -notmatch '[\p{L}\p{IsCJKUnifiedIdeographs}]') {
                continue
            }
            if ($firstLocations.ContainsKey($fragment)) {
                $firstLocation = $firstLocations[$fragment]
                if ($paragraphIndex -ne $firstLocation.Paragraph -or ($index - $firstLocation.Index) -ge $Window) {
                    return $fragment
                }
            }
            else {
                $firstLocations.Add($fragment, [pscustomobject]@{ Paragraph = $paragraphIndex; Index = $index })
            }
        }
    }

    return $null
}

try {
    $resolvedPath = [System.IO.Path]::GetFullPath($ArticlePath)
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Article does not exist: $resolvedPath"
    }
    if ([System.IO.Path]::GetExtension($resolvedPath) -ne '.md') {
        throw "Article must be a Markdown file: $resolvedPath"
    }
    $articleFile = Get-Item -LiteralPath $resolvedPath
    if ($articleFile.Length -gt $maxArticleBytes) {
        throw "Article exceeds the 512 KiB integrity-check limit: $resolvedPath"
    }

    $text = Get-Content -LiteralPath $resolvedPath -Raw -Encoding utf8
    $failures = [System.Collections.Generic.List[string]]::new()
    $isSourceDive = [System.IO.Path]::GetFileName($resolvedPath) -match '-source-dive_'
    $isSurvey = [System.IO.Path]::GetFileName($resolvedPath) -match '-survey_'
    $frontmatter = [regex]::Match($text, '\A---\r?\n(?<body>.*?)\r?\n---\r?\n', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $bodyText = if ($frontmatter.Success) { $text.Substring($frontmatter.Length) } else { $text }
    $proseResult = Get-ProseText $bodyText
    if (-not $frontmatter.Success) {
        Add-Failure $failures 'Missing valid YAML frontmatter.'
    }
    else {
        $frontmatterText = $frontmatter.Groups['body'].Value
        $tagsSection = [regex]::Match($frontmatterText, '(?ms)^tags:\s*(?<inline>\[[^\]\r\n]*\]|[^\r\n]*)\r?\n(?<items>(?:[ \t]+-\s+[^\r\n]+\r?\n?)*)')
        $isSourceDive = $isSourceDive -or
            ($tagsSection.Success -and $tagsSection.Groups['inline'].Value -match '(?i)\bsource-dive\b') -or
            ($tagsSection.Success -and $tagsSection.Groups['items'].Value -match '(?im)^\s*-\s*source-dive\s*$')
        $isSurvey = $isSurvey -or
            ($tagsSection.Success -and $tagsSection.Groups['inline'].Value -match '(?i)\bsurvey\b') -or
            ($tagsSection.Success -and $tagsSection.Groups['items'].Value -match '(?im)^\s*-\s*survey\s*$')
        foreach ($field in @('title', 'date', 'tags', 'sources', 'status')) {
            if ($frontmatterText -notmatch "(?m)^${field}:") {
                Add-Failure $failures "Frontmatter is missing ${field}."
            }
        }
        if ($isSurvey) {
            foreach ($field in @('topic', 'scope')) {
                if ($frontmatterText -notmatch "(?m)^${field}:") {
                    Add-Failure $failures "Survey frontmatter is missing ${field}."
                }
            }
        }
        if ($frontmatterText -match '(?im)^(?:reader_outcome|prerequisite_floor|transfer_case|explanation_boundary|learning_spine|digest_note|spine_contract|visual_evidence_ledger|domain_use_contract|domain_payoff|article_recoverability_audit):') {
            Add-Failure $failures 'Frontmatter contains a forbidden reader, Survey spine, or learning-design artifact field.'
        }
        if ($isSourceDive -and $frontmatterText -match '(?im)^(?:reading_intent|primary_intent|secondary_intent|reading_scope|primary_scope|secondary_scope|system_design_brief|engineering_decision_brief|article_closure_contract):') {
            Add-Failure $failures 'Source-dive frontmatter contains a forbidden internal-artifact field.'
        }

        $titleMatch = [regex]::Match($frontmatterText, '(?m)^title:\s*(?<title>.+?)\s*$')
        $h1Matches = [regex]::Matches($proseResult.Text, '(?m)^#\s+(?<title>.+?)\s*$')
        if (-not $titleMatch.Success) {
            Add-Failure $failures 'Frontmatter title is empty.'
        }
        elseif ($h1Matches.Count -ne 1) {
            Add-Failure $failures "Expected exactly one H1 title, found $($h1Matches.Count)."
        }
        else {
            $yamlTitle = $titleMatch.Groups['title'].Value.Trim().Trim('"', "'")
            $h1Title = $h1Matches[0].Groups['title'].Value.Trim()
            if ($yamlTitle -cne $h1Title) {
                Add-Failure $failures 'Frontmatter title and H1 title do not match exactly.'
            }
        }

        $sourcesMatch = [regex]::Match($frontmatterText, '(?ms)^sources:\s*\r?\n(?<items>(?:\s{2,}-\s+.*(?:\r?\n|$))+)')
        if (-not $sourcesMatch.Success) {
            Add-Failure $failures 'Frontmatter sources must contain at least one list item.'
        }
        else {
            $sources = @([regex]::Matches($sourcesMatch.Groups['items'].Value, '(?m)^\s{2,}-\s+(?<source>.+?)\s*$') | ForEach-Object { $_.Groups['source'].Value.Trim().Trim('"', "'") })
            $uniqueSources = @($sources | Sort-Object -Unique)
            if ($uniqueSources.Count -ne $sources.Count) {
                Add-Failure $failures 'Frontmatter sources contain duplicate entries.'
            }
            foreach ($source in $sources) {
                if ($source -match '^https://x\.com/(?!i/article/)[^/]+/article/\d+(?:[/?#]|$)') {
                    Add-Failure $failures "X article source uses a non-canonical author/article path: $source"
                }
            }
        }
    }

    $prose = $proseResult.Text
    if (-not $proseResult.FenceClosed) {
        Add-Failure $failures 'Markdown contains an unclosed fenced code block.'
    }

    foreach ($pattern in @('。，', '，。', '。。', '，，', '；。', '：。')) {
        if ($prose.Contains($pattern, [System.StringComparison]::Ordinal)) {
            Add-Failure $failures "Malformed punctuation sequence found: $pattern"
        }
    }
    if ($prose -match '(?m)^>(?![ >])') {
        Add-Failure $failures 'Blockquote marker must be followed by a space.'
    }
    if ($prose -match '(?m)[。！？；：，]>\s*$') {
        Add-Failure $failures 'Line ends with a dangling blockquote marker.'
    }

    $repetitionScanText = [regex]::Replace(
        $prose,
        '(?ims)^#{1,6}\s+(?:进一步阅读|延伸阅读|参考(?:来源|文献)|Further Reading|References?|Bibliography)\s*$.*\z',
        ''
    )
    $repeated = Find-RepeatedFragment $repetitionScanText
    if ($null -ne $repeated) {
        Add-Failure $failures "Repeated long fragment found: $repeated"
    }

    $forbiddenHeadings = '(?im)^#{1,6}\s+(Capability Manifest|Context Envelope|Reader Contract|Learning Spine|Digest Note|Spine Contract|Visual Evidence Ledger|Source Brief|Source Catalog|Domain Use Contract|Domain Payoff|Dialogue Matrix|Candidate Frame Brief|Synthesis Pack|Comprehension Gate|Article Recoverability Audit|Impact Brief|System Design Brief|Engineering Decision Brief|Article Closure Contract)(?:\s*:.*)?\s*$'
    if ($prose -match $forbiddenHeadings) {
        Add-Failure $failures 'Article contains a forbidden internal-artifact heading.'
    }
    $readerArtifactFields = '(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:Initial question|Starting model|Unsettled judgment|Reader outcome|Prerequisite floor|Target capability|Transfer case|Explanation boundary|Revision trigger|Route expression|Central model|Dependency order|Worked examples|Misconception repairs|Chapter deltas|Final transfer|Digest Note|Spine Contract|Through-object|Section-source map|Visual Evidence Ledger|Domain Use Contract|Domain Payoff|Primary reader outcome|Reasoning object|Payoff question|Condition set|Problem World|Reasoning Machine|World After|Shared ground|Term mismatch|Premise conflict|Unresolved question|Reconstruction|Novel case|Counterexample|Question repair|初始问题|起始模型|未决判断|读者结果|前提下限|目标能力|迁移案例|解释边界|修正触发条件|路线表达|中央模型|依赖顺序|承重示例|误解修复|章节增量|最终迁移|消化笔记|脊柱契约|贯穿对象|章节来源映射|视觉证据台账|领域用途契约|领域收益|主要读者结果|推理对象|收益问题|条件集合|问题世界|推理机器|接受后的世界|共同地基|术语错位|前提冲突|未决问题|重建|新例|反例|问题修复)(?:\*\*)?\s*:'
    $readerArtifactTableFields = '(?im)^\s*\|\s*(?:\*\*)?(?:Reader outcome|Prerequisite floor|Target capability|Transfer case|Explanation boundary|Central model|Dependency order|Worked examples|Misconception repairs|Chapter deltas|Final transfer|Digest Note|Spine Contract|Through-object|Section-source map|Visual Evidence Ledger|Primary reader outcome|Reasoning object|Payoff question|Condition set|读者结果|前提下限|目标能力|迁移案例|解释边界|中央模型|依赖顺序|承重示例|误解修复|章节增量|最终迁移|消化笔记|脊柱契约|贯穿对象|章节来源映射|视觉证据台账|主要读者结果|推理对象|收益问题|条件集合)(?:\*\*)?\s*\|'
    if ($prose -match $readerArtifactFields -or $prose -match $readerArtifactTableFields) {
        Add-Failure $failures 'Article contains Reader Contract, Learning Spine, Survey spine, Domain Use, Dialogue Matrix, or Comprehension Gate field dumps.'
    }
    $sourceDiveInternalFieldNames = 'Primary reading intent|Secondary reading intent|Reading intent|Primary reading scope|Secondary reading scope|Reading scope|Observed problem|Design forces|Executable mechanism|Evidence status|Core project problem|Decision chains|Attribution boundary|Version boundary|Product identity|Target user or actor|User capabilities|System boundary|Entry points|Core state|Major subsystems|Canonical task loop|Organizing principle|主要阅读意图|次要阅读意图|阅读意图|主要阅读范围|次要阅读范围|阅读范围|观察到的问题|设计力量|可执行机制|证据状态|核心项目问题|承重判断链|归属边界|版本边界|产品身份|目标用户或行动者|用户能力|系统边界|入口|核心状态|主要子系统|代表性任务循环|组织原则'
    $sourceDiveArtifactFields = "(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:$sourceDiveInternalFieldNames)(?:\*\*)?\s*:"
    $sourceDiveArtifactTableFields = "(?im)^\s*\|\s*(?:\*\*)?(?:$sourceDiveInternalFieldNames)(?:\*\*)?\s*\|"
    if ($isSourceDive -and ($prose -match $sourceDiveArtifactFields -or $prose -match $sourceDiveArtifactTableFields)) {
        Add-Failure $failures 'Article contains source-dive intent, scope, design-brief, decision-brief, or closure-contract field dumps.'
    }

    if ($failures.Count -gt 0) {
        throw ($failures -join [Environment]::NewLine)
    }

    Write-Host "Article integrity passed: $(Split-Path -Leaf $resolvedPath)" -ForegroundColor Green
}
catch {
    Write-Error "Article integrity failed: $($_.Exception.Message)"
    exit 1
}
