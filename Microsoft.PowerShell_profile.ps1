Import-Module cd-extras
Import-Module posh-git
Import-Module oh-my-posh
Import-Module Terminal-Icons
#Import-Module PowerTab -ErrorAction SilentlyContinue
Import-Module PSColor
Set-Theme Paradox #Set-Theme Agnoster
Set-TerminalIconsColorTheme -Name DevBlackOps
#$global:PSColor.File.Executable.Color = 'Blue'
#$ThemeSettings.GitSymbols.BranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
$DefaultUser = 'A687301'

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
