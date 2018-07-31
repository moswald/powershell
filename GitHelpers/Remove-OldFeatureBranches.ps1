function Get-BranchName($branchLine) {
    ($branchLine | Split-String -RemoveEmptyStrings)[0]
}

function Remove-OldFeatureBranches {
    foreach ($branch in (git branch -vv | Select-String gone)) {
        #git branch -D ($branch | Split-String -RemoveEmptyStrings)[0]
        git branch -D (Get-BranchName $branch)
    }
}

function Remove-AllUntracked {
    Write-Output "Removing old feature branches."
    Remove-OldFeatureBranches

    Write-Output "Removing untracked local branches."
    foreach ($branch in (git branch -vv | Select-String \[origin/ -NotMatch)) {
        Write-Output "`nRemoving branch: $branch"
        $response = Read-Host "`nThis is permanent!`nEnter the name of the branch to continue"

        $branchName = Get-BranchName $branch
        if ($response -ceq $branchName) {
            git branch -D $branchName
        }
    }
}
