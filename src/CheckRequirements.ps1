$Global:DoltMissing = $false

$requiredVersion = [Version]'0.18.3'
$script:DoltVersion = $requiredVersion

if (!(Get-Command dolt -TotalCount 1 -ErrorAction SilentlyContinue)) {
    Write-Warning "dolt command could not be found. Please create an alias or add it to your PATH."
    $Global:DoltMissing = $true
    return
}

if ([string](dolt version 2> $null) -match '(?<ver>\d+(?:\.\d+)+)') {
    $script:DoltVersion = [System.Version]$Matches['ver']
}

if ($script:DoltVersion -lt $requiredVersion) {
    Write-Warning "posh-dolt requires Dolt $requiredVersion or better. You have $GitVersion."
    $false
}
else {
    $true
}
