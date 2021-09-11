# $Theme["gciwc.Default"]
# $Theme["gciwc.Directory"]
# $Theme["gciwc.Compressed"]
# $Theme["gciwc.Executable"]

function Get-ChildItemWithColor($path = '.') {
    function themeColor($name, $default) {
        if ($null -ne $global:Theme[$name]) {
            return $global:Theme[$name];
        }

        return $default;
    }

    function directory($path) {
        $dirs = @();
        $files = @();

        foreach ($item in get-childitem $path | sort-object -property Name) {
            if ($item.mode -match "d") {
                $dirs += $item;
            }
            else {
                $files += $item;
            }
        }

        write-host(
            @"

   Directory: {0}

Mode                 LastWriteTime     Length Name
----                 -------------     ------ ----
"@ -f (convert-path $path))

        $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase `
                -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
        $compressed = New-Object System.Text.RegularExpressions.Regex(
            '\.(zip|tar|gz|rar)$', $regex_opts)
        $executable = New-Object System.Text.RegularExpressions.Regex(
            '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$', $regex_opts)

        $dirColor = themeColor "gciwc.Directories" 'Cyan';
        $exeColor = themeColor "gciwc.Executables" 'Green';
        $zipColor = themeColor "gciwc.Compressed" 'Yellow';
        $default = themeColor "gciwc.Default" $Host.UI.RawUI.ForegroundColor;

        foreach ($objItem in $dirs) {
            write-host("{0}        {1} {2}{3,11} {4}" -f `
                    $objItem.Mode, `
                    $objItem.LastWriteTime.ToString('yyyy/MM/dd'), `
                    $objItem.LastWriteTime.ToString('hh:mm:ss t'), `
                    "", `
                    $objItem.Name) `
                -foregroundcolor $dirColor
        }

        foreach ($objItem in $files) {
            if ($compressed.IsMatch($objItem.Name)) {
                $fgc = $zipColor
            }
            elseif ($executable.IsMatch($objItem.Name)) {
                $fgc = $exeColor
            }
            else {
                $fgc = $default
            }

            write-host("{0}        {1} {2}{3,11} {4}" -f `
                    $objItem.Mode, `
                    $objItem.LastWriteTime.ToString('yyyy/MM/dd'), `
                    $objItem.LastWriteTime.ToString('hh:mm:ss t'), `
                    $objItem.Length, `
                    $objItem.Name) `
                -foregroundcolor $fgc
        }

        write-host ''
    }

    # not ready for primetime
    #function registry
    #{
    #    param($path)
    #
    #    $item = get-item $path
    #    $children = get-childitem $path
    #
    #    write-host("")
    #    write-host("   Hive: {0}" -f (convert-path $path))
    #    write-host("")
    #    write-host("SKC  VC Name                           Property")
    #    write-host("---  -- ----                           --------")
    #
    #    foreach ($item in $children)
    #    {
    #        write-host("{0} {1} {2} {3}" -f `
    #        $item.SKC, `
    #        $item.VC, `
    #        $item.Name, `
    #        $item.Property) `
    #        -foregroundcolor 'DarkCyan'
    #    }
    #
    #    foreach ($p in $item.Property)
    #    {
    #    write-host $v
    #    }
    #
    #    write-host('')
    #}

    $provider = (Get-ItemProperty $path).PSProvider

    switch ($provider.Name) {
        FileSystem { directory $path; break }
        default { Get-ChildItem $path; break; }
    }
}
