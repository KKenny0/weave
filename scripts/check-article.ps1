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

function Get-OrgExampleFailures {
    param([string]$Text)

    $failures = [System.Collections.Generic.List[string]]::new()
    $inOrg = $false
    $fence = ''
    foreach ($line in ($Text -split "`r?`n")) {
        if ($fence) {
            if ($line -match ('^ {0,3}' + [regex]::Escape($fence[0]) + '{' + $fence.Length + ',}\s*$')) { $fence = '' }
            continue
        }
        if (-not $inOrg -and $line -match '^ {0,3}(`{3,}|~{3,})') { $fence = $Matches[1]; continue }
        if ($line -match '(?i)^\s*#\+begin_example\s*$') {
            if ($inOrg) { $failures.Add('Nested Org example block.') }
            $inOrg = $true
        }
        elseif ($line -match '(?i)^\s*#\+end_example\s*$') {
            if (-not $inOrg) { $failures.Add('Orphan Org example terminator.') }
            $inOrg = $false
        }
        elseif ($line -match '(?i)^\s*#\+(?:begin|end)_example\b') {
            $failures.Add('Malformed Org example delimiter.')
        }
    }
    if ($inOrg) { $failures.Add('Unclosed Org example block.') }
    return @($failures)
}

function Test-YamlValue {
    param([string]$Value)

    $valueText = $Value.Trim()
    if (-not $valueText -or $valueText -in @('null', '~', '[]', '{}') -or $valueText -match '^(["''])\s*\1(?:\s+#.*)?$') { return $false }
    if ($valueText.StartsWith('"')) { return $valueText -match '^"(?:[^"\\]|\\.)*"(?:\s+#.*)?$' }
    if ($valueText.StartsWith("'")) { return $valueText -match "^'(?:[^']|'')*'(?:\s+#.*)?$" }
    # Frontmatter uses scalars and flat sequences, not YAML objects, anchors or tags.
    return $valueText -notmatch '^[\[\]{}&*!|>@`]|:\s|[\[\]{}]'
}

function Get-YamlSequenceItems {
    param([string]$Value)
    $items = [System.Collections.Generic.List[string]]::new()
    $start = 1
    $quote = [char]0
    for ($index = 1; $index -lt $Value.Length - 1; $index++) {
        $character = $Value[$index]
        if ($quote -ne [char]0) {
            if ($quote -eq [char]34 -and $character -eq [char]92) { $index++; continue }
            if ($character -eq $quote) {
                if ($quote -eq [char]39 -and $index + 1 -lt $Value.Length - 1 -and $Value[$index + 1] -eq $quote) { $index++ }
                else { $quote = [char]0 }
            }
        }
        elseif ($character -eq [char]34 -or $character -eq [char]39) { $quote = $character }
        elseif ($character -eq ',') { $items.Add($Value.Substring($start, $index - $start).Trim()); $start = $index + 1 }
    }
    $items.Add($Value.Substring($start, $Value.Length - 1 - $start).Trim())
    return @($items)
}

