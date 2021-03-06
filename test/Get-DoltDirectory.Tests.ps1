BeforeAll {
    . $PSScriptRoot\Shared.ps1
}

Describe 'Get-DoltDirectory Tests' {
    Context "Test normal repository" {
        BeforeAll {
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
            $origPath = Get-Location
        }
        AfterAll {
            Set-Location $origPath
        }

        It 'Returns $null for not a Dolt repo' {
            $modulePath | Should -Not -BeNullOrEmpty
            Set-Location $modulePath
            Get-DoltDirectory | Should -BeNullOrEmpty
        }
        It 'Returns $null for not a filesystem path' {
            Set-Location Alias:\
            Get-DoltDirectory | Should -BeNullOrEmpty
        }
        It 'Returns correct path when in the root of repo' {
            $repoRoot = (Resolve-Path $env:PoshDoltTestRepository).Path
            Set-Location $repoRoot
            Get-DoltDirectory | Should -BeExactly (MakeNativePath $repoRoot\.dolt)
        }
    }

    Context 'Test bare repository' {
        BeforeAll {
            [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
            $origPath = Get-Location
            $temp = [System.IO.Path]::GetTempPath()
            $bareRepoName = "test.dolt"
            $bareRepoPath = Join-Path $temp $bareRepoName
            if (Test-Path $bareRepoPath) {
                Remove-Item $bareRepoPath -Recurse -Force
            }
            New-Item $bareRepoPath -ItemType Directory | Out-Null
            Push-Location
            Set-Location $bareRepoPath
            &$doltbin init --name "Pester User" --email "you@example.com"
            Pop-Location

            Remove-Item Env:\DOLT_DIR -ErrorAction SilentlyContinue
        }
        AfterAll {
            Set-Location $origPath
            if (Test-Path $bareRepoPath) {
                Remove-Item $bareRepoPath -Recurse -Force
            }
        }

        It 'Returns correct path when in the root of bare repo' {
            Set-Location $bareRepoPath -ErrorAction Break
            $expectedPath = Join-Path -Path $bareRepoPath -ChildPath '.dolt'
            Get-DoltDirectory | Should -BeExactly $expectedPath
        }

        It 'Returns correct path when in the .dolt of bare repo' {
            Set-Location (Join-Path -Path $bareRepoPath -ChildPath '.dolt') -ErrorAction Break
            $expectedPath = Join-Path -Path $bareRepoPath -ChildPath '.dolt'
            Get-DoltDirectory | Should -BeExactly $expectedPath
        }

        It 'Returns correct path when in the .dolt/noms of bare repo' {
            Set-Location (Join-Path -Path $bareRepoPath -ChildPath '.dolt/noms') -ErrorAction Break
            $expectedPath = Join-Path -Path $bareRepoPath -ChildPath '.dolt'
            Get-DoltDirectory | Should -BeExactly $expectedPath
        }
    }

    Context "Test DOLT_DIR environment variable" {
        AfterAll {
            Remove-Item Env:\DOLT_DIR -ErrorAction SilentlyContinue
        }
        It 'Returns the value in DOLT_DIR env var' {
            $tempPath = [System.IO.Path]::GetTempPath()
            $repoName = "xyzzy/posh-dolt/"
            $repoPath = Join-Path $tempPath $repoName
            if (Test-Path $repoPath) {
                Remove-Item $repoPath -Recurse -Force
            }
            New-Item $repoPath -ItemType Directory | Out-Null
            $Env:DOLT_DIR = $repoPath
            Get-DoltDirectory | Should -BeExactly $Env:DOLT_DIR
        }
    }
}
