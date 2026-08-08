#requires -Version 7.0

[CmdletBinding()]
param(
    [switch]$SkipInstall,
    [switch]$CheckLiveInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skillPath = Join-Path $repoRoot 'SKILL.md'
$evalPath = Join-Path $repoRoot 'evals/evals.json'
$courseBaselinePath = Join-Path $repoRoot 'evals/anthropic-course-baseline.md'
$courseSaturatedPath = Join-Path $repoRoot 'evals/anthropic-course-saturated.md'
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

function Get-NormalizedTextSha256 {
    param(
        [Parameter(Mandatory)]
        [string]$LiteralPath
    )

    $text = [System.IO.File]::ReadAllText($LiteralPath)
    $normalizedText = $text.Replace("`r`n", "`n").Replace("`r", "`n")
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($normalizedText)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha256.ComputeHash($bytes)
    }
    finally {
        $sha256.Dispose()
    }
    return ([System.BitConverter]::ToString($hashBytes) -replace '-', '').ToLowerInvariant()
}

function Get-CourseAtomicScores {
    param(
        [Parameter(Mandatory)]
        [string]$AtomicText,

        [Parameter(Mandatory)]
        [string]$Label
    )

    $expectedSections = [ordered]@{
        'Getting started with Claude' = 16
        'Prompt engineering & evaluation' = 16
        'Tool use with Claude' = 14
        'Retrieval augmented generation' = 10
        'Model Context Protocol (MCP)' = 12
        'Claude Code & Computer Use' = 8
        'Agents and workflows' = 11
    }
    $sectionRows = [regex]::Matches($AtomicText, '(?m)^\| (?<name>[^|]+?) \| (?<count>\d+) \| (?<p1>[01]) \| (?<p2>[01]) \| (?<p3>[01]) \| (?<p4>[01]) \| (?<p5>[01]) \| (?<sum>[0-5]) \|$')
    if ($sectionRows.Count -ne 7) {
        throw "Anthropic course $Label atomic record must contain exactly seven section rows; found $($sectionRows.Count)."
    }
    $weightedProbeSum = 0
    $displayedLectureSum = 0
    $seenSections = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $sectionRows) {
        $sectionName = $row.Groups['name'].Value.Trim()
        if (-not $expectedSections.Contains($sectionName)) {
            throw "Anthropic course $Label atomic record contains an unknown section: $sectionName"
        }
        if (-not $seenSections.Add($sectionName)) {
            throw "Anthropic course $Label atomic record contains a duplicate section: $sectionName"
        }
        $probeSum = [int]$row.Groups['p1'].Value + [int]$row.Groups['p2'].Value + [int]$row.Groups['p3'].Value + [int]$row.Groups['p4'].Value + [int]$row.Groups['p5'].Value
        if ($probeSum -ne [int]$row.Groups['sum'].Value) {
            throw "Anthropic course $Label section probe row has an incorrect p_i sum: $($row.Groups['name'].Value)"
        }
        $lectureCount = [int]$row.Groups['count'].Value
        if ($lectureCount -ne [int]$expectedSections[$sectionName]) {
            throw "Anthropic course $Label section $sectionName must use the fixed public lecture count $($expectedSections[$sectionName]); found $lectureCount."
        }
        $displayedLectureSum += $lectureCount
        $weightedProbeSum += $lectureCount * $probeSum
    }
    if ($displayedLectureSum -ne 87) {
        throw "Anthropic course $Label atomic section lecture counts must sum to 87; found $displayedLectureSum."
    }

    $objectiveRows = [regex]::Matches($AtomicText, '(?m)^\| (?<objective>O[1-7]) \| (?<concept>[01]) \| (?<operation>[01]) \| (?<failure>[01]) \| (?<boundary>[01]) \| (?<pass>[01]) \|$')
    if ($objectiveRows.Count -ne 7) {
        throw "Anthropic course $Label atomic record must contain exactly seven objective rows; found $($objectiveRows.Count)."
    }
    $passedObjectives = 0
    $seenObjectives = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $objectiveRows) {
        $objectiveName = $row.Groups['objective'].Value
        if (-not $seenObjectives.Add($objectiveName)) {
            throw "Anthropic course $Label atomic record contains a duplicate objective: $objectiveName"
        }
        $expectedPass = if ($row.Groups['concept'].Value -eq '1' -and $row.Groups['operation'].Value -eq '1' -and $row.Groups['failure'].Value -eq '1' -and $row.Groups['boundary'].Value -eq '1') { 1 } else { 0 }
        if ([int]$row.Groups['pass'].Value -ne $expectedPass) {
            throw "Anthropic course $Label objective verdict does not match its atomic probes."
        }
        $passedObjectives += $expectedPass
    }

    $componentRows = [regex]::Matches($AtomicText, '(?m)^\| (?<rubric>[CDE]) \| (?<v1>\d+) \| (?<v2>\d+) \| (?<v3>\d+) \| (?<v4>\d+|-) \| (?<score>\d+\.\d) \|$')
    if ($componentRows.Count -ne 3) {
        throw "Anthropic course $Label atomic record must contain exactly three C/D/E component rows; found $($componentRows.Count)."
    }
    $componentMaximums = @{
        C = @(5, 5, 5, 5)
        D = @(3, 3, 2, 2)
        E = @(2, 2, 1, 0)
    }
    $componentScores = @{}
    foreach ($row in $componentRows) {
        $rubric = $row.Groups['rubric'].Value
        if ($componentScores.ContainsKey($rubric)) {
            throw "Anthropic course $Label atomic record contains a duplicate component row: $rubric"
        }
        if ($rubric -eq 'E' -and $row.Groups['v4'].Value -ne '-') {
            throw "Anthropic course $Label E component row must use '-' for the unused fourth component."
        }
        if ($rubric -ne 'E' -and $row.Groups['v4'].Value -eq '-') {
            throw "Anthropic course $Label $rubric component row must contain four numeric components."
        }
        $values = @(
            [int]$row.Groups['v1'].Value,
            [int]$row.Groups['v2'].Value,
            [int]$row.Groups['v3'].Value,
            $(if ($row.Groups['v4'].Value -eq '-') { 0 } else { [int]$row.Groups['v4'].Value })
        )
        for ($index = 0; $index -lt 4; $index++) {
            if ($values[$index] -gt $componentMaximums[$rubric][$index]) {
                throw "Anthropic course $Label $rubric component $($index + 1) exceeds its rubric maximum."
            }
        }
        $computedScore = [double](($values | Measure-Object -Sum).Sum)
        $storedScore = [double]::Parse($row.Groups['score'].Value, [System.Globalization.CultureInfo]::InvariantCulture)
        if ($storedScore -ne $computedScore) {
            throw "Anthropic course $Label $rubric component score is incorrect: stored $storedScore, computed $computedScore."
        }
        $componentScores[$rubric] = $storedScore
    }

    return [pscustomobject]@{
        A = [Math]::Round(40.0 * $weightedProbeSum / 435.0, 1, [System.MidpointRounding]::AwayFromZero)
        B = [Math]::Round(25.0 * $passedObjectives / 7.0, 1, [System.MidpointRounding]::AwayFromZero)
        C = $componentScores.C
        D = $componentScores.D
        E = $componentScores.E
    }
}

