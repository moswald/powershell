function Start-SleepEx {
    [cmdletbinding(
        DefaultParameterSetName = 'Seconds')]

    param(
        [Parameter(
            HelpMessage = 'Seconds to sleep',
            ParameterSetName = 'Seconds',
            Mandatory = $true,
            Position = 0)]
        [Alias("s")]
        [int]
        $Seconds,
        [Parameter(
            HelpMessage = 'Milliseconds to sleep',
            ParameterSetName = 'Milliseconds')]
        [Alias("ms")]
        [int]
        $Milliseconds,
        [Parameter(
            HelpMessage = 'Minutes to sleep',
            ParameterSetName = 'Minutes')]
        [Alias("min")]
        [int]
        $Minutes
    )

    if ($PSCmdlet.ParameterSetName -eq 'Seconds') {
        $Milliseconds = $Seconds * 1000
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Minutes') {
        $Milliseconds = $Minutes * 60 * 1000
    }

    if ($Milliseconds -ge 10000) {
        $stepPct = 0.05

        $step = [int]($Milliseconds * $stepPct)
        $complete = 0

        while ($Milliseconds -ge $step) {
            Write-Progress -Activity "Sleeping for" -Status "$($Milliseconds / 1000.0) seconds" -PercentComplete $complete
            Start-Sleep -Milliseconds $step

            $Milliseconds = $Milliseconds - $step
            $complete = $complete + $stepPct * 100
        }
    }

    if ($Milliseconds -gt 0) {
        Start-Sleep -Milliseconds $Milliseconds
    }
}
