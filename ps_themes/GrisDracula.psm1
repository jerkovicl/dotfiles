#requires -Version 2 -Modules posh-git

function Write-Theme {
    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    #check the last command state and indicate if failed
    $promtSymbolColor = $sl.Colors.PromptSymbolColor
    # If ($lastCommandFailed) {
    #     $promtSymbolColor = $sl.Colors.WithForegroundColor
    # }

    # Writes the drive portion
    $drive = $sl.PromptSymbols.HomeSymbol
    if ($pwd.Path -ne $HOME) {
        $drive = " ~/$(Split-Path -path $pwd -Leaf)"
    }

    $prompt += Write-Prompt -Object $drive -ForegroundColor $sl.Colors.DriveForegroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)

        $prompt += Write-Prompt -Object " on " -ForegroundColor $sl.Colors.WithForegroundColor

        $prompt += Write-Prompt -Object "$($themeInfo.VcInfo)" -ForegroundColor $sl.Colors.PromptHighlightColor
    }

    # Writes the postfixes to the prompt
    $prompt += Write-Prompt -Object (" " + $sl.PromptSymbols.PromptIndicator ) -ForegroundColor $promtSymbolColor

    $prompt += ' '
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.PromptIndicator = [char]::ConvertFromUtf32(0x2192)
$sl.Colors.PromptSymbolColor = [ConsoleColor]::Green
$sl.Colors.PromptHighlightColor = [ConsoleColor]::Blue
$sl.Colors.DriveForegroundColor = [ConsoleColor]::Cyan
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.PromptSymbols.GitDirtyIndicator = [char]::ConvertFromUtf32(10007)
$sl.Colors.GitDefaultColor = [ConsoleColor]::Yellow
