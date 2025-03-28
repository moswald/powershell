Remove-Item ~/documents/WindowsPowerShell/profile.ps1 -ea SilentlyContinue 2>&1 | out-null
Remove-Item ~/documents/PowerShell/profile.ps1 -ea SilentlyContinue 2>&1 | out-null

$profileFolder = Split-Path $MyInvocation.MyCommand.Source
Out-File ~/documents/WindowsPowerShell/profile.ps1 -input ". $profileFolder/profile.ps1"
Out-File ~/documents/PowerShell/profile.ps1 -input ". $profileFolder/profile.ps1"

install-module terminal-icons
Install-Module -Name PowershellHumanizer

. $profileFolder/profile.ps1
