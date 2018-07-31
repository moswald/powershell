function Get-ProjectRoot {
    if (!(Test-Path env:PROJECT_ROOT)) {
        $response = ''
        while ($response -eq '') {
            $response = Read-Host -Prompt "Please enter your project root folder (one up from your enlistment)"

            if (!(Test-Path $response)) {
                $response = ''
            }
        }

        Set-PathVariable -Name PROJECT_ROOT -Value $response -Target User
        Set-PathVariable -Name PROJECT_ROOT -Value $response -Target Process
    }

    return $env:PROJECT_ROOT
}

function pr {
    $loc = Get-ProjectRoot
    Set-LocationEx $loc
}

function VSO {
    param(
        [ValidateSet('vso', 'vso2', 'vso3')]
        [string]$name = "vso"
    )

    if (!$env:Enlistment) {
        $env:Enlistment = $name

        $loc = Get-ProjectRoot
        Set-LocationEx $loc/$name/src

        ./init.ps1 -KeepPsReadLine
    }
    else {
        if ($env:Enlistment -ne $name) {
            Write-Warning "$env:Enlistment is already initialized. Not initializing other enlistment $name."
        }

        Set-LocationEx $env:BUILDDIR
    }
}

function b2 {
    Set-LocationEx $env:BUILDDIR/tfs/service/build2
}

function b1 {
    Set-LocationEx $env:BUILDDIR/tfs/service/build
}

function dt {
    Set-LocationEx $env:BUILDDIR/distributedtask
}

function wa {
    Set-LocationEx $env:BUILDDIR/tfs/service/webaccess
}

function lrmms {
    Start-Process c:/lr/mms/lightrail.exe
}

function watch {
    param(
        [ValidateSet('tfs', 'distributedtaskwebplatform')]
        [string]$service = 'tfs'
    )

    $loc = Get-ProjectRoot
    Set-LocationEx $loc/Tools.TypeScriptSassQuickDeploy

    $enlistment = $env:Enlistment
    if (!$enlistment) {
        $enlistment = "VSO"
    }

    $path = "$loc/$enlistment"
    if (Test-Path env:BUILDDIR) {
        $path = "$env:BUILDDIR/.."
    }

    gulp --vsoBasePath $path --watchScss --service $service
}

function provisioner {
    param($ForceRestart = $false)

    $provisionerJobName = "Provisioner"

    $job = Get-Job -Name $provisionerJobName -ErrorAction SilentlyContinue

    if ($job) {
        if ($job.State -eq "Running") {
            if ($ForceRestart) {
                Write-Host "Provisioner job is running." -ForegroundColor Yellow
                Receive-Job -Name $provisionerJobName

                Write-Host "Killing Provisioner job" -ForegroundColor Yellow
                Remove-Job -Name $provisionerJobName -Force
            }
            else {
                if ((Get-Job -Name $provisionerJobName).HasMoreData) {
                    Receive-Job -Name $provisionerJobName
                }
                else {
                    Write-Host "Job is running, but has no new output." -ForegroundColor Green
                }

                return
            }
        }
        else {
            Receive-Job -Name $provisionerJobName
            Write-Host "Removing non-running Provisioner job." -ForegroundColor Yellow
            Remove-Job -Name $provisionerJobName
        }
    }

    Start-Job -Name $provisionerJobName { C:\vsts\vsts-provisioner-Windows\provisioner.exe }

    Start-Sleep -Seconds 2

    Receive-Job -Name $provisionerJobName

    if ((Get-Job -Name $provisionerJobName).State -eq "Running") {
        Write-Host "Provisioner job started." -ForegroundColor Green
    }
    else {
        Write-Host "Provisioner job created, but has an error." -ForegroundColor Red
    }
}

function wd {
    param(
        [ValidateSet('tfs', 'tfsonprem')]
        [string]$product = 'tfsonprem'
    )

    webdev $product -l
}

function vpn {
    rasdial msftvpn
}
