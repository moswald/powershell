$PSDefaultParameterValues['*:Encoding'] = 'UTF8'

$global:isPSCore = $PSVersionTable.PSEdition -eq "Core"
$profileFolder = Split-Path $MyInvocation.MyCommand.Source

#
##
## Modules
##
#
if (!$isPSCore) {
    # PowerShell Community eXtensions don't work in the PSCore version
    Import-Module Pscx -arg ~/.ps/.pscx.preferences.ps1
}

Import-Module Posh-Git
Import-Module PowerShellHumanizer

if ($isPSCore) {
    Import-Module Terminal-Icons # usually must go last or gets clobbered 🤷‍♂️
}

#
##
## Custom commands
##
#
. $profileFolder/Commands/Write-HostWithColor.ps1
. $profileFolder/Commands/Invoke-Sleep.ps1
. $profileFolder/Commands/Compare-Commands.ps1
. $profileFolder/Commands/Measure-Previous.ps1
. $profileFolder/Commands/Get-Solution.ps1
. $profileFolder/Commands/Open-Solution.ps1
. $profileFolder/Commands/Start-SleepEx.ps1

if (!$isPSCore) {
    # PSCore has a better solution for this with module Terminal-Icons
    . $profileFolder/Commands/Get-ChildItemWithColor.ps1
}

#
##
## Prompt
##
#
if ($isPSCore) {
    . $profileFolder/Set-OhMyPoshPrompt.ps1
}
else {
    . $profileFolder/prompt.ps1
}

#
##
## Configuration
##
#

. $profileFolder/Configure-PSReadLine.ps1

$global:Projects = @{
    Root = 'd:/m/projects/';
}

# removing default aliases that I redefine below
remove-item alias:ls -force
remove-item alias:dir -force
remove-item alias:sleep -force
remove-item alias:touch -force 2> $null

# not redefined, but annoying
remove-item alias:sc -force 2> $null
remove-item alias:sp -force

# my own aliases
if (!$isPSCore) {
    set-alias l Get-ChildItemWithColor
    set-alias ls Get-ChildItemWithColor
    set-alias dir Get-ChildItemWithColor
}
else {
    set-alias l Get-ChildItem
    set-alias ls Get-ChildItem
    set-alias dir Get-ChildItem
}

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
    Set-Location ~
}

function cd.. {
    Set-Location ..
}

function cd... {
    Set-Location ...
}

function cd.... {
    Set-Location ....
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
    azuredatastudio $args >$nul 2>$nul
}

function cppath {
    (Get-Location).Path | clip
}

function cpguid {
    (New-Guid).Guid | clip
}

function cd-projects {
    Set-Location $global:Projects['Root']
}

#
##
## argument completers
##
#

# dotnet
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

#
##
## Theme support
##
#
$global:Theme = @{ }

function Get-ThemeValue {
    param(
        $themeKey,
        $defaultValue
    )

    if ($null -ne $global:Theme[$themeKey]) {
        $global:Theme[$themeKey];
    }

    $defaultValue;
}

#
##
## plugins
##
#

# recursively search the untracked folder "plugins" for install.ps1
if (Test-Path  $profileFolder/plugins) {
    foreach ($script in (Get-ChildItem -Recurse -Include install.ps1 $profileFolder/plugins)) {
        . $script
    }
}
