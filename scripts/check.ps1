#requires -Version 7.0

[CmdletBinding()]
param(
    [switch]$SkipInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skillPath = Join-Path $repoRoot 'SKILL.md'
$evalPath = Join-Path $repoRoot 'evals/evals.json'
$scriptPath = Join-Path $repoRoot 'scripts/check.ps1'
$runCheckPath = Join-Path $repoRoot 'scripts/check-run.ps1'
$articleCheckPath = Join-Path $repoRoot 'scripts/check-article.ps1'
$skillsCliPackage = 'skills@1.5.17'

function Invoke-Check {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [scriptblock]$Action
    )

    Write-Host "[CHECK] $Name"
    & $Action
    Write-Host "[PASS]  $Name"
}

function Invoke-NativeCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $output = @(& $Command @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    foreach ($line in $output) {
        Write-Host "$line"
    }
    if ($exitCode -ne 0) {
        throw "Command failed with exit code ${exitCode}: $Command $($Arguments -join ' ')"
    }
    return $output
}

function Get-ProductMarkdownFiles {
    $files = @(
        (Join-Path $repoRoot 'SKILL.md'),
        (Join-Path $repoRoot 'README.md'),
        (Join-Path $repoRoot 'README.en.md'),
        (Join-Path $repoRoot 'MIGRATION.md')
    )
    $files += @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'references') -Filter '*.md' -File | Select-Object -ExpandProperty FullName)
    $files += @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'evals') -Filter '*.md' -File | Select-Object -ExpandProperty FullName)
    return $files
}