function Get-CourseLedgerRecord {
    param(
        [Parameter(Mandatory)]
        [string]$BenchmarkText,

        [Parameter(Mandatory)]
        [string]$RunLabel
    )

    $runPattern = '^\|\s*' + [regex]::Escape($RunLabel) + '\s*\|'
    $lines = @($BenchmarkText -split "`r?`n" | Where-Object { $_ -match $runPattern })
    if ($lines.Count -ne 1) {
        throw "Anthropic course benchmark requires exactly one $RunLabel ledger row."
    }
    $cells = @($lines[0].Trim('|').Split('|') | ForEach-Object { $_.Trim() })
    if ($cells.Count -ne 12) {
        throw "Anthropic course $RunLabel ledger row must contain exactly 12 cells; found $($cells.Count)."
    }
    foreach ($scoreIndex in 3..8) {
        if ($cells[$scoreIndex] -notmatch '^\d+\.\d$') {
            throw "Anthropic course $RunLabel score must use exactly one decimal place: $($cells[$scoreIndex])"
        }
    }

    $parseCulture = [System.Globalization.CultureInfo]::InvariantCulture
    $scores = @(3..8 | ForEach-Object { [double]::Parse($cells[$_], $parseCulture) })
    $maximums = @(40.0, 25.0, 20.0, 10.0, 5.0, 100.0)
    for ($index = 0; $index -lt $scores.Count; $index++) {
        if ($scores[$index] -lt 0.0 -or $scores[$index] -gt $maximums[$index]) {
            throw "Anthropic course $RunLabel score is outside its rubric range: $($scores[$index]) > $($maximums[$index])"
        }
    }
    $computedTotal = [Math]::Round($scores[0] + $scores[1] + $scores[2] + $scores[3] + $scores[4], 1, [System.MidpointRounding]::AwayFromZero)
    if ($scores[5] -ne $computedTotal) {
        throw "Anthropic course $RunLabel total does not match stored components: stored $($scores[5]), computed $computedTotal"
    }

    return [pscustomobject]@{
        Cells = $cells
        A = $scores[0]
        B = $scores[1]
        C = $scores[2]
        D = $scores[3]
        E = $scores[4]
        Total = $scores[5]
    }
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

function Get-ExpectedRuntimeFiles {
    $files = @(
        'MIGRATION.md',
        'README.en.md',
        'README.md',
        'SKILL.md',
        'assets/weave-mark.svg',
        'scripts/check.ps1',
        'scripts/check-article.ps1',
        'scripts/check-run.ps1',
        'evals/anthropic-course-baseline.md',
        'evals/anthropic-course-benchmark.md',
        'evals/anthropic-course-saturated.md',
        'evals/evals.json',
        'evals/frame-quality.md',
        'evals/smoke.md'
    )
    $files += @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'references') -Filter '*.md' -File | ForEach-Object { 'references/' + $_.Name })
    return @($files | Sort-Object -Unique)
}

