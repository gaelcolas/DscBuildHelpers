function Assert-Directory {
    [cmdletbinding()]
    param (
        $Path
    )

    try {
        if (-not (Test-Path $path -ea Stop)) {
            $null = mkdir @psboundparameters
        }
    }
    catch {
        Write-Warning "Failed to validate $path"
        throw $_.Exception
    }
}


