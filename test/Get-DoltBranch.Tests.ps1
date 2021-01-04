BeforeAll {
    . $PSScriptRoot\Shared.ps1
}

Describe 'Get-DoltBranch Tests' {
    Context 'Get-DoltBranch DOLT_DIR Tests' {
        It 'Returns branch name' {
            $repoRoot = (Resolve-Path $env:PoshDoltTestRepository).Path
            Set-Location $repoRoot -ErrorAction Break
            InModuleScope posh-dolt {
                Get-DoltBranch | Should -BeExactly 'master'
            }
        }

        It 'Returns DOLT_DIR! when in .dolt dir of the repo' {
            $repoRoot = (Resolve-Path $env:PoshDoltTestRepository).Path
            Set-Location $repoRoot\.dolt -ErrorAction Break
            InModuleScope posh-dolt {
                Get-DoltBranch | Should -BeExactly 'DOLT_DIR!'
            }
        }
        It 'Returns correct path when in a child folder of the .dolt dir of the repo' {
            $repoRoot = (Resolve-Path $env:PoshDoltTestRepository).Path
            Set-Location $repoRoot\.dolt\noms -ErrorAction Break
            InModuleScope posh-dolt {
                Get-DoltBranch | Should -BeExactly 'DOLT_DIR!'
            }
        }
    }
}
