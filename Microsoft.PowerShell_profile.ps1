# PowerShell Profile ported from zsh functions and aliases

# --- Git Helper Functions ---

function searchGitRoot {
    param($Path = (Get-Location).Path)
    $current = Get-Item $Path
    while ($current) {
        if (Test-Path (Join-Path $current.FullName ".git")) {
            return $current.FullName
        }
        $current = $current.Parent
    }
    return $null
}

function b {
    $branch = git branch --sort=-committerdate | fzf --height 40% --layout=reverse --border | ForEach-Object { $_.Trim().TrimStart('*').Trim() }
    if ($branch) {
        git switch $branch
    }
}

function ba {
    $branch = git branch -a --sort=-committerdate | fzf --height 40% --layout=reverse --border | ForEach-Object {
        $_.Trim().TrimStart('*').Trim() -replace '^remotes/origin/', ''
    }
    if ($branch) {
        git switch $branch
    }
}

function bm {
    $root = searchGitRoot
    if (-not $root) {
        Write-Host "invalid path`nplease run at git root directory"
        return
    }

    $remote = git remote -v
    if ($remote -match "origin") {
        $origin_url = git remote get-url origin
        $origin_url = $origin_url -replace 'https://github.com/', '' -replace '\.git$', ''
        gh repo set-default $origin_url
    }

    $prList = Join-Path $root ".git/pr-list"
    gh pr list > $prList
    if (-not (Test-Path $prList) -or (Get-Item $prList).Length -eq 0) {
        b
        return
    }

    $selected = Get-Content $prList | ForEach-Object {
        $fields = $_ -split "\t"
        if ($fields.Count -ge 3) {
            "$($fields[2])`t$($fields[1])"
        } else {
            $_
        }
    } | fzf --height 40% --layout=reverse --border

    if ($selected) {
        $branch = ($selected -split "`t")[0]
        git fetch
        git switch $branch
    }
}

function gcb {
    param($p1, $p2)
    if (-not $p1) {
        Write-Host "Please provide a new branch name or prefix and Jira URL"
        return
    }
    if (-not $p2) {
        $branch = $p1
    } else {
        $suffix = $p2 -replace '.*/', ''
        $branch = "$p1/$suffix"
    }
    git checkout -b $branch
}

# --- Navigation Functions ---

function Get-ParentDirectories {
    param($Path = (Get-Location).Path)
    $current = Get-Item $Path
    $paths = @()
    while ($current) {
        $paths += $current.FullName
        $current = $current.Parent
    }
    return $paths
}

function cdp {
    $selected = Get-ParentDirectories | fzf --height 40% --layout=reverse --border
    if ($selected) {
        Set-Location $selected
    }
}

function cdr {
    $root = searchGitRoot
    if ($root) {
        Set-Location $root
    }
}

# --- Utility Functions ---

function pmc {
    if (Test-Path "package-lock.json") { "npm" }
    elseif (Test-Path "yarn.lock") { "yarn" }
    elseif (Test-Path "pnpm-lock.yaml") { "pnpm" }
    else { "?" }
}

function node_install {
    if (Test-Path ".node-version") {
        $version = Get-Content ".node-version" -Raw
        Write-Host $version.Trim()
        # volta install node@$version.Trim()
    }
}

function rmn {
    $timestamp = Get-Date -UFormat %s
    if (Test-Path "./node_modules") {
        Move-Item ./node_modules "/tmp/node_modules.$timestamp"
    }
}

function rl {
    if ($PROFILE) {
        . $PROFILE
    }
}

function cb {
    system_profiler SPPowerDataType | Select-String 'State of Charge'
}

function confetti {
    open raycast://confetti
}

# --- Aliases & Short Functions ---

# Git
function g { git @args }
function gs { git status @args }
function glo { git log --oneline @args }
function gcm { git switch main; if ($?) { git pull @args } }
function gc { git checkout @args }
function gco { git commit @args }
function gd { git diff @args }
function gdf { git diff --name-only @args }
function gdm { git diff main @args }
function gdmw { git diff main -w @args }
function gdw { git diff -w @args }
function gds { git diff --staged @args }
function gdsw { git diff --staged -w @args }
function gdws { git diff --staged -w @args }
function gl { git log @args }
function gloh { git log --oneline @args | select -first 10 }
function gloo { git log --oneline @args | select -first 1 }

# Docker
function d { docker @args }
function dc { docker compose @args }
function dce { docker compose exec @args }
function dcd { docker compose down @args }
function dcud { docker compose up -d @args }
function dcudb { docker compose up -d --build @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function cd- { Set-Location - }

# System Utilities
function l { Get-ChildItem @args }
function ll { Get-ChildItem @args }
function la { Get-ChildItem -Force @args }

# Node
function n { node @args }

# Nvim
function vim { nvim @args }
function vimc { nvim ~/.config/ @args }
function vimp { nvim ~/.config/nvim/lua/plugins @args }

# Application Shortcuts (macOS)
function chrome { open -a "Google Chrome" @args }
function ff { open -a "Firefox" @args }
function edge { open -a "Microsoft Edge" @args }
