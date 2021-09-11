Function Measure-Previous {
    param(
        [Parameter(ValueFromPipeLine = $true)]
        $id = ($MyInvocation.HistoryId - 1)
    )

    if ($id -gt 0) {
        <# .Synopsis Returns the time taken to run a command
        .Description By default returns the time taken to run the last command
        .Parameter ID The history ID of an earlier item.
        #>
        foreach ($i in $id) {
            $histInfo = (get-history $i)
            $histInfo.EndExecutionTime.Subtract($histInfo.StartExecutionTime).Humanize(3)
        }
    }
}
