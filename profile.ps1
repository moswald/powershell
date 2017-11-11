#
# loading powershell scripts
$profileFolder = Split-Path $MyInvocation.MyCommand.Source

. $profileFolder/Get-ChildItemWithColor.ps1
. $profileFolder/Write-HostWithColor.ps1
. $profileFolder/prompt.ps1
. $profileFolder/Invoke-Sleep.ps1
. $profileFolder/Compare-Commands.ps1
. $profileFolder/Measure-Previous.ps1
. $profileFolder/Get-Solution.ps1
. $profileFolder/Open-Solution.ps1

# load any scripts found in untracked folder "local"
if (Test-Path  $profileFolder/local)
{
    foreach ($script in (Get-ChildItem  $profileFolder/local/*.ps1))
    {
        . $script
    }
}

#
# PowerShell Community eXtensions
Import-Module "C:\Program Files (x86)\PowerShell Community Extensions\Pscx3\Pscx" -arg ~/.ps/.pscx.preferences.ps1

#
# Posh-Git
Import-Module $profileFolder/external/posh-git
Enable-GitColors

#
# PSReadLine
Set-PSReadlineOption -BellStyle None

#
# Azure
Import-Module Azure

#
# removing default aliases that I redefine below
remove-item alias:ls -force
remove-item alias:dir -force
remove-item alias:touch -force
remove-item alias:ise -force

#
# not redefined, but annoying
remove-item alias:sc -force

#
# my own aliases
set-alias l Get-ChildItemWithColor
set-alias ls Get-ChildItemWithColor
set-alias dir Get-ChildItemWithColor
set-alias which Get-Command
set-alias say Out-Speech
set-alias sudo Invoke-Elevated
set-alias psget Install-Module
set-alias reboot Restart-Computer
set-alias shutdown Stop-Computer
set-alias pause Start-Sleep
set-alias ping Test-Connection
set-alias ise Powershell_ISE
set-alias sln Open-Solution
set-alias gsln Get-Solution

# functions unsuitable for aliases
function cd~
{
    Set-LocationEx ~
}

function cd..
{
    Set-LocationEx ..
}

function cd...
{
    Set-LocationEx ...
}

function cd....
{
    Set-LocationEx ....
}

function touch
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$path
    )

    $test = Test-Path $path
    if ($test)
    {
        Set-FileTime $path
    }
    else
    {
        Set-Content -Path $path -Value $null
    }
}

#
# create the theme dictionary
$global:Theme = @{}