function Get-OptionalRuntimeFiles {
    # skills@1.5.17 may preserve repository CI metadata for a direct local install,
    # but the workflow is not required by the installed skill runtime.
    return @('.github/workflows/check.yml')
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
            'evals/anthropic-course-baseline.md',
            'evals/anthropic-course-benchmark.md',
            'evals/anthropic-course-saturated.md',
            'evals/smoke.md',
            'references/collect.md',
            'references/article-integrity.md',
            'references/context-acquisition.md',
            'references/deep-read.md',
            'references/frame-selection.md',
            'references/impact-pass.md',
            'references/learning-design.md',
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
        foreach ($requiredSkillContract in @('Only after routing to Survey', 'prefix the first response line with 🥷 inline', 'support the user''s thinking rather than replacing it', 'This clause does not alter Deep Read or Source Dive', 'check whether `/read` and `/write` are installed', 'cross-phase visual protocol', '<!-- weave-visual -->', '#+begin_example', '#+end_example', '80 ASCII columns')) {
            if ($skillText -notmatch [regex]::Escape($requiredSkillContract)) {
                throw "SKILL.md is missing upstream Learn or Survey visual contract: $requiredSkillContract"
            }
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
        foreach ($requiredEvalName in @('initial-question-repair', 'generative-comprehension', 'source-dive-curiosity-engineering-work', 'source-dive-system-understanding', 'publication-reader-research-consequence', 'publication-reader-time-bound', 'publication-reader-editorial-noop', 'publication-reader-no-amplification', 'reader-evidence-truth-boundary', 'reader-effect-editorial-routing', 'survey-learn-canonical-article', 'survey-spine-direction-gate', 'survey-visual-pass', 'survey-classification-integrity', 'survey-cross-phase-visual-contract', 'survey-anthropic-api-course-benchmark')) {
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
        $publicationEvalExpectations = @($evals | Where-Object { $_.name -like 'publication-reader-*' } | ForEach-Object { $_.expectations }) -join "`n"
        foreach ($requiredPublicationConcept in @('Publication Reader Extension', 'Public reader', 'recurring situation', 'missing capability', 'durable payoff', 'Research consequence', 'no-op', 'time-bound', 'source quality', 'counterexample', 'frontmatter', 'delivery report')) {
            if ($publicationEvalExpectations -notmatch [regex]::Escape($requiredPublicationConcept)) {
                throw "Publication-reader evals do not cover required concept: $requiredPublicationConcept"
            }
        }
        $readerEvidenceExpectations = @($evals | Where-Object { $_.name -like 'reader-evidence-*' -or $_.name -like 'reader-effect-*' } | ForEach-Object { $_.expectations }) -join "`n"
        foreach ($requiredReaderEvidenceConcept in @('L0', 'L1', 'L2', 'L3', 'generation-side', 'serialized', 'Article Recoverability', 'actual reader', 'fifth Comprehension Gate probe', 'optional', 'persisted')) {
            if ($readerEvidenceExpectations -notmatch [regex]::Escape($requiredReaderEvidenceConcept)) {
                throw "Reader-evidence evals do not cover required concept: $requiredReaderEvidenceConcept"
            }
        }
        $surveyLearnExpectations = @($evals | Where-Object { $_.name -like 'survey-*' } | ForEach-Object { $_.expectations }) -join "`n"
        foreach ($requiredSurveyLearnConcept in @('Canonical Article', 'Collect', 'Digest', 'Outline', 'Fill', 'Refine', 'Spine Direction Gate', 'explicitly selects', 'through-object', 'Visual Pass', 'prose reflow', '<!-- weave-visual -->', '#+begin_example', '#+end_example', '80 ASCII columns', 'immediately followed', 'standalone', 'Article Integrity', 'Article Recoverability', 'Human Self-review', 'trend-capable evidence', 'hybrid method', 'course page and access date', 'baseline', 'stopping decision')) {
            if ($surveyLearnExpectations -notmatch [regex]::Escape($requiredSurveyLearnConcept)) {
                throw "Survey Learn evals do not cover required concept: $requiredSurveyLearnConcept"
            }
        }
        foreach ($routeEvalName in @('source-dive-real-repo', 'survey-real-domain')) {
            $routeEval = $evals | Where-Object { $_.name -eq $routeEvalName } | Select-Object -First 1
            $routeExpectations = @($routeEval.expectations) -join "`n"
            if ($routeExpectations -notmatch 'Reader Contract' -or $routeExpectations -notmatch 'Comprehension Gate' -or $routeExpectations -notmatch 'before Impact Pass') {
                throw "Route eval does not enforce the reader-model ordering: $routeEvalName"
            }
        }
        $sourceDiveExpectations = @($evals | Where-Object { $_.name -in @('source-dive-real-repo', 'source-dive-curiosity-engineering-work', 'source-dive-system-understanding') } | ForEach-Object { $_.expectations }) -join "`n"
        foreach ($requiredSourceDiveConcept in @('understand', 'learn', 'apply', 'system scope', 'System Design Brief', 'canonical task', 'takeaways', 'independent reader', 'Engineering Decision Brief', 'weave inference', 'Article Integrity')) {
            if ($sourceDiveExpectations -notmatch [regex]::Escape($requiredSourceDiveConcept)) {
                throw "Source-dive evals do not cover required concept: $requiredSourceDiveConcept"
            }
        }
        Write-Host "Validated $($evals.Count) eval cases."
    }

    Invoke-Check 'reader-model workflow wiring' {
        $readerModelPath = Join-Path $repoRoot 'references/reader-model.md'
        $readerModelText = Get-Content -LiteralPath $readerModelPath -Raw
        foreach ($requiredSection in @('## Evidence boundary', '## Reader Contract', '## Publication Reader Extension', '## Comprehension Gate', '### 1. Reconstruction', '### 2. Novel case', '### 3. Counterexample', '### 4. Question repair')) {
            if ($readerModelText -notmatch [regex]::Escape($requiredSection)) {
                throw "Reader model is missing required section: $requiredSection"
            }
        }
        foreach ($requiredBoundary in @('generation-side capability proxy', 'L0', 'L1', 'L2', 'L3', 'actual reader', 'do not add a fifth Comprehension Gate probe')) {
            if ($readerModelText -notmatch [regex]::Escape($requiredBoundary)) {
                throw "Reader model is missing evidence boundary: $requiredBoundary"
            }
        }
        foreach ($routeFile in @('deep-read.md', 'source-dive.md', 'survey.md')) {
            $routeText = Get-Content -LiteralPath (Join-Path $repoRoot "references/$routeFile") -Raw
            if ($routeText -notmatch 'reader-model\.md' -or $routeText -notmatch 'Comprehension Gate') {
                throw "Workflow is not wired to the reader model: $routeFile"
            }
        }
    }

    Invoke-Check 'reader-outcome and final-file wiring' {
        $learningDesignPath = Join-Path $repoRoot 'references/learning-design.md'
        $learningDesignText = Get-Content -LiteralPath $learningDesignPath -Raw
        foreach ($requiredSection in @('## Select the reader outcome', '## Extend the Reader Contract', '## Build the Learning Spine for Deep Read and Source Dive', '### Explain', '### Map', '### Evaluate', '### Decide', '### Enter', '## Final-article recoverability')) {
            if ($learningDesignText -notmatch [regex]::Escape($requiredSection)) {
                throw "Learning design is missing required section: $requiredSection"
            }
        }
        foreach ($requiredConcept in @('Survey now uses the Learn Mode Gate', 'prerequisite floor', 'dependency order', 'misconception', 'new case', 'L1 article recoverability', 'L2 and L3')) {
            if ($learningDesignText -notmatch [regex]::Escape($requiredConcept)) {
                throw "Learning design is missing required concept: $requiredConcept"
            }
        }
        foreach ($routeFile in @('deep-read.md', 'source-dive.md')) {
            $routeText = Get-Content -LiteralPath (Join-Path $repoRoot "references/$routeFile") -Raw
            foreach ($requiredRouteConcept in @('learning-design.md', 'Learning Spine', 'article-integrity.md', 'Article Recoverability')) {
                if ($routeText -notmatch [regex]::Escape($requiredRouteConcept)) {
                    throw "Workflow is not wired to reader outcome and final-file validation: $routeFile [$requiredRouteConcept]"
                }
            }
        }
        $surveyText = Get-Content -LiteralPath (Join-Path $repoRoot 'references/survey.md') -Raw
        foreach ($requiredSurveyConcept in @('## Mode Gate', '| Mode | Goal | Entry | Exit |', '| **Quick Reference** | Build a working mental model fast, no article planned | Phase 2 | Phase 2: notes only |', 'collection prerequisite', '## Learn pre-check', 'Prefix the first Survey response line with 🥷 inline', 'Support the user''s thinking; do not replace it', '## Phase 1: Collect', '## Phase 2: Digest', '## Phase 3: Outline', '## Spine Direction Gate', '## Phase 4: Fill', '## Phase 5: Refine', '## Phase 5.5: Visual Pass', '## Phase 6: Self-review', '/read', '/write', '**Discover**', '**Fetch**', '**File**', 'official specifications and documentation', 'first-party technical blogs or reports', 'systematic reviews and textbooks', '### Conversation or review distillation', 'opening sentence rewritten three times', 'accurate mental model, an executable or inspectable operation, a common failure, and an evidence or version boundary', 'two or three candidates', 'explicit choice', 'concrete through-object', '📍', '<!-- weave-visual -->', '#+begin_example', '#+end_example', '80 ASCII columns', 'supporting evidence and applicability boundary immediately after', 'standalone test', 'Survey has no Domain Payoff')) {
            if ($surveyText -notmatch [regex]::Escape($requiredSurveyConcept)) {
                throw "Survey is missing Learn-based workflow concept: $requiredSurveyConcept"
            }
        }
        $courseBenchmarkText = Get-Content -LiteralPath (Join-Path $repoRoot 'evals/anthropic-course-benchmark.md') -Raw
        foreach ($requiredBenchmarkConcept in @('Building with the Claude API', '## Public course inventory', 'Getting started with Claude', 'Prompt engineering & evaluation', 'Tool use with Claude', 'Retrieval augmented generation', 'Model Context Protocol (MCP)', 'Claude Code & Computer Use', 'Agents and workflows', '84 lectures', '8.1 hours', '10 quizzes', 'displayed lecture counts sum to 87', '## 100-point rubric', '### A. Section coverage — 40 points', 'five binary probes', 'A = 40 × Σ(c_i × p_i) / (87 × 5)', '### B. Objective completion — 25 points', 'B = 25 × passed objectives / 7', 'there is no partial objective credit', '### C. Correctness and evidence — 20 points', '### D. Learnability and integration — 10 points', '### E. Artifact and visual integrity — 5 points', '## Hard fails', 'at least 85/100', 'at least 92/100', '## Run ledger', '## Iteration 3 cross-phase visual audit', 'Iteration 3 — saturated', '100.0', '## Defect analysis', '## Saturation gate', 'no proposed workflow change', '### Authoritative baseline atomic record', 'Σ(c_i × p_i) = 375', 'passed objectives = 2', '### Saturated comparison atomic record', 'Σ(c_i × p_i) = 435', 'passed objectives = 7', 'evals/anthropic-course-baseline.md', 'e0635935c77d92e5a8ed8f70ec29371370fe59ebc0ec15a6e5d12a953cf1bbc8', 'evals/anthropic-course-saturated.md', '5354efc7aa016fdae6a4031eedc5ec8809c538bf877475544723fce019764208')) {
            if ($courseBenchmarkText -notmatch [regex]::Escape($requiredBenchmarkConcept)) {
                throw "Anthropic course benchmark is missing required concept: $requiredBenchmarkConcept"
            }
        }

        $expectedBaselineHash = 'e0635935c77d92e5a8ed8f70ec29371370fe59ebc0ec15a6e5d12a953cf1bbc8'
        $actualBaselineHash = Get-NormalizedTextSha256 -LiteralPath $courseBaselinePath
        if ($actualBaselineHash -ne $expectedBaselineHash) {
            throw "Anthropic course baseline SHA-256 mismatch: expected $expectedBaselineHash, found $actualBaselineHash"
        }
        $expectedSaturatedHash = '5354efc7aa016fdae6a4031eedc5ec8809c538bf877475544723fce019764208'
        $actualSaturatedHash = Get-NormalizedTextSha256 -LiteralPath $courseSaturatedPath
        if ($actualSaturatedHash -ne $expectedSaturatedHash) {
            throw "Anthropic course saturated artifact SHA-256 mismatch: expected $expectedSaturatedHash, found $actualSaturatedHash"
        }

        $baselineAtomicMatch = [regex]::Match($courseBenchmarkText, '(?ms)^### Authoritative baseline atomic record\s*(?<body>.*?)(?=^### Saturated comparison atomic record\s*$)')
        $saturatedAtomicMatch = [regex]::Match($courseBenchmarkText, '(?ms)^### Saturated comparison atomic record\s*(?<body>.*?)(?=^\| Run \|)')
        if (-not $baselineAtomicMatch.Success -or -not $saturatedAtomicMatch.Success) {
            throw 'Anthropic course benchmark must contain separate baseline and saturated atomic records.'
        }
        $baselineAtomic = Get-CourseAtomicScores -AtomicText $baselineAtomicMatch.Groups['body'].Value -Label 'baseline'
        $saturatedAtomic = Get-CourseAtomicScores -AtomicText $saturatedAtomicMatch.Groups['body'].Value -Label 'saturated'

        $baselineLedger = Get-CourseLedgerRecord -BenchmarkText $courseBenchmarkText -RunLabel 'Authoritative rescore'
        if ($baselineLedger.A -ne $baselineAtomic.A -or $baselineLedger.B -ne $baselineAtomic.B -or $baselineLedger.C -ne $baselineAtomic.C -or $baselineLedger.D -ne $baselineAtomic.D -or $baselineLedger.E -ne $baselineAtomic.E) {
            throw "Anthropic course authoritative scores do not match baseline atomic records."
        }
        if ($baselineLedger.Cells[2] -notmatch [regex]::Escape('evals/anthropic-course-baseline.md') -or $baselineLedger.Cells[2] -notmatch $expectedBaselineHash) {
            throw 'Anthropic course authoritative ledger does not identify the verified baseline artifact and hash.'
        }

        $saturatedLedger = Get-CourseLedgerRecord -BenchmarkText $courseBenchmarkText -RunLabel 'Iteration 3 — saturated'
        if ($saturatedLedger.A -ne $saturatedAtomic.A -or $saturatedLedger.B -ne $saturatedAtomic.B -or $saturatedLedger.C -ne $saturatedAtomic.C -or $saturatedLedger.D -ne $saturatedAtomic.D -or $saturatedLedger.E -ne $saturatedAtomic.E) {
            throw "Anthropic course saturated scores do not match saturated atomic records."
        }
        if ($saturatedLedger.C -ne 20.0 -or $saturatedLedger.D -ne 10.0 -or $saturatedLedger.E -ne 5.0 -or $saturatedLedger.Total -ne 100.0) {
            throw 'Anthropic course saturated ledger must preserve the independently audited 20.0/10.0/5.0 component scores and 100.0 total.'
        }
        if ($saturatedLedger.Cells[2] -notmatch [regex]::Escape('evals/anthropic-course-saturated.md') -or $saturatedLedger.Cells[2] -notmatch $expectedSaturatedHash) {
            throw 'Anthropic course saturated ledger does not identify the verified saturated artifact and hash.'
        }
        $articleIntegrityText = Get-Content -LiteralPath (Join-Path $repoRoot 'references/article-integrity.md') -Raw
        foreach ($requiredIntegrityConcept in @('Every deep-read, source-dive, and survey run', 'For Deep Read or Source Dive `explain` also check', 'For Deep Read or Source Dive `map` also check', 'For survey also check', 'selected Survey spine', 'Visual Pass')) {
            if ($articleIntegrityText -notmatch [regex]::Escape($requiredIntegrityConcept)) {
                throw "Article Integrity is missing all-route semantic coverage: $requiredIntegrityConcept"
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
Evidence workflow: deep-read
Reader outcome: map
Admitted impacts: 1
Comprehension Gate: passed
Voice Pass: passed
Article Integrity: passed
Article Recoverability: not required
Chronology: verified
Artifact: .weave-frame/pre-reveal.md
'@ | Set-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Encoding utf8NoBOM

            $pwsh = (Get-Command pwsh -ErrorAction Stop).Source
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $runCheckPath, '-RunDirectory', $fixtureRoot, '-ImpactMode', 'personal')

            $surveyRouteRoot = Join-Path $fixtureRoot 'survey-route'
            New-Item -ItemType Directory -Path (Join-Path $surveyRouteRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $surveyRouteRoot '.weave-frame/pre-reveal.md')
            $surveyArticle = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Raw).Replace('tags: [deep-read]', "tags:`n  - survey # route comment`ntopic: test`nscope: focused`nrelated:`n  - deep-read")
            $surveyArticle | Set-Content -LiteralPath (Join-Path $surveyRouteRoot 'nonstandard-name.md') -Encoding utf8NoBOM
            $surveyReport = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw).Replace('Evidence workflow: deep-read', 'Evidence workflow: survey').Replace('Reader outcome: map', "Survey mode: Deep Research`nVisual Pass: candidates=2, admitted=0, deleted=2`nHuman Self-review: pending")
            $surveyReport | Set-Content -LiteralPath (Join-Path $surveyRouteRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $runCheckPath, '-RunDirectory', $surveyRouteRoot, '-ImpactMode', 'personal')

            $visualCountMismatchRoot = Join-Path $fixtureRoot 'visual-count-mismatch'
            New-Item -ItemType Directory -Path (Join-Path $visualCountMismatchRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $surveyRouteRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $visualCountMismatchRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $surveyRouteRoot 'nonstandard-name.md') -Destination (Join-Path $visualCountMismatchRoot 'nonstandard-name.md')
            $surveyReport.Replace('Visual Pass: candidates=2, admitted=0, deleted=2', 'Visual Pass: candidates=2, admitted=1, deleted=1') | Set-Content -LiteralPath (Join-Path $visualCountMismatchRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $visualCountMismatchRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted a Survey admitted count that differs from serialized visual markers.'
            }

            $exactTagRoot = Join-Path $fixtureRoot 'exact-tag-route'
            New-Item -ItemType Directory -Path (Join-Path $exactTagRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $exactTagRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Destination (Join-Path $exactTagRoot 'smoke-report.md')
            $exactTagArticle = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Raw).Replace('tags: [deep-read]', 'tags: [deep-read, survey-notes, source-dive-notes]')
            $exactTagArticle | Set-Content -LiteralPath (Join-Path $exactTagRoot 'nonstandard-name.md') -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $runCheckPath, '-RunDirectory', $exactTagRoot, '-ImpactMode', 'personal')

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

            $explainWithoutRecoverabilityRoot = Join-Path $fixtureRoot 'explain-without-recoverability'
            New-Item -ItemType Directory -Path (Join-Path $explainWithoutRecoverabilityRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $explainWithoutRecoverabilityRoot '.weave-frame/pre-reveal.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Destination (Join-Path $explainWithoutRecoverabilityRoot 'test-deep-read_2026-07-14.md')
            $explainWithoutRecoverabilityReport = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw).Replace('Reader outcome: map', 'Reader outcome: explain')
            $explainWithoutRecoverabilityReport | Set-Content -LiteralPath (Join-Path $explainWithoutRecoverabilityRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $explainWithoutRecoverabilityRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted an explain report without Article Recoverability: passed.'
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

            $inlineSourceDiveRoot = Join-Path $fixtureRoot 'inline-source-dive-route'
            New-Item -ItemType Directory -Path (Join-Path $inlineSourceDiveRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Destination (Join-Path $inlineSourceDiveRoot 'smoke-report.md')
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $inlineSourceDiveRoot '.weave-frame/pre-reveal.md')
            $sourceDiveArticle = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'test-deep-read_2026-07-14.md') -Raw).Replace('tags: [deep-read]', 'tags: [source-dive]')
            ($sourceDiveArticle + "`n正文结束。，") | Set-Content -LiteralPath (Join-Path $inlineSourceDiveRoot 'nonstandard-name.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $inlineSourceDiveRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier skipped Article Integrity for an inline source-dive tag with a nonstandard filename.'
            }

            $sourceDiveMissingStatusRoot = Join-Path $fixtureRoot 'source-dive-missing-integrity-status'
            New-Item -ItemType Directory -Path (Join-Path $sourceDiveMissingStatusRoot '.weave-frame') -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $fixtureRoot '.weave-frame/pre-reveal.md') -Destination (Join-Path $sourceDiveMissingStatusRoot '.weave-frame/pre-reveal.md')
            $sourceDiveArticle | Set-Content -LiteralPath (Join-Path $sourceDiveMissingStatusRoot 'test-source-dive_2026-07-14.md') -Encoding utf8NoBOM
            $sourceDiveReportWithoutIntegrity = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'smoke-report.md') -Raw) -replace '(?m)^Article Integrity: passed\r?\n', ''
            $sourceDiveReportWithoutIntegrity | Set-Content -LiteralPath (Join-Path $sourceDiveMissingStatusRoot 'smoke-report.md') -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $runCheckPath -RunDirectory $sourceDiveMissingStatusRoot -ImpactMode personal 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Run verifier accepted a source-dive report without Article Integrity: passed.'
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
                'survey-unclosed-org-example.md' = @'