function Get-FrontmatterFailures {
    param([string]$Text)

    $failures = [System.Collections.Generic.List[string]]::new()
    $fields = @{}
    $sequences = @{}
    $listIndents = @{}
    $activeField = ''
    foreach ($line in ($Text -split "`r?`n")) {
        if ($line -match '^\s*(?:#.*)?$') { continue }
        if ($line -match '^(?<key>[A-Za-z_][\w-]*):[ \t]*(?<value>.*)$') {
            $activeField = $Matches.key
            if ($fields.ContainsKey($activeField)) { $failures.Add("Duplicate YAML field: $activeField") }
            $fields[$activeField] = $Matches.value.Trim()
            $value = $fields[$activeField]
            if ($activeField -in @('tags', 'sources') -and $value.StartsWith('[') -and $value.EndsWith(']')) {
                $items = @(Get-YamlSequenceItems $value)
                $sequences[$activeField] = $items
                if (@($items | Where-Object { -not (Test-YamlValue $_) }).Count) { $failures.Add("Malformed or empty YAML sequence: $activeField") }
            }
            elseif ($activeField -in @('tags', 'sources') -and $value) { $failures.Add("YAML $activeField must be a nonempty sequence.") }
            elseif ($value -and -not (Test-YamlValue $value)) { $failures.Add("Malformed YAML value: $activeField") }
        }
        elseif ($line -match '^(?<indent> *)-[ \t]+(?<value>.+)$' -and $activeField -in @('tags', 'sources')) {
            $indent = $Matches.indent.Length
            if ($listIndents.ContainsKey($activeField) -and $listIndents[$activeField] -ne $indent) { $failures.Add("Inconsistent YAML list indentation: $activeField") }
            $listIndents[$activeField] = $indent
            if (-not (Test-YamlValue $Matches.value)) { $failures.Add("Malformed YAML list item: $activeField") }
            if ($fields[$activeField] -and $fields[$activeField] -ne '__list__') { $failures.Add("Mixed inline and block YAML list: $activeField") }
            $fields[$activeField] = '__list__'
            if (-not $sequences.ContainsKey($activeField)) { $sequences[$activeField] = @() }
            $sequences[$activeField] = @($sequences[$activeField]) + @($Matches.value)
        }
        else { $failures.Add("Unsupported or malformed frontmatter line: $line") }
    }
    foreach ($field in @('title', 'date', 'tags', 'sources', 'status')) {
        if (-not $fields.ContainsKey($field) -or -not $fields[$field]) { $failures.Add("Missing or empty YAML field: $field") }
    }
    if ($sequences.ContainsKey('sources')) {
        $sources = @($sequences.sources | ForEach-Object { $_.Trim().Trim('"', "'") })
        if (@($sources | Sort-Object -Unique).Count -ne $sources.Count) { $failures.Add('Frontmatter sources contain duplicate entries.') }
    }
    if ($fields.ContainsKey('date')) {
        $dateValue = [datetime]::MinValue
        if (-not [datetime]::TryParseExact($fields.date.Trim('"', "'"), 'yyyy-MM-dd', [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$dateValue)) {
            $failures.Add('Frontmatter date must be a real YYYY-MM-DD date.')
        }
    }
    return @($failures)
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

    if ($articleFile.Length -eq 0) { throw 'Article file is empty.' }

    $text = Get-Content -LiteralPath $resolvedPath -Raw -Encoding utf8
    $failures = [System.Collections.Generic.List[string]]::new()
    $frontmatter = [regex]::Match($text, '\A---\r?\n(?<body>.*?)\r?\n---\r?\n', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $bodyText = if ($frontmatter.Success) { $text.Substring($frontmatter.Length) } else { $text }
    $proseResult = Get-ProseText $bodyText
    if (-not $frontmatter.Success) {
        Add-Failure $failures 'Missing valid YAML frontmatter.'
    }
    else {
        $frontmatterText = $frontmatter.Groups['body'].Value
        foreach ($failure in @(Get-FrontmatterFailures $frontmatterText)) { Add-Failure $failures $failure }
        if ($frontmatterText -match '(?im)^(?:capability_manifest|context_envelope|reader_contract|source_brief|source_catalog|candidate_frame_brief|synthesis_pack|impact_brief|comprehension_gate|reader_outcome|prerequisite_floor|transfer_case|explanation_boundary|learning_spine|digest_note|spine_contract|visual_evidence_ledger|domain_use_contract|domain_payoff|article_recoverability_audit):') {
            Add-Failure $failures 'Frontmatter contains a forbidden reader, Survey spine, or learning-design artifact field.'
        }
        if ($frontmatterText -match '(?im)^(?:reading_intent|primary_intent|secondary_intent|reading_scope|primary_scope|secondary_scope|system_design_brief|engineering_decision_brief|article_closure_contract):') {
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

    }

    $prose = $proseResult.Text
    foreach ($orgFailure in @(Get-OrgExampleFailures -Text $bodyText)) { Add-Failure $failures $orgFailure }
    if ([string]::IsNullOrWhiteSpace(($prose -replace '(?m)^# .+$', ''))) { Add-Failure $failures 'Article has no prose body.' }
    if (-not $proseResult.FenceClosed) {
        Add-Failure $failures 'Markdown contains an unclosed fenced code block.'
    }

    foreach ($pattern in @('。，', '，。', '。。', '，，', '；。', '：。')) {
        if ($prose.Contains($pattern, [System.StringComparison]::Ordinal)) {
            Add-Failure $failures "Malformed punctuation sequence found: $pattern"
        }
    }
    if ($prose -match '(?m)^>(?![ >]|\r?$)') {
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
    $readerArtifactFields = '(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:Initial question|Starting model|Unsettled judgment|Reader outcome|Prerequisite floor|Target capability|Transfer case|Explanation boundary|Revision trigger|Route expression|Central model|Dependency order|Worked examples|Misconception repairs|Chapter deltas|Final transfer|Digest Note|Spine Contract|Through-object|Section-source map|Visual Evidence Ledger|Domain Use Contract|Domain Payoff|Primary reader outcome|Reasoning object|Payoff question|Condition set|Problem World|Reasoning Machine|World After|Shared ground|Term mismatch|Premise conflict|Unresolved question|初始问题|起始模型|未决判断|读者结果|前提下限|目标能力|迁移案例|解释边界|修正触发条件|路线表达|中央模型|依赖顺序|承重示例|误解修复|章节增量|最终迁移|消化笔记|脊柱契约|贯穿对象|章节来源映射|视觉证据台账|领域用途契约|领域收益|主要读者结果|推理对象|收益问题|条件集合|问题世界|推理机器|接受后的世界|共同地基|术语错位|前提冲突|未决问题)(?:\*\*)?\s*:'
    $readerArtifactTableFields = '(?im)^\s*\|\s*(?:\*\*)?(?:Reader outcome|Prerequisite floor|Target capability|Transfer case|Explanation boundary|Central model|Dependency order|Worked examples|Misconception repairs|Chapter deltas|Final transfer|Digest Note|Spine Contract|Through-object|Section-source map|Visual Evidence Ledger|Primary reader outcome|Reasoning object|Payoff question|Condition set|读者结果|前提下限|目标能力|迁移案例|解释边界|中央模型|依赖顺序|承重示例|误解修复|章节增量|最终迁移|消化笔记|脊柱契约|贯穿对象|章节来源映射|视觉证据台账|主要读者结果|推理对象|收益问题|条件集合)(?:\*\*)?\s*\|'
    $readerFieldCount = [regex]::Matches($prose, $readerArtifactFields).Count + [regex]::Matches($prose, $readerArtifactTableFields).Count
    $explicitArtifactField = '(?im)^\s*(?:[-*]\s*|\|\s*)?(?:\*\*)?(?:Reader outcome|Route expression|Digest Note|Spine Contract|Visual Evidence Ledger|Domain Use Contract|Domain Payoff|读者结果|路线表达|消化笔记|脊柱契约|视觉证据台账|领域用途契约|领域收益)(?:\*\*)?\s*[:|]'
    if ($readerFieldCount -ge 3 -or $prose -match $explicitArtifactField) {
        Add-Failure $failures 'Article contains Reader Contract, Learning Spine, Survey spine, Domain Use, Dialogue Matrix, or Comprehension Gate field dumps.'
    }
    $sourceDiveInternalFieldNames = 'Primary reading intent|Secondary reading intent|Reading intent|Primary reading scope|Secondary reading scope|Reading scope|Observed problem|Design forces|Executable mechanism|Evidence status|Core project problem|Decision chains|Attribution boundary|Version boundary|Product identity|Target user or actor|User capabilities|System boundary|Entry points|Core state|Major subsystems|Canonical task loop|Organizing principle|主要阅读意图|次要阅读意图|阅读意图|主要阅读范围|次要阅读范围|阅读范围|观察到的问题|设计力量|可执行机制|证据状态|核心项目问题|承重判断链|归属边界|版本边界|产品身份|目标用户或行动者|用户能力|系统边界|入口|核心状态|主要子系统|代表性任务循环|组织原则'
    $sourceDiveArtifactFields = "(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:$sourceDiveInternalFieldNames)(?:\*\*)?\s*:"
    $sourceDiveArtifactTableFields = "(?im)^\s*\|\s*(?:\*\*)?(?:$sourceDiveInternalFieldNames)(?:\*\*)?\s*\|"
    if ([regex]::Matches($prose, $sourceDiveArtifactFields).Count + [regex]::Matches($prose, $sourceDiveArtifactTableFields).Count -ge 3 -or $prose -match '(?im)^\s*(?:[-*]\s*)?(?:Primary reading intent|Reading scope|主要阅读意图|阅读范围):') {
        Add-Failure $failures 'Article contains source-dive intent, scope, design-brief, decision-brief, or closure-contract field dumps.'
    }

    if ($failures.Count -gt 0) {
        throw ($failures -join [Environment]::NewLine)
    }

    Write-Host "Article mechanical checks completed: $(Split-Path -Leaf $resolvedPath). Semantic quality and source truth are not verified by this script." -ForegroundColor Green
}
catch {
    Write-Error "Article integrity failed: $($_.Exception.Message)"
    exit 1
}
