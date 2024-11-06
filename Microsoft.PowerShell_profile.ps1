# themes link https: //github.com/JanDeDobbeleer/oh-my-posh?WT.mc_id=-blog-scottha#themes
# psreadline keybinds samples https: //raw.githubusercontent.com/PowerShell/PSReadLine/master/PSReadLine/SamplePSReadLineProfile.ps1
# Upgrade module trick  cd "C:\Program Files\PowerShell\7\" && pwsh.exe -noprofile -command "Install-Module PSReadLine -Force -SkipPublisherCheck -AllowPrerelease"
# Upgrade any module: Update-Module -Name modulename -AllowPrerelease -Scope CurrentUser
# Install-Module -Name CompletionPredictor
# Install-Module PShell-AI
# install ohmyposh: winget install JanDeDobbeleer.OhMyPosh
# upgrade ohmyposh: winget upgrade JanDeDobbeleer.OhMyPosh

using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# ENV VARS

$DefaultUser = "xxx"
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$MyModulePath = "C:\Tools\Tools\utils\Modules"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$MyModulePath"
$env:POSH_GIT_ENABLED = $true
$env:FORCE_COLOR = 1
$env:OPENAI_API_KEY = "xxxx"
$env:NPM_TOKEN = "xxx"
$env:PROJECT_NPM_TOKEN = "xxxx"
$env:KEY_PATH = "C:\Users\xxx\ssl-localhost\localhost.key"
$env:CERT_PATH = "C:\Users\xxx\ssl-localhost\localhost.crt"
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\xxx\translateapi-xxxx-xxxx.json"
$env:NX_DAEMON = $true
$env:ESLINT_USE_FLAT_CONFIG = $true
$env:SONARCUBE = "xxxxxxx"
$env:NODE_OPTIONS = "max-old-space-size=8192"
$env:GITLAB_WORKFLOW_TOKEN = "xxxxxx"
$env:GITLAB_WORKFLOW_INSTANCE_URL = "https://xxx.yyy"
# NODE PATH - find with fnm env
#{FNM_DIR}\aliases\default
[Environment]::SetEnvironmentVariable('FNM_DIR','C:\ProgramData\chocolatey\lib\fnm\tools')
fnm env --use-on-cd | Out-String | Invoke-Expression # fnm node manager init
#if ($env:TERM_PROGRAM -eq "vscode") { . "$(code --locate-shell-integration-path pwsh)" }
#eval "$(github-copilot-cli alias -- "$0")"


# Modules import section

Import-Module cd-extras
Import-Module posh-git
Import-Module -Name Terminal-Icons
Import-Module CompletionPredictor

# PSReadLine settings
$PSReadLineOptions = @{
    PredictionSource = "HistoryAndPlugin"
    PredictionViewStyle = "ListView" #"InlineView"
    EditMode = "Windows"
    HistoryNoDuplicates = $true
    ShowToolTips = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
      "InlinePrediction" = "`e[38;5;238m"
      "ListPredictionSelected" = "#39A3F9"
      "Selection" = "`e[7m"
    }
}
Set-PSReadLineOption @PSReadLineOptions
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'
Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function CaptureScreen
#Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
#Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function AcceptSuggestion
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression

Import-Module PSFzf

# OH-MY-POSH INIT
# --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json'
oh-my-posh --init --shell pwsh --config ~/.go-my-posh.json | Invoke-Expression
Enable-PoshTooltips

# winget autocomplete
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Shell integration and completion
# https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration#how-to-enable-shell-integration-marks/
function Send-Completions {
  $commandLine = ""
  $cursorIndex = 0
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$commandLine, [ref]$cursorIndex)
  $completionPrefix = $commandLine

  $result = "`e]633;Completions"
  if ($completionPrefix.Length -gt 0) {
    $completions = TabExpansion2 -inputScript $completionPrefix -cursorColumn $cursorIndex
    if ($null -ne $completions.CompletionMatches) {
      $result += ";$($completions.ReplacementIndex);$($completions.ReplacementLength);$($cursorIndex);"
      $result += $completions.CompletionMatches | ConvertTo-Json -Compress
    }
  }
  $result += "`a"

  Write-Host -NoNewLine $result
}

function Set-MappedKeyHandlers {
  # Terminal suggest - always on keybindings
  Set-PSReadLineKeyHandler -Chord 'F12,b' -ScriptBlock {
    Send-Completions
  }
}

# Register key handlers if PSReadLine is available
if (Get-Module -Name PSReadLine) {
  Set-MappedKeyHandlers
}
else {
  Write-Host "PsReadline was disabled. Shell Completion was not enabled."
}

