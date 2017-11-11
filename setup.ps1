Remove-Item ~/documents/WindowsPowerShell/profile.ps1 -ea SilentlyContinue 2>&1 | out-null

Out-File ~/documents/WindowsPowerShell/profile.ps1 -input ". ~/.ps/profile.ps1"

. ./profile.ps1
