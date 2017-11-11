param([int]$version)

$comntools = 'invalid'
$title = "invalid"

if ($version -eq 90)
{
    $comntools = (Get-ChildItem env:VS90COMNTOOLS).Value
    $title = "Visual Studio 2008 Windows Powershell"
}
elseif ($version -eq 100)
{
    $comntools = (Get-ChildItem env:VS100COMNTOOLS).Value
    $title = "Visual Studio 2010 Windows Powershell"
}
elseif ($version -eq 110)
{
    $comntools = (Get-ChildItem env:VS110COMNTOOLS).Value
    $title = "Visual Studio 2012 Windows Powershell"
}
elseif ($version -eq 120)
{
    $comntools = (Get-ChildItem env:VS120COMNTOOLS).Value
    $title = "Visual Studio 2013 Windows Powershell"
}
elseif ($version -eq 140)
{
    $comntools = (Get-ChildItem env:VS140COMNTOOLS).Value
    $title = "Visual Studio 2015 Windows Powershell"
}

if ($comntools -eq 'invalid')
{
    write-host("{0}", "Usage: VsVars32 <value>`nWhere <value> is one of: 90, 100, 110, 120, 140.");
    return -1
}

$batchFile = [System.IO.Path]::Combine($comntools, "vsvars32.bat")

$cmd = "`"$batchFile`" & set"
foreach ($item in (cmd /c $cmd))
{
    $p, $v = $item.split('=')
    Set-Item -path env:$p -value $v
}

[System.Console]::Title = $title
