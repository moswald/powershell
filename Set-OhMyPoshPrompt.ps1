function Set-PoshMeasurePrevious {
    $env:MEASURE_PREVIOUS = $(Measure-Previous)
}
New-Alias -Name 'Set-PoshContext' -Value 'Set-PoshMeasurePrevious' -Scope Global -Force

oh-my-posh --init --shell pwsh --config ~/.ps/moswald.omp.json | Invoke-Expression;