---
title: survey unclosed org example
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey unclosed org example

<!-- weave-visual -->
#+begin_example
A --> B
'@
                'survey-orphan-org-end.md' = @'
---
title: survey orphan org end
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey orphan org end

#+end_example
'@
                'survey-nested-org-example.md' = @'
---
title: survey nested org example
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey nested org example

<!-- weave-visual -->
#+begin_example
#+begin_example
A --> B
#+end_example
#+end_example
'@
                'survey-invalid-org-delimiter.md' = @'
---
title: survey invalid org delimiter
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey invalid org delimiter

<!-- weave-visual -->
#+begin_example ascii
A --> B
#+end_example
'@
                'survey-markdown-fenced-ascii.md' = @'
---
title: survey markdown fenced ascii
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey markdown fenced ascii

<!-- weave-visual -->
```text
A --> B
```
'@
                'survey-naked-ascii.md' = @'
---
title: survey naked ascii
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey naked ascii

A --> B
'@
                'survey-indented-naked-ascii.md' = @'
---
title: survey indented naked ascii
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey indented naked ascii

    A => B

	A ==> B
'@
                'survey-unmarked-org-visual.md' = @'
---
title: survey unmarked org visual
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey unmarked org visual

#+begin_example
A --> B
#+end_example
'@
                'survey-unmarked-mermaid-visual.md' = @'