try {
    Invoke-Check 'required files and SKILL frontmatter' {
        $required = @(
            'SKILL.md',
            'README.md',
            'scripts/check.ps1',
            'scripts/check-article.ps1',
            'scripts/check-run.ps1',
            'evals/evals.json',
            'evals/smoke.md',
            'references/collect.md',
            'references/article-integrity.md',
            'references/context-acquisition.md',
            'references/deep-read.md',
            'references/frame-selection.md',
            'references/impact-pass.md',
            'references/output-spec.md',
            'references/reader-model.md',
            'references/reading-variants.md',
            'references/source-dive.md',
            'references/survey.md',
            'references/voice-pass.md'
        )
        foreach ($relativePath in $required) {
            if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath) -PathType Leaf)) {
                throw "Missing required file: $relativePath"
            }
        }

        $skillText = Get-Content -LiteralPath $skillPath -Raw
        $frontmatter = [regex]::Match($skillText, '\A---\r?\n(?<body>.*?)\r?\n---\r?\n', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        if (-not $frontmatter.Success) {
            throw 'SKILL.md has no valid YAML frontmatter block.'
        }
        if ($frontmatter.Groups['body'].Value -notmatch '(?m)^name:\s*weave\s*$') {
            throw 'SKILL.md frontmatter name must remain weave.'
        }
        $description = [regex]::Match($frontmatter.Groups['body'].Value, '(?m)^description:\s*(?<value>.*)$')
        if (-not $description.Success -or [string]::IsNullOrWhiteSpace($description.Groups['value'].Value)) {
            throw 'SKILL.md frontmatter must contain a description.'
        }
    }

    Invoke-Check 'eval JSON shape and unique IDs' {
        $evalRoot = Get-Content -LiteralPath $evalPath -Raw | ConvertFrom-Json -Depth 30
        if ($evalRoot.skill_name -ne 'weave') {
            throw 'evals/evals.json skill_name must be weave.'
        }
        $evals = @($evalRoot.evals)
        if ($evals.Count -eq 0) {
            throw 'evals/evals.json contains no eval cases.'
        }
        $ids = @($evals | ForEach-Object { $_.id })
        if (($ids | Sort-Object -Unique).Count -ne $ids.Count) {
            throw 'evals/evals.json contains duplicate IDs.'
        }
        $names = @($evals | ForEach-Object { $_.name })
        if (($names | Sort-Object -Unique).Count -ne $names.Count) {
            throw 'evals/evals.json contains duplicate names.'
        }
        foreach ($requiredEvalName in @('initial-question-repair', 'generative-comprehension')) {
            if ($requiredEvalName -notin $names) {
                throw "evals/evals.json is missing reader-model regression: $requiredEvalName"
            }
        }
        foreach ($eval in $evals) {
            foreach ($field in @('id', 'name', 'prompt', 'expected_output', 'files', 'expectations')) {
                if ($null -eq $eval.PSObject.Properties[$field]) {
                    throw "Eval $($eval.id) is missing field: $field"
                }
            }
            if ([string]::IsNullOrWhiteSpace([string]$eval.prompt) -or @($eval.expectations).Count -eq 0) {
                throw "Eval $($eval.id) has an empty prompt or expectations list."
            }
        }
        $readerEvalExpectations = @($evals | Where-Object { $_.name -in @('initial-question-repair', 'generative-comprehension') } | ForEach-Object { $_.expectations }) -join "`n"
        foreach ($requiredReaderProbe in @('Reader Contract', 'reconstruction', 'novel-case', 'counterexample', 'Question repair', 'Comprehension Gate')) {
            if ($readerEvalExpectations -notmatch [regex]::Escape($requiredReaderProbe)) {
                throw "Reader-model evals do not cover required probe: $requiredReaderProbe"
            }
        }
        foreach ($routeEvalName in @('source-dive-real-repo', 'survey-real-domain')) {
            $routeEval = $evals | Where-Object { $_.name -eq $routeEvalName } | Select-Object -First 1
            $routeExpectations = @($routeEval.expectations) -join "`n"
            if ($routeExpectations -notmatch 'Reader Contract' -or $routeExpectations -notmatch 'Comprehension Gate' -or $routeExpectations -notmatch 'before Impact Pass') {
                throw "Route eval does not enforce the reader-model ordering: $routeEvalName"
            }
        }
        Write-Host "Validated $($evals.Count) eval cases."
    }

    Invoke-Check 'reader-model workflow wiring' {
        $readerModelPath = Join-Path $repoRoot 'references/reader-model.md'
        $readerModelText = Get-Content -LiteralPath $readerModelPath -Raw
        foreach ($requiredSection in @('## Reader Contract', '## Comprehension Gate', '### 1. Reconstruction', '### 2. Novel case', '### 3. Counterexample', '### 4. Question repair')) {
            if ($readerModelText -notmatch [regex]::Escape($requiredSection)) {
                throw "Reader model is missing required section: $requiredSection"
            }
        }
        foreach ($routeFile in @('deep-read.md', 'source-dive.md', 'survey.md')) {
            $routeText = Get-Content -LiteralPath (Join-Path $repoRoot "references/$routeFile") -Raw
            if ($routeText -notmatch 'reader-model\.md' -or $routeText -notmatch 'Comprehension Gate') {
                throw "Workflow is not wired to the reader model: $routeFile"
            }
        }
    }

    Invoke-Check 'local document references' {
        $markdownFiles = @(Get-ProductMarkdownFiles)
        foreach ($file in $markdownFiles) {
            $text = Get-Content -LiteralPath $file -Raw

            foreach ($match in [regex]::Matches($text, 'references/[A-Za-z0-9._/-]+\.md')) {
                $target = $match.Value.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
                if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $target) -PathType Leaf)) {
                    throw "Missing referenced file '$($match.Value)' in $file"
                }
            }

            foreach ($match in [regex]::Matches($text, '\[[^\]]*\]\((?<target>[^)]+)\)')) {
                $target = $match.Groups['target'].Value.Trim().Trim('<', '>')
                if ($target -match '^(?:https?://|mailto:|app://|#)' -or $target -match '^\{') {
                    continue
                }
                $target = ($target -split '#', 2)[0]
                if ([string]::IsNullOrWhiteSpace($target)) {
                    continue
                }
                $resolved = Join-Path (Split-Path -Parent $file) $target
                if (-not (Test-Path -LiteralPath $resolved)) {
                    throw "Broken Markdown link '$target' in $file"
                }
            }
        }
    }

    Invoke-Check 'text hygiene and machine-path leakage' {
        $contentFiles = @(Get-ProductMarkdownFiles) + $evalPath
        foreach ($file in $contentFiles + @($scriptPath, $articleCheckPath, $runCheckPath)) {
            $lineNumber = 0
            foreach ($line in Get-Content -LiteralPath $file) {
                $lineNumber++
                if ($line -match '[ \t]+$') {
                    throw "Trailing whitespace at ${file}:$lineNumber"
                }
                if ($file -in $contentFiles -and $line -match '(?i)([A-Z]:\\Users\\|/Users/|/home/[^/\s]+/)') {
                    throw "Machine-specific path at ${file}:$lineNumber"
                }
            }
        }
    }

    Invoke-Check 'Git whitespace errors' {
        $git = (Get-Command git -ErrorAction Stop).Source
        $null = Invoke-NativeCommand -Command $git -Arguments @('-C', $repoRoot, 'diff', '--check')
    }

    Invoke-Check 'run verifier fixtures' {
        $fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('weave-run-check-' + [guid]::NewGuid().ToString('N'))
        try {
            New-Item -ItemType Directory -Path (Join-Path $fixtureRoot '.weave-frame') -Force | Out-Null
            @'
---
title: test
date: 2026-07-14
tags: [deep-read]
sources:
  - https://example.com
  - https://x.com/i/article/2052898104039657472
status: draft
---
# test

## 对我意味着什么
Material impact.

```text
# code heading
```not-a-closing-fence
Code samples may contain prose-like tokens such as 。， and >broken.
```
'@ | Set-Content -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Encoding utf8NoBOM
            @'
Timestamp: 2026-07-14T00:00:00Z
Workflow: deep-read
Topic: agent architecture
Hold-out identifier: source-2
Hold-out prediction: the boundary remains stable
Provisional selection: boundary-first
Comparative judgment: strongest evidence coverage
'@ | Set-Content -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Encoding utf8NoBOM
            @'
# Smoke Report
Host: Codex
Context source categories: explicit current request
Admitted impacts: 1
Comprehension Gate: passed
Voice Pass: passed
Article Integrity: passed
Chronology: verified
Artifact: .weave-frame/pre-reveal.md
'@ | Set-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Encoding utf8NoBOM

            $pwsh = (Get-Command pwsh -ErrorAction Stop).Source
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $runCheckPath, '-RunDirectory', $fixtureRoot, '-ImpactMode', 'personal')

            $surveyRouteRoot = Join-Path $fixtureRoot 'survey-route'
            New-Item -ItemType Directory -Path (Join-Path $surveyRouteRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $surveyRouteRoot '.weave-frame/pre-reveal.md')
            $surveyArticle = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Raw).Replace('tags: [deep-read]', "tags: [survey]`nrelated:`n  - deep-read")
            $surveyArticle | Set-Content -LiteralPath (Join-Path $surveyRouteRoot 'test-survey_2026-07-14.md') -Encoding utf8NoBOM
            $surveyReport = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw) -replace '(?m)^Article Integrity: passed\r?\n', ''
            $surveyReport | Set-Content -LiteralPath (Join-Path $surveyRouteRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $runCheckPath, '-RunDirectory', $surveyRouteRoot, '-ImpactMode', 'personal')

            $reportLeakRoot = Join-Path $fixtureRoot 'report-leak'
            New-Item -ItemType Directory -Path (Join-Path $reportLeakRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $reportLeakRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Destination (Join-Path $reportLeakRoot 'test-deep-read_2026-07-14.md')
            $reportWithContract = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw) + "`n## Article Closure Contract`n`nInternal fields.`n"
            $reportWithContract | Set-Content -LiteralPath (Join-Path $reportLeakRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $reportLeakRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted an Article Closure Contract heading in the delivery report.'
            }

            $readerLeakRoot = Join-Path $fixtureRoot 'reader-leak'
            New-Item -ItemType Directory -Path (Join-Path $readerLeakRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $readerLeakRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Destination (Join-Path $readerLeakRoot 'test-deep-read_2026-07-14.md')
            $reportWithReaderContract = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw) + "`n#### Reader Contract: hidden fields`n"
            $reportWithReaderContract | Set-Content -LiteralPath (Join-Path $readerLeakRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $readerLeakRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted a renamed Reader Contract heading in the delivery report.'
            }

            $readerFieldLeakRoot = Join-Path $fixtureRoot 'reader-field-leak'
            New-Item -ItemType Directory -Path (Join-Path $readerFieldLeakRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $readerFieldLeakRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Destination (Join-Path $readerFieldLeakRoot 'test-deep-read_2026-07-14.md')
            $reportWithReaderField = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw) + "`nStarting model: private baseline.`n"
            $reportWithReaderField | Set-Content -LiteralPath (Join-Path $readerFieldLeakRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $readerFieldLeakRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted a Reader Contract field dump without a heading.'
            }

            $frameReaderLeakRoot = Join-Path $fixtureRoot 'frame-reader-leak'
            New-Item -ItemType Directory -Path (Join-Path $frameReaderLeakRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $frameReaderLeakRoot '.weave-frame/pre-reveal.md')
            Add-Content -LiteralPath (Join-Path $frameReaderLeakRoot '.weave-frame/pre-reveal.md') -Value "Target capability: predict a new case"
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Destination (Join-Path $frameReaderLeakRoot 'test-deep-read_2026-07-14.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Destination (Join-Path $frameReaderLeakRoot 'smoke-report.md')
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $frameReaderLeakRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted Reader Contract fields in pre-reveal.md.'
            }

            $hollowComprehensionRoot = Join-Path $fixtureRoot 'hollow-comprehension'
            New-Item -ItemType Directory -Path (Join-Path $hollowComprehensionRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $hollowComprehensionRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Destination (Join-Path $hollowComprehensionRoot 'test-deep-read_2026-07-14.md')
            $hollowComprehensionReport = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw).Replace('Comprehension Gate: passed', 'Claimed Comprehension Gate: passed, but novel-case failed')
            $hollowComprehensionReport | Set-Content -LiteralPath (Join-Path $hollowComprehensionRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $hollowComprehensionRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted a hollow Comprehension Gate pass claim.'
            }

            $inlineRouteRoot = Join-Path $fixtureRoot 'inline-route'
            New-Item -ItemType Directory -Path (Join-Path $inlineRouteRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Destination (Join-Path $inlineRouteRoot 'smoke-report.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $inlineRouteRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Destination (Join-Path $inlineRouteRoot 'nonstandard-name.md')
            Add-Content -LiteralPath (Join-Path $inlineRouteRoot 'nonstandard-name.md') -Value "`n正文结束。，"
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $inlineRouteRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier skipped Article Integrity for an inline deep-read tag with a nonstandard filename.'
            }

            $articleFixtureRoot = Join-Path $fixtureRoot 'article-fixtures'
            New-Item -ItemType Directory -Path $articleFixtureRoot | Out-Null
            $negativeFixtures = @{
                'malformed-punctuation.md' = @'
---
title: malformed punctuation
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# malformed punctuation

正文在这里结束。，下一句从这里开始。
'@
                'noncanonical-source.md' = @'
---
title: noncanonical source
date: 2026-07-17
tags: [deep-read]
sources:
  - https://x.com/example/article/2053127519872614419
status: draft
---
# noncanonical source

正文保持完整。
'@
                'damaged-blockquote.md' = @'
---
title: damaged blockquote
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# damaged blockquote

>损坏的引用没有空格。
'@
                'dangling-blockquote.md' = @'
---
title: dangling blockquote
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# dangling blockquote

> 正文引用末尾带有损坏标记。>
'@
                'repeated-fragment.md' = @'
---
title: repeated fragment
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# repeated fragment

这段文字用于验证重复片段检测能够发现正文中的长句再次出现而没有任何解释。

这段文字用于验证重复片段检测能够发现正文中的长句再次出现而没有任何解释。
'@
                'title-mismatch.md' = @'
---
title: frontmatter title
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# different H1 title

正文保持完整。
'@
                'duplicate-source.md' = @'
---
title: duplicate source
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
  - https://example.com/source
status: draft
---
# duplicate source

正文保持完整。
'@
                'unclosed-fence.md' = @'
---
title: unclosed fence
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# unclosed fence

```text
code remains open
'@
                'internal-heading.md' = @'
---
title: internal heading
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# internal heading

## Article Closure Contract

Internal fields leaked into the article.
'@
                'internal-reader-field.md' = @'
---
title: internal reader field
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# internal reader field

Starting model: private baseline leaked into the article.
'@
            }
            foreach ($fixtureName in $negativeFixtures.Keys) {
                $negativePath = Join-Path $articleFixtureRoot $fixtureName
                $negativeFixtures[$fixtureName] | Set-Content -LiteralPath $negativePath -Encoding utf8NoBOM
                $null = @(& $pwsh -NoProfile -File $articleCheckPath -ArticlePath $negativePath 2>&1)
                if ($LASTEXITCODE -eq 0) {
                    throw "Article verifier accepted negative fixture: $fixtureName"
                }
            }

            $oversizedPath = Join-Path $articleFixtureRoot 'oversized.md'
            ('a' * (512KB + 1)) | Set-Content -LiteralPath $oversizedPath -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $articleCheckPath -ArticlePath $oversizedPath 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Article verifier accepted an article above the size limit.'
            }

            Add-Content -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Value "Why: fits the user's decision"
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $fixtureRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted a personal-context leak fixture.'
            }
        }
        finally {
            $resolved = [System.IO.Path]::GetFullPath($fixtureRoot)
            $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
            if ($resolved.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase) -and (Split-Path -Leaf $resolved).StartsWith('weave-run-check-')) {
                Remove-Item -LiteralPath $resolved -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    if (-not $SkipInstall) {
        $npx = (Get-Command npx -ErrorAction Stop).Source

        Invoke-Check 'skills CLI discovery' {
            Push-Location $repoRoot
            try {
                $output = Invoke-NativeCommand -Command $npx -Arguments @('-y', $skillsCliPackage, 'add', '.', '--list')
                $joined = $output -join "`n"
                if ($joined -notmatch 'Available Skills' -or $joined -notmatch '(?m)\bweave\b') {
                    throw 'skills CLI did not discover weave.'
                }
            }
            finally {
                Pop-Location
            }
        }

        Invoke-Check 'isolated package install' {
            $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('weave-check-' + [guid]::NewGuid().ToString('N'))
            $oldHome = $env:HOME
            $oldUserProfile = $env:USERPROFILE
            $oldCodexHome = $env:CODEX_HOME
            $oldNpmCache = $env:NPM_CONFIG_CACHE
            $oldNpmUserConfig = $env:NPM_CONFIG_USERCONFIG
            $oldXdgCacheHome = $env:XDG_CACHE_HOME
            $oldXdgConfigHome = $env:XDG_CONFIG_HOME
            New-Item -ItemType Directory -Path $tempRoot | Out-Null
            try {
                $env:HOME = $tempRoot
                $env:USERPROFILE = $tempRoot
                $env:CODEX_HOME = Join-Path $tempRoot '.codex'
                $env:NPM_CONFIG_CACHE = Join-Path $tempRoot '.npm-cache'
                $env:NPM_CONFIG_USERCONFIG = Join-Path $tempRoot '.npmrc'
                $env:XDG_CACHE_HOME = Join-Path $tempRoot '.cache'
                $env:XDG_CONFIG_HOME = Join-Path $tempRoot '.config'

                $installSource = $repoRoot
                $gitMarker = Join-Path $repoRoot '.git'
                if (Test-Path -LiteralPath $gitMarker -PathType Leaf) {
                    $installSource = Join-Path $tempRoot 'source'
                    New-Item -ItemType Directory -Path $installSource | Out-Null
                    foreach ($item in Get-ChildItem -LiteralPath $repoRoot -Force) {
                        if ($item.Name -eq '.git') {
                            continue
                        }
                        Copy-Item -LiteralPath $item.FullName -Destination $installSource -Recurse -Force
                    }
                }

                $null = Invoke-NativeCommand -Command $npx -Arguments @('-y', $skillsCliPackage, 'add', $installSource, '--skill', 'weave', '-g', '-a', 'codex', '-y')
                $installed = Join-Path $tempRoot '.agents/skills/weave'
                if (-not (Test-Path -LiteralPath $installed -PathType Container)) {
                    throw 'Isolated install did not create .agents/skills/weave.'
                }

                $runtimeFiles = @('SKILL.md', 'scripts/check.ps1', 'scripts/check-article.ps1', 'scripts/check-run.ps1')
                $runtimeFiles += @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'references') -Filter '*.md' -File | ForEach-Object { 'references/' + $_.Name })
                foreach ($relativePath in $runtimeFiles) {
                    $source = Join-Path $repoRoot $relativePath
                    $copy = Join-Path $installed $relativePath
                    if (-not (Test-Path -LiteralPath $copy -PathType Leaf)) {
                        throw "Packaged runtime file missing: $relativePath"
                    }
                    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $copy).Hash) {
                        throw "Packaged runtime file differs: $relativePath"
                    }
                }

                $runtimeSmoke = Join-Path $tempRoot 'runtime-smoke'
                New-Item -ItemType Directory -Path (Join-Path $runtimeSmoke '.weave-frame') -Force | Out-Null
                $runtimeArticle = @'
