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
    if ($Env:DOLT_DIR) {
        Resolve-Path -Path $Env:DOLT_DIR
    }
    elseif (!$pathInfo -or ($pathInfo.Provider.Name -ne 'FileSystem')) {
        $null
    }
    else {
        $currentDir = Get-Item -LiteralPath $pathInfo -Force
        while ($currentDir) {
            $doltDirPath = Join-Path $currentDir.FullName .dolt
            if (Test-Path -LiteralPath $doltDirPath -PathType Container) {
                return $doltDirPath
            }

            $currentDir = $currentDir.Parent
        }
    }
}

function Get-DoltBranch($doltDir, [Diagnostics.Stopwatch]$sw) {
    if (!$doltDir) {
        $doltDir = Get-DoltDirectory
    }

    if (!$doltDir) {
        return
    }

    $pathInfo = Microsoft.PowerShell.Management\Get-Location

    if($pathInfo.Path.StartsWith($doltDir)){
        return 'DOLT_DIR!'
    }

    $branch = dolt branch --show-current 2> $null

    return $branch
}
