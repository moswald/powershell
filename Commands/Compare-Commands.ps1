function Compare-Commands(
    [parameter(Mandatory = $true)]
    [scriptblock]$a,

    [parameter(Mandatory = $true)]
    [scriptblock]$b,

    [int]$Iterations = 100,
    [int]$DropWorst=5)
{
    $results = @(@(), @())

    for ($i = 0; $i -ne $Iterations; $i += 1)
    {
        $results[0] += (measure-command $a).TotalMilliseconds
        $results[1] += (measure-command $b).TotalMilliseconds
    }

    if ($DropWorst -gt 0 -and $DropWorst -lt $Iterations)
    {
        [Array]::Sort([array]$results[0])
        [Array]::Sort([array]$results[1])

        $results[0] = $results[0][0..($results[0].length - $DropWorst - 1)]
        $results[1] = $results[1][0..($results[1].length - $DropWorst - 1)]
    }

    $results[0] = $results[0] | measure-object -min -max -average
    $results[1] = $results[1] | measure-object -min -max -average

    $format = @{Expression={[System.Math]::Round($_.Average, 4)};Label="Mean";Width=10}, `
        @{Expression={[System.Math]::Round($_.Minimum, 4)};Label="Min";Width=10}, `
        @{Expression={[System.Math]::Round($_.Maximum, 4)};Label="Max";Width=10}, `
        @{Expression={[System.Math]::Round($_.Maximum - $_.Minimum, 4)};Label="Range";Width=10}

    $results | Format-Table $format
}
