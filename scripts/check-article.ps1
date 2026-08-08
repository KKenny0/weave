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

function Get-YamlTagTokens {
    param([string]$FrontmatterText)

    $section = [regex]::Match($FrontmatterText, '(?ms)^tags:[ \t]*(?<inline>\[[^\]\r\n]*\]|[^\r\n]*)\r?\n(?<items>(?:[ \t]+-\s+[^\r\n]+\r?\n?)*)')
    if (-not $section.Success) { return @() }

    $rawValues = [System.Collections.Generic.List[string]]::new()
    $inline = $section.Groups['inline'].Value.Trim()
    if ($inline.StartsWith('[') -and $inline.EndsWith(']')) {
        foreach ($value in $inline.Substring(1, $inline.Length - 2).Split(',')) { $rawValues.Add($value) }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($inline)) {
        $rawValues.Add($inline)
    }
    foreach ($match in [regex]::Matches($section.Groups['items'].Value, '(?m)^\s*-\s*(?<value>[^\r\n]+?)\s*$')) {
        $rawValues.Add($match.Groups['value'].Value)
    }

    return @($rawValues | ForEach-Object {
        ([regex]::Replace($_, '\s+#.*$', '')).Trim().Trim('"', "'").ToLowerInvariant()
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-ProseText {
    param([string]$Text)

    $lines = $Text -split "`r?`n"
    $result = [System.Collections.Generic.List[string]]::new()
    $inFence = $false
    $inOrgExample = $false
    $fenceMarker = $null
    $fenceLength = 0

    foreach ($line in $lines) {
        if (-not $inFence -and $line -match '(?i)^\s*#\+begin_example\s*$') {
            $inOrgExample = $true
            $result.Add('')
            continue
        }
        if (-not $inFence -and $line -match '(?i)^\s*#\+end_example\s*$') {
            $inOrgExample = $false
            $result.Add('')
            continue
        }
        if ($inOrgExample) {
            $result.Add('')
            continue
        }

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

function Get-DisplayColumnWidth {
    param([string]$Line)

    $width = 0
    foreach ($character in $Line.ToCharArray()) {
        if ($character -eq "`t") {
            $width += 8 - ($width % 8)
        }
        elseif ([int]$character -le 0x7f) {
            $width += 1
        }
        else {
            # Org example blocks should prefer ASCII. Count non-ASCII conservatively
            # as two display columns so CJK alignment cannot pass a byte-blind check.
            $width += 2
        }
    }
    return $width
}

function Get-OrgExampleFailures {
    param(
        [string]$Text,
        [bool]$EnforceSurveyAscii
    )

    $result = [System.Collections.Generic.List[string]]::new()
    $lines = $Text -split "`r?`n"
    $inOrgExample = $false
    $orgStartLine = 0
    $inMarkdownFence = $false
    $fenceMarker = $null
    $fenceLength = 0
    $fenceLanguage = ''
    $fenceStartLine = 0
    $fenceLooksLikeAscii = $false
    $previousContentLine = ''
    $pendingVisualMarkerLine = 0
    $inMarkedMarkdownTable = $false
    $visualMarkerPattern = '^\s*<!--\s*weave-visual\s*-->\s*$'
    $asciiVisualPattern = '(?:[-=]{1,3}>|<[-=]{1,3}|<[-=]{1,3}>|\+-{2,}\+|\|\s*[/\\_^~*.-]{2,}\s*\||^\s*[/\\_]{3,}\s*$|^\s*(?:[A-Za-z][\w -]*\s+)?\|\s*.*[/\\_*].*$)'

    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        $lineNumber = $index + 1

        if ($inMarkdownFence) {
            $closingPattern = '^\s{0,3}' + [regex]::Escape($fenceMarker) + '{' + $fenceLength + ',}\s*$'
            if ($line -match $closingPattern) {
                if ($EnforceSurveyAscii -and $fenceLooksLikeAscii -and $fenceLanguage -in @('', 'text', 'txt', 'ascii', 'plaintext', 'org', 'diagram')) {
                    $result.Add("Survey ASCII visual at line $fenceStartLine uses a Markdown fence; use a paired Org example block.")
                }
                $inMarkdownFence = $false
                $fenceMarker = $null
                $fenceLength = 0
                $fenceLanguage = ''
                $fenceStartLine = 0
                $fenceLooksLikeAscii = $false
            }
            elseif ($line -match $asciiVisualPattern) {
                $fenceLooksLikeAscii = $true
            }
            continue
        }

        if ($EnforceSurveyAscii -and $line -match $visualMarkerPattern) {
            if ($pendingVisualMarkerLine -gt 0) {
                $result.Add("Survey visual marker at line $pendingVisualMarkerLine is not attached to a visual.")
            }
            $pendingVisualMarkerLine = $lineNumber
            $previousContentLine = $line
            continue
        }

        if ($EnforceSurveyAscii -and $pendingVisualMarkerLine -gt 0 -and -not [string]::IsNullOrWhiteSpace($line)) {
            $isVisualStart = $line -match '(?i)^\s*#\+begin_example\s*$' -or
                $line -match '^\s{0,3}`{3,}\s*mermaid(?:\s|$)' -or
                $line -match '^\s{0,3}~{3,}\s*mermaid(?:\s|$)' -or
                $line -match '^\s*!\[' -or
                $line -match '(?i)^\s*<figure(?:\s|>)' -or
                $line -match '^\s*\|' -or
                $line -match '^\s*(?:\$\$|\\\[)'
            if (-not $isVisualStart) {
                $result.Add("Survey visual marker at line $pendingVisualMarkerLine is not immediately followed by a supported visual.")
            }
            elseif ($line -match '^\s*\|') {
                $inMarkedMarkdownTable = $true
            }
            $pendingVisualMarkerLine = 0
        }

        if ($inMarkedMarkdownTable -and $line -notmatch '^\s*\|') {
            $inMarkedMarkdownTable = $false
        }

        if (-not $inOrgExample) {
            $fence = [regex]::Match($line, '^\s{0,3}(?<marker>`{3,}|~{3,})(?<info>.*)$')
            if ($fence.Success) {
                $markerText = $fence.Groups['marker'].Value
                $inMarkdownFence = $true
                $fenceMarker = $markerText.Substring(0, 1)
                $fenceLength = $markerText.Length
                $fenceInfo = $fence.Groups['info'].Value
                $pandocLanguage = [regex]::Match($fenceInfo, '^\s*\{\.(?<language>[^}\s]+)')
                $fenceLanguage = if ($pandocLanguage.Success) {
                    $pandocLanguage.Groups['language'].Value.ToLowerInvariant()
                }
                else {
                    [regex]::Match($fenceInfo, '^\s*(?<language>\S*)').Groups['language'].Value.ToLowerInvariant()
                }
                $fenceStartLine = $lineNumber
                if ($EnforceSurveyAscii -and $fenceLanguage -eq 'mermaid' -and $previousContentLine -notmatch $visualMarkerPattern) {
                    $result.Add("Survey Mermaid visual at line $lineNumber is missing its immediately preceding visual marker.")
                }
                $previousContentLine = $line
                continue
            }
        }

        if ($line -match '(?i)^\s*#\+begin_example\s*$') {
            if ($EnforceSurveyAscii -and -not $inOrgExample -and $previousContentLine -notmatch $visualMarkerPattern) {
                $result.Add("Survey Org example visual at line $lineNumber is missing its immediately preceding visual marker.")
            }
            if ($inOrgExample) {
                $result.Add("Nested Org example block begins at line $lineNumber.")
            }
            else {
                $inOrgExample = $true
                $orgStartLine = $lineNumber
            }
            $previousContentLine = $line
            continue
        }

        if ($line -match '(?i)^\s*#\+end_example\s*$') {
            if (-not $inOrgExample) {
                $result.Add("Orphan Org example block terminator at line $lineNumber.")
            }
            else {
                $inOrgExample = $false
                $orgStartLine = 0
            }
            $previousContentLine = $line
            continue
        }

        if ($line -match '(?i)^\s*#\+(?:begin|end)_example\b') {
            $result.Add("Invalid Org example delimiter at line $lineNumber; use the exact delimiter alone on its line.")
            $previousContentLine = $line
            continue
        }

        if ($inOrgExample) {
            $displayWidth = Get-DisplayColumnWidth $line
            if ($displayWidth -gt 80) {
                $result.Add("Org example content at line $lineNumber is $displayWidth columns; maximum is 80.")
            }
            continue
        }

        if ($EnforceSurveyAscii -and -not $inMarkedMarkdownTable) {
            $unmaskedLine = [regex]::Replace($line, '`[^`\r\n]*`', '')
            $looksLikePythonTypeSignature = $unmaskedLine -match '^\s*(?:async\s+)?def\s+[A-Za-z_]\w*\s*\([^)]*\)\s*->\s*[^:]+:\s*$'
            if (-not $looksLikePythonTypeSignature -and $unmaskedLine -match $asciiVisualPattern) {
                $result.Add("Survey ASCII visual at line $lineNumber is outside a paired Org example block.")
            }
        }
        if ($EnforceSurveyAscii -and $line -match '^\s*!\[' -and $previousContentLine -notmatch $visualMarkerPattern) {
            $result.Add("Survey image visual at line $lineNumber is missing its immediately preceding visual marker.")
        }
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $previousContentLine = $line
        }
    }

    if ($inOrgExample) {
        $result.Add("Org example block opened at line $orgStartLine is not closed.")
    }
    if ($pendingVisualMarkerLine -gt 0) {
        $result.Add("Survey visual marker at line $pendingVisualMarkerLine is not attached to a visual.")
    }

    return @($result)
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
        $tagTokens = @(Get-YamlTagTokens $frontmatterText)
        $isSourceDive = $isSourceDive -or ($tagTokens -contains 'source-dive')
        $isSurvey = $isSurvey -or ($tagTokens -contains 'survey')
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
    if ($isSurvey) {
        foreach ($orgFailure in @(Get-OrgExampleFailures -Text $bodyText -EnforceSurveyAscii $true)) {
            Add-Failure $failures $orgFailure
        }
    }
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
