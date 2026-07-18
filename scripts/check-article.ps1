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
    $frontmatter = [regex]::Match($text, '\A---\r?\n(?<body>.*?)\r?\n---\r?\n', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $bodyText = if ($frontmatter.Success) { $text.Substring($frontmatter.Length) } else { $text }
    $proseResult = Get-ProseText $bodyText
    if (-not $frontmatter.Success) {
        Add-Failure $failures 'Missing valid YAML frontmatter.'
    }
    else {
        $frontmatterText = $frontmatter.Groups['body'].Value
        foreach ($field in @('title', 'date', 'tags', 'sources', 'status')) {
            if ($frontmatterText -notmatch "(?m)^${field}:") {
                Add-Failure $failures "Frontmatter is missing ${field}."
            }
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

    $repeated = Find-RepeatedFragment $prose
    if ($null -ne $repeated) {
        Add-Failure $failures "Repeated long fragment found: $repeated"
    }

    $forbiddenHeadings = '(?im)^#{1,6}\s+(Capability Manifest|Context Envelope|Reader Contract|Source Brief|Source Catalog|Dialogue Matrix|Candidate Frame Brief|Synthesis Pack|Comprehension Gate|Impact Brief|Article Closure Contract)(?:\s*:.*)?\s*$'
    if ($prose -match $forbiddenHeadings) {
        Add-Failure $failures 'Article contains a forbidden internal-artifact heading.'
    }
    $readerArtifactFields = '(?im)^\s*(?:[-*]\s*)?(?:\*\*)?(?:Initial question|Starting model|Unsettled judgment|Target capability|Revision trigger|Route expression|Problem World|Reasoning Machine|World After|Shared ground|Term mismatch|Premise conflict|Unresolved question|Reconstruction|Novel case|Counterexample|Question repair|初始问题|起始模型|未决判断|目标能力|修正触发条件|路线表达|问题世界|推理机器|接受后的世界|共同地基|术语错位|前提冲突|未决问题|重建|新例|反例|问题修复)(?:\*\*)?\s*:'
    if ($prose -match $readerArtifactFields) {
        Add-Failure $failures 'Article contains Reader Contract, Dialogue Matrix, or Comprehension Gate field dumps.'
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
