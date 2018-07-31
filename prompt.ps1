function Get-BatteryLevelPromptString {
    $battery = Get-WmiObject -Class Win32_Battery

    if ($battery -ne $nul) {
        $charging = $battery.BatteryStatus -eq 2
        $charge = $battery.EstimatedChargeRemaining

        $defaultColors = "Red", "Magenta", "Yellow", "DarkYellow", "DarkCyan", "DarkGreen", "Green"
        $colors = ?? { $Theme["prompt.batteryColors"] } { $defaultColors }

        $chargeColor = $colors[[int]($charge / (100 / $colors.Length)) - 1]
        $chargingColors = ?? { $Theme["prompt.batteryChargingColors"]} { "Yellow", "Green" }
        $glyphColor = $chargingColors[$charging]
        $chargingGlyph = '++'
        if (!$charging) {
            $chargingGlyph = '--'
        }

        "[%<fg=$chargeColor>$charge%<fg=$glyphColor>$chargingGlyph%<fg=>] "
    }
}

function Get-DebugPromptString {
    if ($PSDebugContext) {
        $debugColor = ?? { $Theme["prompt.dbg"] } { 'Maroon' }
        "%<fg=$debugColor>[DBG]%<fg=>"
    }
}

function Get-GitPromptString {
    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus 2> $nul
    $global:LASTEXITCODE = $realLASTEXITCODE
}

function Get-PathPromptString {
    # swap '/' for '\'
    $cwd = $pwd.Path.Replace('\', '/')

    if (! $cwd.EndsWith('/')) {
        $cwd = $cwd + '/'
    }

    # check for path replacement names
    $replacementLength = 0
    $replacement = ""
    foreach ($r in $global:PromptPathReplacements.GetEnumerator()) {
        if ($cwd.StartsWith($r.Name, "CurrentCultureIgnoreCase")) {
            $replacementLength = $r.Name.Length
            $replacement = $r.Value
            $cwd = $cwd.SubString($r.Name.Length)
            break
        }
    }

    $maxLength = ?? { $Theme["prompt.MaxLen"] } { 50 }
    if ($cwd.length -ge $maxLength) {
        if ($replacementLength -gt 0) {
            $cwd = "…" + $cwd.SubString($cwd.length - $maxLength + 4)
        }
        else {
            $cwd = $pwd.Drive.Name + ":/…" + $cwd.SubString($cwd.length - $maxLength + 4)
        }
    }

    if ($err) {
        $errColor = ?? { $Theme["prompt.error"] } { 'DarkRed' }
        $replacementColor = ?? { $Theme["prompt." + $replacement + ".error"]} { $errColor }
        "%<fg=$replacementColor>$replacement%<fg=$errColor>$cwd%<fg=>"
    }
    else {
        $successColor = ?? { $Theme["prompt.success"] } { 'Green' }
        $replacementColor = ?? { $Theme["prompt." + $replacement + ".success"]} { $successColor }
        "%<fg=$replacementColor>$replacement%<fg=$successColor>$cwd%<fg=>"
    }
}

# PUSHD stack level prefix
function Get-StackLevelPromptString {
    $stackCount = (Get-Location -Stack).Count

    if ($stackCount -gt 0) {
        $stackColor = ?? { $Theme["prompt.stack"] } { 'Yellow' }

        $stack = "+" * $stackCount
        if ($stackCount -gt 5) {
            $stack = "+($stackCount)"
        }

        "%<fg=$stackColor>[$stack]%<fg=>"
    }
}

function Get-TerminatorPromptChar {
    git branch >$nul 2>$nul
    if ($?) {
        "±"
    }
    else {
        ">"
    }
}

function prompt {
    $batteryLevel = Get-BatteryLevelPromptString
    $debugPrompt = Get-DebugPromptString
    $stackLevel = Get-StackLevelPromptString
    $pathPrompt = Get-PathPromptString
    $gitPrompt = Get-GitPromptString
    $terminatorChar = Get-TerminatorPromptChar

    $prompt = $pathPrompt

    if ($stackLevel.Length -gt 0) {
        $prompt = "$stackLevel $prompt"
    }

    if ($debugPrompt.Length -gt 0) {
        $prompt = "$($debugPrompt.Length) $prompt"
    }

    if ($batteryLevel.Length -gt 0) {
        $prompt = "$batteryLevel $prompt"
    }

    if ($gitPrompt.Length -gt 0) {
        $prompt = "$prompt$gitPrompt"
    }

    if ($terminatorChar.Length -gt 0) {
        $prompt = "$prompt`n$terminatorChar"
    }

    Write-HostWithColor "`n$prompt" -NoNewline

    return " "
}
