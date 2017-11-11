function prompt
{
    # error on previous command?
    $err = !$?

    # PUSHD stack level prefix
    $stack_level = (Get-Location -Stack).Count

    # current command history id
    $historyId = $MyInvocation.HistoryId

    # if we're somewhere in my home dir, show '~'
    $cwd = $pwd.Path
    if ($cwd.StartsWith($home, 1))
    {
        $cwd = "~" + $cwd.SubString($home.Length)
    }

    # I prefer '/' to '\'
    $cwd = $cwd.Replace('\', '/')

    function battery_level
    {
        $battery = Get-WmiObject -Class Win32_Battery

        if ($battery -ne $nul)
        {
            $charging = $battery.BatteryStatus -eq 2
            $charge = $battery.EstimatedChargeRemaining

            $defaultColors = "Red", "Magenta", "Yellow", "DarkYellow", "DarkCyan", "DarkGreen", "Green"
            $colors = ?? { $Theme["prompt.batteryColors"] } { $defaultColors }

            $chargeColor = $colors[[int]($charge / (100 / $colors.Length)) - 1]
            $chargingColors = ?? { $Theme["prompt.batteryChargingColors"]} { "Yellow", "Green" }
            $glyphColor = $chargingColors[$charging]
            $chargingGlyph = '++'
            if (!$charging)
            {
                $chargingGlyph = '--'
            }

            "[%<fg=$chargeColor>$charge%<fg=$glyphColor>$chargingGlyph%<fg=>] "
        }
    }

    function prompt_char {
        git branch >$nul 2>$nul
        if ($?) {
            Write-Output '±'
            return
        }

        Write-Output '>'
    }

    function git_prompt
    {
        $realLASTEXITCODE = $LASTEXITCODE
        Write-VcsStatus 2> $nul
        $global:LASTEXITCODE = $realLASTEXITCODE
    }

    #
    # begin output
    #

    $historyIdColor = ?? { $Theme["prompt.historyId"] } { 'DarkCyan' }
    Write-HostWithColor "
$(battery_level)%<fg=$historyIdColor>#$([Math]::Abs($historyId))%<fg=> " -NoNewline

    # [+] stack level
    if ($stack_level -gt 0)
    {
        $stackColor = ?? { $Theme["prompt.stack"] } { 'Yellow' }

        $stack = "+" * (Get-Location -Stack).count
        Write-Host "[$stack]" -NoNewline -Fore $stackColor
    }

    # path
    $max_len = ?? { $Theme["prompt.MaxLen"] } { 50 }
    if ($cwd.length -ge $max_len)
    {
        if ($cwd.StartsWith('~'))
        {
            $cwd = "~/..." + $cwd.substring($cwd.length - $max_len + 4)
        }
        else
        {
            $strDrive = $PWD.Drive.name
            $cwd = $strDrive + ":/..." + $cwd.substring($cwd.length - $max_len + 4)
        }
    }

    if (! $cwd.EndsWith('/'))
    {
        $cwd = $cwd + '/'
    }

    if ($err)
    {
        $errColor = ?? { $Theme["prompt.error"] } { 'DarkRed' }
        Write-Host -NoNewLine $cwd -Fore $errColor
    }
    else
    {
        $successColor = ?? { $Theme["prompt.success"] } { 'Green' }
        Write-Host -NoNewLine $cwd -Fore $successColor
    }

    Write-HostWithColor -NoNewLine "$(git_prompt)`n$(prompt_char)".Replace("%<nl>", "`n").Replace("%<a>", "→")

    return " "
}
