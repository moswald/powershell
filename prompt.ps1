if ($null -ne $GitPromptSettings) {
    $GitPromptSettings.EnableFileStatus = $false
}

#
# the prompt will replace any path strings with these pretty names
# initially created with just the user's home path
$global:PromptPathReplacements = @{
    $home.Replace('\', '/') = "~"
}

function Get-BatteryLevelPromptString {
    param(
        [bool]$err
    )

    $battery = Get-WmiObject -Class Win32_Battery;

    if ($battery -ne $nul) {
        # todo: 6 apparently means charging
        #       2 only means connected to AC (may not be charging)
        # see: https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-battery
        $charging = $battery.BatteryStatus -eq 2
        $charge = $battery.EstimatedChargeRemaining

        $defaultColors = "Red", "Magenta", "Yellow", "DarkYellow", "DarkCyan", "DarkGreen", "Green"
        $colors = Get-ThemeValue "prompt.batteryColors" $defaultColors;

        $chargeColor = $colors[[int]($charge / (100 / $colors.Length)) - 1]
        $chargingColors = Get-ThemeValue "prompt.batteryChargingColors" ("Yellow", "Green")
        $glyphColor = $chargingColors[$charging]
        $chargingGlyph = '++'
        if (!$charging) {
            $chargingGlyph = '--'
        }

        "[%<fg=$chargeColor>$charge%<fg=$glyphColor>$chargingGlyph%<fg=>] "
    }
}

function Get-DebugPromptString {
    param(
        [bool]$err
    )

    if ($PSDebugContext) {
        $debugColor = Get-ThemeValue "prompt.dbg" 'Maroon'
        "%<fg=$debugColor>[DBG]%<fg=>"
    }
}

function Get-GitPromptString {
    param(
        [bool]$err
    )

    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus #2> $nul
    $global:LASTEXITCODE = $realLASTEXITCODE
}

function Get-PathPromptString {
    param(
        [bool]$err
    )

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

    $maxLength = Get-ThemeValue "prompt.MaxLen" 50
    if ($cwd.length -ge $maxLength) {
        if ($replacementLength -gt 0) {
            $cwd = "…" + $cwd.SubString($cwd.length - $maxLength + 4)
        }
        else {
            $cwd = $pwd.Drive.Name + ":/…" + $cwd.SubString($cwd.length - $maxLength + 4)
        }
    }

    if ($err) {
        $errColor = Get-ThemeValue "prompt.error" 'DarkRed'
        $replacementColorFormatter = Get-ThemeValue "prompt.$replacement.error" "%<fg=$errColor>"
        "$replacementColorFormatter$replacement%<bg=>%<fg=$errColor>$cwd%<fg=>"
    }
    else {
        $successColor = Get-ThemeValue "prompt.success" 'Green'
        $replacementColorFormatter = Get-ThemeValue "prompt.$replacement.success" "%<fg=$successColor>"
        "$replacementColorFormatter$replacement%<bg=>%<fg=$successColor>$cwd%<fg=>"
    }
}

# PUSHD stack level prefix
function Get-StackLevelPromptString {
    param(
        [bool]$err
    )

    $stackCount = (Get-Location -Stack).Count

    if ($stackCount -gt 0) {
        $stackColor = Get-ThemeValue "prompt.stack" 'Yellow'

        $stack = "+" * $stackCount
        if ($stackCount -gt 5) {
            $stack = "+($stackCount)"
        }

        "%<fg=$stackColor>[$stack]%<fg=>"
    }
}

function Get-TerminatorPromptChar {
    param(
        [bool]$err
    )

    git branch >$nul 2>$nul
    if ($?) {
        "±"
    }
    else {
        ">"
    }
}

function prompt {
    # error on previous command?
    $err = !$?

    $batteryLevel = Get-BatteryLevelPromptString($err)
    $debugPrompt = Get-DebugPromptString($err)
    $stackLevel = Get-StackLevelPromptString($err)
    $pathPrompt = Get-PathPromptString($err)
    $gitPrompt = Get-GitPromptString($err)
    $terminatorChar = Get-TerminatorPromptChar($err)

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
