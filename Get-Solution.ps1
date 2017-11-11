function Get-Solution
{
    $slnFile = (split-path -Leaf (Get-Location)) + ".sln"

    if (!(Test-Path $slnFile))
    {
        # default guess didn't work, is there just one solution in the folder?

        # note, we have to do it this way because gci will return a single FileInfo or an array, but not an array of one
        $files = @()
        $files += Get-ChildItem *.sln

        if ($files.Length -eq 1)
        {
            $slnFile = $files[0]
        }
        else
        {
            throw "Could not find default solution file, or more than one solution file found in folder."
        }
    }

    return $slnFile
}
