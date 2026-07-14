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
            'evals/evals.json',
            'evals/smoke.md',
            'references/collect.md',
            'references/context-acquisition.md',
            'references/deep-read.md',
            'references/frame-selection.md',
            'references/impact-pass.md',
            'references/output-spec.md',
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
        Write-Host "Validated $($evals.Count) eval cases."
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
        foreach ($file in $contentFiles + $scriptPath) {
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

                $runtimeFiles = @('SKILL.md', 'scripts/check.ps1')
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
}
catch {
    Write-Error "[FAIL] $($_.Exception.Message)"
    exit 1
}