# Carapace

Function _git_completer {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "", Scope="Function", Target="*")]
    param($wordToComplete, $commandAst, $cursorPosition)
    $commandElements = $commandAst.CommandElements

    # double quoted value works but seems single quoted needs some fixing (e.g. "example 'acti" -> "example acti")
    $elems = @()
    foreach ($_ in $commandElements) {
      if ($_.Extent.StartOffset -gt $cursorPosition) {
          break
      }
      $t = $_.Extent.Text
      if ($_.Extent.EndOffset -gt $cursorPosition) {
          $t = $t.Substring(0, $_.Extent.Text.get_Length() - ($_.Extent.EndOffset - $cursorPosition))
      }

      if ($t.Substring(0,1) -eq "'"){
        $t = $t.Substring(1)
      }
      if ($t.get_Length() -gt 0 -and $t.Substring($t.get_Length()-1) -eq "'"){
        $t = $t.Substring(0,$t.get_Length()-1)
      }
      if ($t.get_Length() -eq 0){
        $t = '""'
      }
      $elems += $t.replace('`,', ',') # quick fix
    }

    $completions = @(
      if (!$wordToComplete) {
        carapace git powershell $($elems| ForEach-Object {$_}) '' | ConvertFrom-Json | ForEach-Object { [CompletionResult]::new($_.CompletionText, $_.ListItemText.replace('`e[', "`e["), [CompletionResultType]::ParameterValue, $_.ToolTip) }
      } else {
        carapace git powershell $($elems| ForEach-Object {$_}) | ConvertFrom-Json | ForEach-Object { [CompletionResult]::new($_.CompletionText, $_.ListItemText.replace('`e[', "`e["), [CompletionResultType]::ParameterValue, $_.ToolTip) }
      }
    )

    if ($completions.count -eq 0) {
      return "" # prevent default file completion
    }

    $completions
}
Register-ArgumentCompleter -Native -CommandName 'git' -ScriptBlock (Get-Item "Function:_git_completer").ScriptBlock

# Aliases functions
function GoAdmin { start-process pwsh –verb runAs
}

function Check-Modules {
   Get-InstalledModule | foreach { $b = (find-module $_.name).version ; if ($b -ne $_.version) { Write-host "$($_.name) has an update from $($_.version) to $b"
        }
    }
}

function Update-Modules {
   Get-InstalledModule | Update-Module # -Force -AllowPrerelease
}

function Dotnet-Rebuild {
   dotnet watch run
}

# Git

function gb {
    git checkout -b $args
}

function gbt ([string] $taskid) {
    git checkout -b "task/$taskid"
}

function gs {
    git checkout $args
    git pull
}

function gmaster {
    gs 'master'
}

function gmain {
    gs 'main'
}

function gdev {
    gs 'develop'
}

function gco {
    git add .
    git commit -m $args
}

function gfeat {
    if($null -eq $args[
        1
    ]) {
        gco "feat: $($args[0])"
    }else {
        gco "feat($($args[0])): $($args[1])"
    }
}

function gfix {
    if($null -eq $args[
        1
    ]) {
        gco "fix: $($args[0])"
    }else {
        gco "fix($($args[0])): $($args[1])"
    }
}

function gtest {
    if($null -eq $args[
        1
    ]) {
        gco "test: $($args[0])"
    }else {
        gco "test($($args[0])): $($args[1])"
    }
}

function gdocs {
    if($null -eq $args[
        1
    ]) {
        gco "docs: $($args[0])"
    }else {
        gco "docs($($args[0])): $($args[1])"
    }
}

function gstyle {
    if($null -eq $args[
        1
    ]) {
        gco "style: $($args[0])"
    }else {
        gco "style($($args[0])): $($args[1])"
    }
}

function grefactor {
    if($null -eq $args[
        1
    ]) {
        gco "refactor: $($args[0])"
    }else {
        gco "refactor($($args[0])): $($args[1])"
    }
}

function gperf {
    if($null -eq $args[
        1
    ]) {
        gco "perf: $($args[0])"
    }else {
        gco "perf($($args[0])): $($args[1])"
    }
}

function gchore {
    if($null -eq $args[
        1
    ]) {
        gco "chore: $($args[0])"
    }else {
        gco "chore($($args[0])): $($args[1])"
    }
}

function gpu {
    git pull
}

function goops {
    git add .
    git commit --amend --no-edit
}

function gfp {
    git push --force-with-lease
}

function gr {
    git reset --hard
    git clean -f -d
}


