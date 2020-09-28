<#
.SYNOPSIS
    Gets the path to the current repository's .dolt dir.
.DESCRIPTION
    Gets the path to the current repository's .dolt dir.  Or if the repository
    is a bare repository, the root directory of the bare repository.
.EXAMPLE
    PS E:\DoltHub\dolthub\corona-virus> Get-DoltDirectory
    Returns E:\DoltHub\dolthub\corona-virus\.dolt
.INPUTS
    None.
.OUTPUTS
    System.String
#>
function Get-DoltDirectory {
    $pathInfo = Microsoft.PowerShell.Management\Get-Location
    if (!$pathInfo -or ($pathInfo.Provider.Name -ne 'FileSystem')) {
        $null
    }
    elseif ($Env:DOLT_DIR) {
        $Env:DOLT_DIR -replace '\\|/', [System.IO.Path]::DirectorySeparatorChar
    }
    else {
        $currentDir = Get-Item -LiteralPath $pathInfo -Force
        while ($currentDir) {
            $doltDirPath = Join-Path $currentDir.FullName .dolt
            if (Test-Path -LiteralPath $doltDirPath -PathType Container) {
                return $doltDirPath
            }

            # Handle the worktree case where .dolt is a file
            if (Test-Path -LiteralPath $doltDirPath -PathType Leaf) {
                $doltDirPath = Invoke-Utf8ConsoleCommand { git rev-parse --git-dir 2>$null }
                if ($doltDirPath) {
                    return $doltDirPath
                }
            }

            $headPath = Join-Path $currentDir.FullName HEAD
            if (Test-Path -LiteralPath $headPath -PathType Leaf) {
                $refsPath = Join-Path $currentDir.FullName refs
                $objsPath = Join-Path $currentDir.FullName objects
                if ((Test-Path -LiteralPath $refsPath -PathType Container) -and
                    (Test-Path -LiteralPath $objsPath -PathType Container)) {

                    $bareDir = Invoke-Utf8ConsoleCommand { git rev-parse --git-dir 2>$null }
                    if ($bareDir -and (Test-Path -LiteralPath $bareDir -PathType Container)) {
                        $resolvedBareDir = (Resolve-Path $bareDir).Path
                        return $resolvedBareDir
                    }
                }
            }

            $currentDir = $currentDir.Parent
        }
    }
}
