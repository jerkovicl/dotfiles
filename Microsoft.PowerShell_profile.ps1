# themes link https: //github.com/JanDeDobbeleer/oh-my-posh?WT.mc_id=-blog-scottha#themes
# psreadline keybinds samples https: //raw.githubusercontent.com/PowerShell/PSReadLine/master/PSReadLine/SamplePSReadLineProfile.ps1
# Upgrade module trick  cd "C:\Program Files\PowerShell\7\" && pwsh.exe -noprofile -command "Install-Module PSReadLine -Force -SkipPublisherCheck -AllowPrerelease"
# Upgrade any module: Update-Module -Name modulename -AllowPrerelease -Scope CurrentUser
# install ohmyposh: oh-my-posh winget install JanDeDobbeleer.OhMyPosh
# upgrade ohmyposh: oh-my-posh winget upgrade JanDeDobbeleer.OhMyPosh

# ENV VARS

$DefaultUser = "LukaJerković"
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$MyModulePath = "C:\Tools\Tools\utils\Modules"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$MyModulePath"
$env:NPM_TOKEN = "xxxxx"
$env:NODE_OPTIONS = "max-old-space-size=8192"
[Environment]::SetEnvironmentVariable('FNM_DIR','C:\ProgramData\chocolatey\lib\fnm\tools')
fnm env --use-on-cd | Out-String | Invoke-Expression # fnm node manager init

# Modules import section

Import-Module cd-extras
Import-Module posh-git
Import-Module -Name Terminal-Icons

# PSReadLine settings
$PSReadLineOptions = @{
    PredictionSource = "HistoryAndPlugin"
    PredictionViewStyle = "ListView"
    EditMode = "Windows"
    HistoryNoDuplicates = $true
    HistorySearchCursorMovesToEnd = $true
    Colors = @{
      "InlinePrediction" = '#39A3F9'
      "ListPredictionSelected" = '#39A3F9'
    }
}
Set-PSReadLineOption @PSReadLineOptions
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'
Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function CaptureScreen
#Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
#Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Import-Module PSFzf

# OH-MY-POSH INIT
oh-my-posh --init --shell pwsh --config ~/.go-my-posh.json | Invoke-Expression

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

# Aliases

Add-Path -Directory "C:\Program Files\Notepad++"
Set-Alias edit notepad++.exe
Set-Alias .. GoBack
Set-Alias -Name np -Value notepad++
Set-Alias dwr Dotnet-Rebuild
Set-Alias gac Git-Commit
Set-Alias gs Git-Status
Set-Alias glp GitLogPretty
Set-Alias ls Dir-Icons
Set-Alias pum Update-Modules
Set-Alias pcm Check-Modules
Set-Alias myip GetMyIp
Set-Alias isesm IsNpmPackageEsm
Set-Alias swsld StartWSLDocker
Set-Alias wnv WriteNodeVersionForFnm