---
title: installed runtime
date: 2026-07-17
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# installed runtime

## 对我意味着什么

Material impact.
'@
                $runtimeArticlePath = Join-Path $runtimeSmoke 'installed-runtime-deep-read_2026-07-17.md'
                $runtimeArticle | Set-Content -LiteralPath $runtimeArticlePath -Encoding utf8NoBOM
                @'
Timestamp: 2026-07-17T00:00:00Z
Prediction: installed runtime resolves sibling scripts.
'@ | Set-Content -LiteralPath (Join-Path $runtimeSmoke '.weave-frame/pre-reveal.md') -Encoding utf8NoBOM
                @'
Host: Codex
Context source categories: explicit current request
Admitted impacts: 1
Comprehension Gate: passed
Voice Pass: passed
Article Integrity: passed
Chronology: verified
Artifact: .weave-frame/pre-reveal.md
'@ | Set-Content -LiteralPath (Join-Path $runtimeSmoke 'smoke-report.md') -Encoding utf8NoBOM

                $runtimePwsh = (Get-Command pwsh -ErrorAction Stop).Source
                $installedArticleCheck = Join-Path $installed 'scripts/check-article.ps1'
                $installedRunCheck = Join-Path $installed 'scripts/check-run.ps1'
                Push-Location $tempRoot
                try {
                    $null = Invoke-NativeCommand -Command $runtimePwsh -Arguments @('-NoProfile', '-File', $installedArticleCheck, '-ArticlePath', $runtimeArticlePath)
                    $null = Invoke-NativeCommand -Command $runtimePwsh -Arguments @('-NoProfile', '-File', $installedRunCheck, '-RunDirectory', $runtimeSmoke, '-ImpactMode', 'personal')
                    ($runtimeArticle + "`n正文结束。，") | Set-Content -LiteralPath $runtimeArticlePath -Encoding utf8NoBOM
                    $null = @(& $runtimePwsh -NoProfile -File $installedArticleCheck -ArticlePath $runtimeArticlePath 2>&1)
                    if ($LASTEXITCODE -eq 0) {
                        throw 'Installed Article Integrity checker accepted a malformed article.'
                    }
                }
                finally {
                    Pop-Location
                }

                $noiseNames = @('.git', 'node_modules', '__pycache__', '.pytest_cache', '.ruff_cache', '.mypy_cache', '.DS_Store')
                $noise = @(Get-ChildItem -LiteralPath $installed -Recurse -Force | Where-Object { $_.Name -in $noiseNames -or $_.Extension -in @('.pyc', '.log') })
                foreach ($hostDirectory in @('.agents', '.codex')) {
                    $hostPath = Join-Path $installed $hostDirectory
                    if (Test-Path -LiteralPath $hostPath -PathType Container) {
                        $noise += @(Get-ChildItem -LiteralPath $hostPath -Recurse -Force -File)
                    }
                }
                if ($noise.Count -gt 0) {
                    throw "Packaged skill contains development noise: $($noise[0].FullName)"
                }
            }
            finally {
                $env:HOME = $oldHome
                $env:USERPROFILE = $oldUserProfile
                $env:CODEX_HOME = $oldCodexHome
                $env:NPM_CONFIG_CACHE = $oldNpmCache
                $env:NPM_CONFIG_USERCONFIG = $oldNpmUserConfig
                $env:XDG_CACHE_HOME = $oldXdgCacheHome
                $env:XDG_CONFIG_HOME = $oldXdgConfigHome

                $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
                $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
                if ($resolvedTemp.StartsWith($tempBase, [System.StringComparison]::OrdinalIgnoreCase) -and (Split-Path -Leaf $resolvedTemp).StartsWith('weave-check-')) {
                    Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
                }
                else {
                    throw "Refusing to clean unexpected path: $resolvedTemp"
                }
            }
        }
    }
    else {
        Write-Host '[SKIP]  skills CLI discovery and isolated install'
    }

    Write-Host ''
    Write-Host 'All automated weave checks passed.' -ForegroundColor Green
    exit 0
}
catch {
    Write-Error "[FAIL] $($_.Exception.Message)"
    exit 1
}
