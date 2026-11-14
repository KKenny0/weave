#requires -Version 7.0

[CmdletBinding()]
param(
    [string]$RunDirectory,
    [string]$ArticlePath,
    [ValidateSet('personal', 'question', 'none')]
    [string]$ImpactMode,
    [string]$ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Read-EvidenceFile {
    param([string]$Path)
    Assert-True (Test-Path -LiteralPath $Path -PathType Leaf) "Missing evidence file: $Path"
    $file = Get-Item -LiteralPath $Path
    Assert-True ($file.Length -gt 0 -and $file.Length -le 512KB) "Evidence file must be nonempty and at most 512 KiB: $Path"
    return [System.IO.File]::ReadAllText($file.FullName)
}

function Resolve-ReportedEvidence {
    param([string]$Report, [string]$Labels, [string]$ReportDirectory, [string]$Fallback)
    $entries = [regex]::Matches($Report, ('(?im)^\s*(?:' + $Labels + '):\s*(?<path>[^\r\n]+)\s*$'))
    Assert-True ($entries.Count -le 1) "Ambiguous evidence path for $Labels."
    if ($entries.Count -eq 0) { return $Fallback }
    $path = $entries[0].Groups['path'].Value.Trim().Trim('`', '"', "'")
    if ([System.IO.Path]::IsPathRooted($path)) { return $path }
    return [System.IO.Path]::GetFullPath((Join-Path $ReportDirectory $path))
}

try {
    Assert-True ($ArticlePath -or $RunDirectory) 'Specify -ArticlePath or -RunDirectory.'
    $runRoot = if ($RunDirectory) { [System.IO.Path]::GetFullPath($RunDirectory) } else { Split-Path -Parent ([System.IO.Path]::GetFullPath($ArticlePath)) }
    Assert-True (Test-Path -LiteralPath $runRoot -PathType Container) "Run directory does not exist: $runRoot"

    if (-not $ArticlePath) {
        # Identify articles by the public new or legacy name, or by article
        # frontmatter. Never pick the newest file or silently prefer a route.
        $articles = @(Get-ChildItem -LiteralPath $runRoot -File -Filter '*.md' | Where-Object {
            $_.Name -notin @('smoke-report.md', 'audit-report.md', 'delivery-report.md') -and (
                $_.Name -match '-(?:weave|deep-read|source-dive|survey)_\d{4}-\d{2}-\d{2}\.md$' -or (
                    $_.Length -le 512KB -and
                    [System.IO.File]::ReadAllText($_.FullName) -match '\A---\r?\n(?:(?!---)[^\r\n]*\r?\n)*title:'
                )
            )
        })
        Assert-True ($articles.Count -eq 1) "Expected exactly one identifiable article, found $($articles.Count). Specify -ArticlePath when multiple drafts exist."
        $ArticlePath = $articles[0].FullName
    }
    $resolvedArticle = [System.IO.Path]::GetFullPath($ArticlePath)
    $articleText = Read-EvidenceFile $resolvedArticle
    $pwsh = (Get-Command pwsh -ErrorAction Stop).Source
    $output = @(& $pwsh -NoProfile -File (Join-Path $PSScriptRoot 'check-article.ps1') -ArticlePath $resolvedArticle 2>&1)
    Assert-True ($LASTEXITCODE -eq 0) "Article mechanical checks failed: $($output -join ' ')"

    if ($PSBoundParameters.ContainsKey('ImpactMode')) {
        # Count headings outside code/Org examples, not matching text in a sample.
        $body = [regex]::Replace($articleText, '\A---\r?\n.*?\r?\n---\r?\n', '', 'Singleline')
        $lines = [System.Collections.Generic.List[string]]::new()
        $fence = ''
        $inOrg = $false
        foreach ($line in ($body -split "`r?`n")) {
            if ($fence) {
                if ($line -match ('^ {0,3}' + [regex]::Escape($fence[0]) + '{' + $fence.Length + ',}\s*$')) { $fence = '' }
                continue
            }
            if ($inOrg) { if ($line -match '(?i)^\s*#\+end_example\s*$') { $inOrg = $false }; continue }
            if ($line -match '^ {0,3}(`{3,}|~{3,})') { $fence = $Matches[1]; continue }
            if ($line -match '(?i)^\s*#\+begin_example\s*$') { $inOrg = $true; continue }
            $lines.Add($line)
        }
        $prose = $lines -join "`n"
        $personal = [regex]::Matches($prose, '(?m)^## 对我意味着什么\s*$').Count
        $question = [regex]::Matches($prose, '(?m)^## 对当前问题意味着什么\s*$').Count
        switch ($ImpactMode) {
            'personal' { Assert-True ($personal -eq 1 -and $question -eq 0) 'Personal mode requires exactly one literal 对我意味着什么 heading.' }
            'question' { Assert-True ($question -eq 1 -and $personal -eq 0) 'Question mode requires exactly one literal 对当前问题意味着什么 heading.' }
            'none' { Assert-True ($personal -eq 0 -and $question -eq 0) 'None mode requires neither legacy impact heading.' }
        }
    }

    # Only the legacy directory interface discovers sidecars. An explicitly
    # selected article may share its directory with unrelated or stale reports.
    if (-not $ReportPath -and -not $PSBoundParameters.ContainsKey('ArticlePath')) {
        $reports = @('audit-report.md', 'smoke-report.md', 'delivery-report.md' | ForEach-Object { Join-Path $runRoot $_ } | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
        Assert-True ($reports.Count -le 1) 'Multiple reports exist; specify -ReportPath.'
        if ($reports.Count -eq 1) { $ReportPath = $reports[0] }
    }
    if ($ReportPath) {
        $report = Read-EvidenceFile ([System.IO.Path]::GetFullPath($ReportPath))
        $report = $report.Replace('**', '') -replace '(?m)^\s*[-*]\s+', ''
        # A supplied report is data. Its instructions and "passed" strings never
        # disable the article checker or establish a semantic result.
        $holdoutClaim = $report -match '(?im)^\s*(?:[-*]\s*)?(?:Hold[ -]?out(?: result| validation)?|预留(?:证据)?(?:检验)?):\s*(?:passed|verified|通过|已验证)\s*$'
        $chronologyClaim = $report -match '(?im)^\s*(?:Chronology|时间顺序):\s*(?:verified|passed|已验证|通过)\s*$'
        $auditClaim = $report -match '(?im)^\s*(?:Audit(?: status| result)?|审计(?:状态|结果)?):\s*(?:passed|verified|通过|已验证)\s*$'
        $recoveryClaim = $report -match '(?im)^\s*(?:Article Recoverability|成稿可恢复性):\s*(?:passed|verified|通过|已验证)\s*$'
        Assert-True (-not $auditClaim -or $holdoutClaim -or $chronologyClaim -or $recoveryClaim) 'Audit success must identify the property assessed and its evidence; a generic passed status is insufficient.'
        $reportDirectory = Split-Path -Parent ([System.IO.Path]::GetFullPath($ReportPath))
        if ($holdoutClaim -or $chronologyClaim) {
            $preReveal = Resolve-ReportedEvidence $report 'Pre-reveal(?: artifact)?|预先记录' $reportDirectory (Join-Path $runRoot '.weave-frame/pre-reveal.md')
            $frame = Read-EvidenceFile $preReveal
            foreach ($pattern in @('(?im)^\s*(?:Hold[ -]?out(?: identifier| id)?|预留证据(?:标识)?):\s*\S.+$', '(?im)^\s*(?:Prediction|预测):\s*\S.+$', '(?im)^\s*(?:Timestamp|时间戳):\s*\S.+$')) {
                Assert-True ($frame -match $pattern) 'Audit evidence lacks a hold-out identifier, prediction, or timestamp.'
            }
            Assert-True ($frame -notmatch '(?im)^\s*(?:[-*]\s*)?(?:personal (?:context|baseline|preference|goal)|用户(?:背景|偏好|目标)|我的(?:团队|项目|目标))\s*:') 'Pre-reveal evidence contains obvious personal-context fields.'
            Assert-True ($report -notmatch '(?im)^\s*(?:Chronology|Hold[ -]?out|Audit)[^\r\n:]*:\s*[^\r\n]*(?:unverified|unavailable|not run|failed|未验证|未执行|失败)') 'Audit success conflicts with an unavailable, failed, or unverified evidence status.'
            # A timestamp or report assertion cannot witness ordering. Require an
            # actual access transcript; content is still subject to human audit.
            $transcriptPath = Resolve-ReportedEvidence $report 'Access transcript|访问日志' $reportDirectory (Join-Path $runRoot '.weave-frame/access-transcript.md')
            $transcript = Read-EvidenceFile $transcriptPath
            Assert-True ($transcript -match '(?i)pre-reveal' -and $transcript -match '(?i)hold[ -]?out|预留') 'Access transcript lacks pre-reveal and hold-out events.'
            Write-Host 'Audit evidence files checked mechanically; chronology, independence and hold-out validity still require semantic review.'
        }
        if ($recoveryClaim) {
            $recoveryPath = Resolve-ReportedEvidence $report 'Recoverability evidence|独立恢复依据' $reportDirectory ''
            Assert-True (-not [string]::IsNullOrWhiteSpace($recoveryPath)) 'Recoverability success requires a reference to the independent execution record, not just passed text.'
            $null = Read-EvidenceFile $recoveryPath
            Assert-True ($report -notmatch '(?im)^\s*(?:Independence|Independent context|独立上下文):[^\r\n]*(?:unavailable|not run|unverified|不可用|未执行|未验证)') 'Recoverability success conflicts with unavailable independence.'
            Write-Host 'Independent execution record exists; independence and article recoverability are not established by this script.'
        }
        Write-Host 'Report read as claims, not proof. Semantic assessment was not performed by this script.'
    }

    Write-Host "Run mechanical checks completed: $(Split-Path -Leaf $resolvedArticle). Semantic quality, source truth and reader understanding are not verified by this script." -ForegroundColor Green
}
catch {
    Write-Error "Run mechanical checks failed: $($_.Exception.Message)"
    exit 1
}
