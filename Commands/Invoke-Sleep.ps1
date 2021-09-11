function Invoke-Sleep
{
    Add-Type -Assembly System.Windows.Forms
    [System.Windows.Forms.Application]::SetSuspendState(0, 0, 0)
}