---
title: survey unmarked mermaid visual
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey unmarked mermaid visual

```mermaid
flowchart LR
    A --> B
```
'@
                'survey-naked-wide-arrow.md' = @'
---
title: survey naked wide arrow
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey naked wide arrow

A ==> B => C
'@
                'survey-naked-curve.md' = @'
---
title: survey naked curve
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey naked curve

loss | __/****
'@
                'survey-diagram-fence.md' = @'
---
title: survey diagram fence
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey diagram fence

```diagram
A ==> B
```
'@
                'survey-pandoc-text-fence.md' = @'
---
title: survey pandoc text fence
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey pandoc text fence

```{.text}
A => B
```
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
                'internal-learning-spine-field.md' = @'
---
title: internal learning spine field
date: 2026-07-17
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# internal learning spine field

Central model: hidden composition control leaked into the article.
'@
                'internal-survey-spine-field.md' = @'
---
title: internal survey spine field
date: 2026-07-17
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# internal survey spine field

Through-object: hidden Survey composition control leaked into the article.
'@
                'survey-missing-route-frontmatter.md' = @'
---
title: survey missing route frontmatter
date: 2026-07-17
tags: [survey]
sources:
  - https://example.com/source
status: draft
---
# survey missing route frontmatter

正文保持完整。
'@
                'internal-source-dive-field.md' = @'
---
title: internal source dive field
date: 2026-07-17
tags: [source-dive]
sources:
  - https://example.com/source
status: draft
---
# internal source dive field

Observed problem: internal brief leaked into the article.
'@
                'internal-source-dive-frontmatter.md' = @'
---
title: internal source dive frontmatter
date: 2026-07-17
tags: [source-dive]
sources:
  - https://example.com/source
status: draft
reading_intent: understand
---
# internal source dive frontmatter

正文保持完整。
'@
                'internal-source-dive-scope-frontmatter.md' = @'
---
title: internal source dive scope frontmatter
date: 2026-07-18
tags: [source-dive]
sources:
  - https://example.com/source
status: draft
reading_scope: system
---
# internal source dive scope frontmatter

正文保持完整。
'@
                'internal-source-dive-table.md' = @'
---
title: internal source dive table
date: 2026-07-17
tags: [source-dive]
sources:
  - https://example.com/source
status: draft
---
# internal source dive table

| Observed problem | Internal brief leaked into a table |
| --- | --- |
| Design forces | Hidden contract data |
| Executable mechanism | Hidden implementation data |
| Evidence status | Hidden provenance data |
'@
                'internal-system-design-table.md' = @'
---
title: internal system design table
date: 2026-07-18
tags: [source-dive]
sources:
  - https://example.com/source
status: draft
---
# internal system design table

| Product identity | Hidden product model |
| --- | --- |
| Core state | Hidden state model |
| Canonical task loop | Hidden task model |
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

            $overwideOrgPath = Join-Path $articleFixtureRoot 'survey-overwide-org-example.md'
            $overwideOrgArticle = @'
---
title: survey overwide org example
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey overwide org example

<!-- weave-visual -->
#+begin_example
{org-line}
#+end_example
'@.Replace('{org-line}', ('x' * 81))
            $overwideOrgArticle | Set-Content -LiteralPath $overwideOrgPath -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $articleCheckPath -ArticlePath $overwideOrgPath 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Article verifier accepted an Org example line wider than 80 columns.'
            }

            $overwideTabOrgPath = Join-Path $articleFixtureRoot 'survey-overwide-tab-org-example.md'
            $overwideTabOrgArticle = @'
---
title: survey overwide tab org example
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey overwide tab org example

<!-- weave-visual -->
#+begin_example
{org-line}
#+end_example
'@.Replace('{org-line}', ("`t" * 11))
            $overwideTabOrgArticle | Set-Content -LiteralPath $overwideTabOrgPath -Encoding utf8NoBOM
            $null = @(& $pwsh -NoProfile -File $articleCheckPath -ArticlePath $overwideTabOrgPath 2>&1)
            if ($LASTEXITCODE -eq 0) {
                throw 'Article verifier accepted an Org example line wider than 80 columns after tab expansion.'
            }

            $validOrgPath = Join-Path $articleFixtureRoot 'survey-valid-org-example.md'
            $validOrgArticle = @'
---
title: survey valid org example
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey valid org example

正文先用人话和案例解释关系。

<!-- weave-visual -->
#+begin_example
{org-line}
#+end_example

**状态从 A 流向 B。**

Evidence: https://example.com/source. Boundary: this shows flow, not effect size.
'@.Replace('{org-line}', ('x' * 74 + ' --> B'))
            $validOrgArticle | Set-Content -LiteralPath $validOrgPath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $validOrgPath)

            $validVisualTablePath = Join-Path $articleFixtureRoot 'survey-valid-visual-table.md'
            @'
---
title: survey valid visual table
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey valid visual table

正文和案例先解释状态变化。

<!-- weave-visual -->
| Stage | Transition |
|---|---|
| request | model -> tool |

**表格对齐状态与转移。**

Evidence: https://example.com/source. Boundary: this is an ordering aid.
'@ | Set-Content -LiteralPath $validVisualTablePath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $validVisualTablePath)

            $validTabOrgPath = Join-Path $articleFixtureRoot 'survey-valid-tab-org-example.md'
            $validTabOrgArticle = @'
---
title: survey valid tab org example
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey valid tab org example

<!-- weave-visual -->
#+begin_example
{org-line}
#+end_example
'@.Replace('{org-line}', ("`t" * 10))
            $validTabOrgArticle | Set-Content -LiteralPath $validTabOrgPath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $validTabOrgPath)

            $surveyTypedCodePath = Join-Path $articleFixtureRoot 'survey-typed-code.md'
            @'
---
title: survey typed code
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey typed code

这段代码中的箭头是类型标注，不是 ASCII 图。

```python
def build_request() -> dict:
    return {}
```
'@ | Set-Content -LiteralPath $surveyTypedCodePath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $surveyTypedCodePath)

            $surveyIndentedTypedCodePath = Join-Path $articleFixtureRoot 'survey-indented-typed-code.md'
            @'
---
title: survey indented typed code
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey indented typed code

真实的 Python 返回类型标注不是 ASCII 图。

    def f() -> dict:
        return {}
'@ | Set-Content -LiteralPath $surveyIndentedTypedCodePath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $surveyIndentedTypedCodePath)

            $surveyNonVisualCodePath = Join-Path $articleFixtureRoot 'survey-nonvisual-code.md'
            @'
---
title: survey nonvisual code
date: 2026-08-08
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# survey nonvisual code

Inline syntax such as `A => B` is not a visual.

<!-- weave-visual -->
```mermaid
flowchart LR
    A --> B
```
'@ | Set-Content -LiteralPath $surveyNonVisualCodePath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $surveyNonVisualCodePath)

            $surveyNotesPath = Join-Path $articleFixtureRoot 'neutral-survey-notes.md'
            @'
---
title: neutral survey notes
date: 2026-08-08
tags: [survey-notes]
sources:
  - https://example.com/source
status: draft
---
# neutral survey notes

A ==> B
'@ | Set-Content -LiteralPath $surveyNotesPath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $surveyNotesPath)

            $sourceDiveNotesPath = Join-Path $articleFixtureRoot 'neutral-source-dive-notes.md'
            @'
---
title: neutral source dive notes
date: 2026-08-08
tags: [source-dive-notes]
sources:
  - https://example.com/source
status: draft
---
# neutral source dive notes

Observed problem: this is ordinary reader-visible prose for a non-route tag.
'@ | Set-Content -LiteralPath $sourceDiveNotesPath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $sourceDiveNotesPath)

            $nonSurveyOrgPath = Join-Path $articleFixtureRoot 'deep-read-org-example.md'
            @'
---
title: deep read org example
date: 2026-08-08
tags: [deep-read]
sources:
  - https://example.com/source
status: draft
---
# deep read org example

#+begin_example
A ==> B
'@ | Set-Content -LiteralPath $nonSurveyOrgPath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $nonSurveyOrgPath)

            $referenceAppendixPath = Join-Path $articleFixtureRoot 'reference-appendix-repeat.md'
            @'
---
title: reference appendix repeat
date: 2026-07-17
tags: [survey]
topic: test
scope: focused
sources:
  - https://example.com/source
status: draft
---
# reference appendix repeat

正文会自然引用 [Conservative Q-Learning for Offline Reinforcement Learning](https://example.com/source)，但这不是重复段落。

## Further Reading

1. [Conservative Q-Learning for Offline Reinforcement Learning](https://example.com/source).

## References

1. Author. [Conservative Q-Learning for Offline Reinforcement Learning](https://example.com/source). 2020.
'@ | Set-Content -LiteralPath $referenceAppendixPath -Encoding utf8NoBOM
            $null = Invoke-NativeCommand -Command $pwsh -Arguments @('-NoProfile', '-File', $articleCheckPath, '-ArticlePath', $referenceAppendixPath)

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

                $runtimeFiles = @(Get-ExpectedRuntimeFiles)
                $optionalRuntimeFiles = @(Get-OptionalRuntimeFiles)
                $installedFiles = @(Get-ChildItem -LiteralPath $installed -File -Recurse | ForEach-Object {
                    [System.IO.Path]::GetRelativePath($installed, $_.FullName).Replace('\', '/')
                } | Sort-Object -Unique)
                $missingRuntimeFiles = @($runtimeFiles | Where-Object { $_ -notin $installedFiles })
                $allowedRuntimeFiles = @($runtimeFiles + $optionalRuntimeFiles | Sort-Object -Unique)
                $unexpectedRuntimeFiles = @($installedFiles | Where-Object { $_ -notin $allowedRuntimeFiles })
                if ($missingRuntimeFiles.Count -gt 0 -or $unexpectedRuntimeFiles.Count -gt 0) {
                    throw "Packaged runtime file set differs from the exact allowlist. Missing: $($missingRuntimeFiles -join ', '); unexpected: $($unexpectedRuntimeFiles -join ', ')"
                }
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
                foreach ($relativePath in @($optionalRuntimeFiles | Where-Object { $_ -in $installedFiles })) {
                    $source = Join-Path $repoRoot $relativePath
                    $copy = Join-Path $installed $relativePath
                    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $copy).Hash) {
                        throw "Optional packaged runtime file differs: $relativePath"
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
Evidence workflow: deep-read
Reader outcome: map
Admitted impacts: 1
Comprehension Gate: passed
Voice Pass: passed
Article Integrity: passed
Article Recoverability: not required
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

    if ($CheckLiveInstall) {
        Invoke-Check 'live install has no retired route collisions' {
            $userProfilePath = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
            if ([string]::IsNullOrWhiteSpace($userProfilePath)) {
                throw 'Could not resolve the current user profile for live-install validation.'
            }
            $skillRoots = @(
                (Join-Path $userProfilePath '.agents/skills'),
                (Join-Path $userProfilePath '.codex/skills'),
                (Join-Path $userProfilePath '.claude/skills')
            )
            $collisions = [System.Collections.Generic.List[string]]::new()
            $liveWeavePaths = [System.Collections.Generic.List[string]]::new()
            foreach ($skillRoot in $skillRoots) {
                foreach ($retiredName in @('deep-read', 'source-dive', 'survey')) {
                    $candidate = Join-Path $skillRoot $retiredName
                    if (Test-Path -LiteralPath $candidate -PathType Container) {
                        $collisions.Add($candidate)
                    }
                }
                $weaveCandidate = Join-Path $skillRoot 'weave'
                if (Test-Path -LiteralPath $weaveCandidate -PathType Container) {
                    $liveWeavePaths.Add($weaveCandidate)
                }
            }
            if ($collisions.Count -gt 0) {
                throw "Retired route skills remain discoverable: $($collisions -join ', ')"
            }
            if ($liveWeavePaths.Count -eq 0) {
                throw 'No live weave installation was found in the supported skill roots.'
            }
            $liveRuntimeFiles = @(Get-ExpectedRuntimeFiles)
            $optionalRuntimeFiles = @(Get-OptionalRuntimeFiles)
            foreach ($liveWeavePath in @($liveWeavePaths | Sort-Object -Unique)) {
                $installedFiles = @(Get-ChildItem -LiteralPath $liveWeavePath -File -Recurse | ForEach-Object {
                    [System.IO.Path]::GetRelativePath($liveWeavePath, $_.FullName).Replace('\', '/')
                } | Sort-Object -Unique)
                $missingRuntimeFiles = @($liveRuntimeFiles | Where-Object { $_ -notin $installedFiles })
                $allowedRuntimeFiles = @($liveRuntimeFiles + $optionalRuntimeFiles | Sort-Object -Unique)
                $unexpectedRuntimeFiles = @($installedFiles | Where-Object { $_ -notin $allowedRuntimeFiles })
                if ($missingRuntimeFiles.Count -gt 0 -or $unexpectedRuntimeFiles.Count -gt 0) {
                    throw "Live weave installation differs from the exact runtime allowlist. Missing: $($missingRuntimeFiles -join ', '); unexpected: $($unexpectedRuntimeFiles -join ', ')"
                }
                foreach ($relativePath in $liveRuntimeFiles) {
                    $sourcePath = Join-Path $repoRoot $relativePath
                    $installedPath = Join-Path $liveWeavePath $relativePath
                    if (-not (Test-Path -LiteralPath $installedPath -PathType Leaf)) {
                        throw "Live weave installation is missing ${relativePath}: $liveWeavePath"
                    }
                    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $installedPath).Hash) {
                        throw "Live weave installation differs from the repository for ${relativePath}: $liveWeavePath"
                    }
                }
                foreach ($relativePath in @($optionalRuntimeFiles | Where-Object { $_ -in $installedFiles })) {
                    $sourcePath = Join-Path $repoRoot $relativePath
                    $installedPath = Join-Path $liveWeavePath $relativePath
                    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash -ne (Get-FileHash -Algorithm SHA256 -LiteralPath $installedPath).Hash) {
                        throw "Optional live weave installation file differs for ${relativePath}: $liveWeavePath"
                    }
                }
            }
        }
    }
    else {
        Write-Host '[SKIP]  live-install collision and content check'
    }

    Write-Host ''
    Write-Host 'All automated weave checks passed.' -ForegroundColor Green
    exit 0
}
catch {
    Write-Error "[FAIL] $($_.Exception.Message)"
    exit 1
}
