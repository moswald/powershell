function Open-Solution(
    [string]$slnFile = ""
)
{
    if ($slnFile -eq "")
    {
        $slnFile = Get-Solution
    }

    if (!$slnFile.EndsWith(".sln"))
    {
        $slnFile = $slnFile + ".sln";
    }

    Start-Process $slnFile
}
