# themes link https://github.com/JanDeDobbeleer/oh-my-posh?WT.mc_id=-blog-scottha#themes
# Upgrade module trick  cd "C:\Program Files\PowerShell\7\" && pwsh.exe -noprofile -command "Install-Module PSReadLine -Force -SkipPublisherCheck -AllowPrerelease"
Import-Module PSReadLine
Import-Module cd-extras
Import-Module posh-git
Import-Module oh-my-posh
Import-Module Terminal-Icons
#Import-Module Get-ChildItemColor
#Import-Module PowerTab -ErrorAction SilentlyContinue
Import-Module PSColor
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'
Import-Module PSFzf
Set-PoshPrompt -Theme paradox # for oh-my-posh v3
Set-Theme Paradox #Set-Theme Agnoster
Set-TerminalIconsColorTheme -Name DevBlackOps
Import-Module DockerCompletion
Import-Module NPMTabCompletion
#$global:PSColor.File.Executable.Color = 'Blue'
#$ThemeSettings.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
#unicorn symbol [char]::ConvertFromUtf32(0x01F984)
$ThemeSettings.PromptSymbols.StartSymbol = [char]::ConvertFromUtf32(0x0001F525) 
$ThemeSettings.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x01F680) +[char]::ConvertFromUtf32(0x276F)
$DefaultUser = 'A687301'
$Env:NODE_OPTIONS = "max-old-space-size=8192"

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

function GoAdmin { start-process pwsh –verb runAs }

function Check-Modules {
   Get-InstalledModule | foreach { $b = (find-module $_.name).version ; if ($b -ne $_.version) { Write-host "$($_.name) has an update from $($_.version) to $b" } } 
}

function Update-Modules {
   Get-InstalledModule | Update-Module # -Force 
}

function Set-PathVariable {
   param (
        [string]$AddPath,
        [string]$RemovePath
   )
   $regexPaths = @()
   if ($PSBoundParameters.Keys -contains 'AddPath'){
        $regexPaths += [regex]::Escape($AddPath)
   }

   if ($PSBoundParameters.Keys -contains 'RemovePath'){
        $regexPaths += [regex]::Escape($RemovePath)
   }
    
   $arrPath = $env:Path -split ';'
   foreach ($path in $regexPaths) {
        $arrPath = $arrPath | Where-Object {$_ -notMatch "^$path\\?"}
   }
   $env:Path = ($arrPath + $addPath) -join ';'
}

function Dotnet-Rebuild {
   dotnet watch run  
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

function Dir-Icons {
   Get-ChildItem | Format-Wide
}

function GetMyIp { curl -L tool.lu/ip }

function GoBack { Set-Location .. }

# check if npm package is tree shakeable
function IsNpmPackageEsm {
  param (
       [string] $packagename
   )
  npx is-esm $packagename
}


Set-Alias .. GoBack
Set-Alias -Name np -Value notepad++
Set-Alias dwr Dotnet-Rebuild
Set-Alias gac Git-Commit
Set-Alias gs Git-Status
Set-Alias glp GitLogPretty
Set-Alias ls Dir-Icons
Set-Alias pum Update-Modules
Set-Alias pcm Check-Modules
Set-Alias gci Get-ComputerInfo
Set-Alias myip GetMyIp
Set-Alias isesm IsNpmPackageEsm
