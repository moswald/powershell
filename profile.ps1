$PSDefaultParameterValues['*:Encoding'] = 'UTF8'

$global:isPSCore = $PSVersionTable.PSEdition -eq "Core"

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
. $profileFolder/Start-SleepEx.ps1

# load the scripts in the GitHelpers folder
# todo: turn into a plugin
if (Test-Path $profileFolder/GitHelpers) {
    foreach ($script in (Get-ChildItem  $profileFolder/GitHelpers/*.ps1)) {
        . $script
    }
}

#
# PowerShell Community eXtensions
Import-Module Pscx -arg ~/.ps/.pscx.preferences.ps1

#
# Posh-Git
Import-Module $profileFolder/external/posh-git/src/posh-git

#
# PSReadLine
Set-PSReadlineOption -BellStyle None

#
# Azure
if (!$isPSCore) {
    Import-Module Azure
}

#
# Humanizer
Import-Module PowerShellHumanizer

#
# removing default aliases that I redefine below
remove-item alias:ls -force
remove-item alias:dir -force
remove-item alias:touch -force
remove-item alias:sleep -force

#
# not redefined, but annoying
if (!$isPSCore) {
    remove-item alias:sc -force
}

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
set-alias pause Start-SleepEx
set-alias sleep Start-SleepEx
set-alias ping Test-Connection
set-alias sln Open-Solution
set-alias gsln Get-Solution
set-alias nguid New-Guid

# functions unsuitable for aliases
function cd~ {
    Set-LocationEx ~
}

function cd.. {
    Set-LocationEx ..
}

function cd... {
    Set-LocationEx ...
}

function cd.... {
    Set-LocationEx ....
}

function touch {
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$path
    )

    if (Test-Path $path) {
        Set-FileTime $path
    }
    else {
        Set-Content -Path $path -Value $null
    }
}

function ads {
    & 'C:\Users\maoswald\AppData\Local\Programs\Azure Data Studio\bin\azuredatastudio.cmd' $args >$nul 2>$nul
}

function cppath {
    (Get-Location).Path | clip
}

$GitPromptSettings.EnableFileStatus = $false

#
# create the theme dictionary
$global:Theme = @{ }

#
# the prompt will replace any path strings with these pretty names
# initially created with just the user's home path
$global:PromptPathReplacements = @{
    $home.Replace('\', '/') = "~"
}

$global:Projects = @{
    Root = 'd:/m/projects/';
    MS = 'd:/m/projects/MS/';
}

function cd-projects {
    cd $global:Projects['Root']
}

function cd-ms {
    cd $global:Projects['MS']
}

function get-guid {
    [System.Guid]::NewGuid()
}

function cpguid {
    (get-guid).Guid | clip
}

# recursively search the untracked folder "plugins" for install.ps1
if (Test-Path  $profileFolder/plugins) {
    foreach ($script in (Get-ChildItem -Recurse -Include install.ps1 $profileFolder/plugins)) {
        . $script
    }
}
