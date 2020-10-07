Import-Module cd-extras
Import-Module posh-git
Import-Module oh-my-posh
Import-Module Terminal-Icons
#Import-Module PowerTab -ErrorAction SilentlyContinue
Import-Module PSColor
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'
Import-Module PSFzf
Set-Theme Paradox #Set-Theme Agnoster
Set-TerminalIconsColorTheme -Name DevBlackOps
#$global:PSColor.File.Executable.Color = 'Blue'
#$ThemeSettings.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
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

function Dir-Icons {
   Get-ChildItem | Format-Wide
}

Set-Alias dwr Dotnet-Rebuild
Set-Alias gac Git-Commit
Set-Alias -Name np -Value notepad++
Set-Alias gs Git-Status
Set-Alias lsi Dir-Icons
Set-Alias pum Update-Modules
Set-Alias pcm Check-Modules
Set-Alias gci Get-ComputerInfo
