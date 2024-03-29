function Write-HostWithColor {
    param(
        [string]
        $line,

        [switch]
        $NoNewline)

    function MyWriteHost {
        param($NoNewline, [string]$line, $fore, $back)

        if ($fore -eq "") {
            $fore = $null;
        }

        if ($back -eq "") {
            $back = $null;
        }

        if ($NoNewline) {
            if ($null -ne $fore -and $null -ne $back) {
                Write-Host $line -NoNewline -Fore $fore -Back $back
            }
            elseif ($null -ne $fore) {
                Write-Host $line -NoNewline -Fore $fore
            }
            elseif ($null -ne $back) {
                Write-Host $line -NoNewline -Back $back
            }
            else {
                Write-Host $line -NoNewline
            }
        }
        else {
            if ($null -ne $fore -and $null -ne $back) {
                Write-Host $line -Fore $fore -Back $back
            }
            elseif ($null -ne $fore) {
                Write-Host $line -Fore $fore
            }
            elseif ($null -ne $back) {
                Write-Host $line -Back $back
            }
            else {
                Write-Host $line
            }
        }
    }

    if ($line.Length -eq 0) {
        MyWriteHost $NoNewline "" $null $null
    }

    # need to find %<fg=<color>> or %<bg=<color>> or %<c=<color>,<color>>
    $split = 0
    $fg = $null
    $bg = $null
    for (; ; ) {
        $split = $line.IndexOf("%<", $split)

        # no format code found, just write the rest of the string
        if ($split -eq -1) {
            MyWriteHost $NoNewline $line $fg $bg
            break
        }

        # have to make sure %%( parses correctly as NOT a format code
        if ($split -ne 0) {
            if ($line.Chars($split - 1) -eq '%') {
                continue
            }
        }

        $sub = $line.Substring(0, $split)

        if ($sub.Length -ne 0) {
            MyWriteHost $true $sub $fg $bg
        }

        $line = $line.Substring($split)

        $code = $line.Chars(2)
        $end = $line.IndexOf('>')
        if ($code -eq 'f') {
            $fg = $line.Substring(5, $end - 5)
        }
        elseif ($code -eq 'b') {
            $bg = $line.Substring(5, $end - 5)
        }
        elseif ($code -eq 'c') {
            $comma = $line.IndexOf(',')
            $fg = $line.Substring(4, $comma - 4)
            $bg = $line.Substring($comma + 1, $end - ($comma + 1))
        }

        $line = $line.Substring($end + 1)
        $split = 0
    }
}