function Git-Commit {
   param (
       [string] $message
   )
   git add -A ; git commit -m $message
}

function Git-ListCommitFiles {
   param (
       [string] $commitId
   )
   git diff-tree --no-commit-id --name-only -r $commitId
}

function Git-Status {
   git status
}

function GitLogPretty {
  git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all
}

# Utils

function Dir-Icons {
   Get-ChildItem | Format-Wide
}

function GetMyIp { curl -L tool.lu/ip
}

function GoBack { Set-Location ..
}

# check if npm package is tree shakeable
function IsNpmPackageEsm {
  param (
    [string] $packagename
  )
  npx is-esm $packagename
}

function Add-Path {
  <#
    .SYNOPSIS
      Adds a Directory to the Current Path
    .DESCRIPTION
      Add a directory to the current path.  This is useful for
      temporary changes to the path or, when run from your
      profile, for adjusting the path within your powershell
      prompt.
    .EXAMPLE
      Add-Path -Directory "C:\Program Files\Notepad++"
    .PARAMETER Directory
      The name of the directory to add to the current path.
  #>

  [CmdletBinding()
    ]
  param (
    [Parameter(
      Mandatory=$True,
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,
      HelpMessage='What directory would you like to add?')
    ]
    [Alias('dir')
    ]
    [string[]]$Directory
  )

  PROCESS {
    $Path = $env:PATH.Split(';')

    foreach ($dir in $Directory) {
      if ($Path -contains $dir) {
        Write-Verbose "$dir is already present in PATH"
            } else {
        if (-not (Test-Path $dir)) {
          Write-Verbose "$dir does not exist in the filesystem"
                } else {
          $Path += $dir
                }
            }
        }

    $env:PATH = [String]::Join(';', $Path)
    }
}

#C:\Tools\Tools\utils\start_docker.ps1
function StartWSLDocker {
  $ip = (wsl sh -c "hostname -I").Split(" ")[
        0
    ]
  netsh interface portproxy add v4tov4 listenport=2375 connectport=2375 connectaddress=$ip
  wsl sh -c "sudo dockerd -H tcp://$ip"
}

function WriteNodeVersionForFnm {
  node --version > .node-version
}

function New-Tab { wt -w 0 nt -d . }

# Github Copilot CLI alias setup
function checkResponse {
  if ( $Args[0] -eq $true ) {
    $fileContents = Get-Content $tempFile
    Write-Host $fileContents
    # write contents of file to console (basically EVAL())
    Invoke-Expression $fileContents
  }
  else {
    Write-Host "User cancelled the command."
  }
  # clear file contents
  Set-Content $tempFile ""
}

function githubCopilotCommand {
  $tempFile = "c:\temp\copilot.txt"
  $firstItem, $remaining = $Args
  if ( $Args[0] -eq "-help" ) {
    $codeToRun = "github-copilot-cli help"
    Invoke-Expression $codeToRun
  }
  elseif ( $Args[0] -eq "-g" -or $Args[0] -eq "-git" ) {
    Write-Host "github-copilot-cli git-assist --shellout $tempFile $remaining"
    github-copilot-cli git-assist --shellout $tempFile $remaining
    checkResponse $?
  }
  elseif ( $Args[0] -eq "-gh" -or $Args[0] -eq "-github" ) {
    Write-Host "github-copilot-cli gh-assist --shellout $tempFile $remaining"
    github-copilot-cli gh-assist --shellout $tempFile $remaining
    checkResponse $?
  }
  else {
    Write-Host "github-copilot-cli what-the-shell --shellout $tempFile powershell $Args"
    github-copilot-cli what-the-shell --shellout $tempFile powershell $Args
    checkResponse $?
  }
}

# Aliases

Add-Path -Directory "C:\Program Files\Notepad++"
Set-Alias edit notepad++.exe
Set-Alias .. GoBack
Set-Alias -Name np -Value notepad++
Set-Alias dwr Dotnet-Rebuild
Set-Alias gac Git-Commit
Set-Alias glcf Git-ListCommitFiles
Set-Alias gs Git-Status
Set-Alias glp GitLogPretty
#Set-Alias ls Dir-Icons
Set-Alias pum Update-Modules
Set-Alias pcm Check-Modules
Set-Alias myip GetMyIp
Set-Alias isesm IsNpmPackageEsm
Set-Alias swsld StartWSLDocker
Set-Alias wnv WriteNodeVersionForFnm
Set-Alias nt New-Tab
Set-Alias /cp githubCopilotCommand
Set-Alias copilot githubCopilotCommand

