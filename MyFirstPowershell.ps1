function Show-FileTable {
    param (
        [Parameter(Mandatory)] $Path
    )

    Get-Childitem $Path | Format-Table Name, Length
}

function Write-LargeFiles {
    param (
        [Parameter(Mandatory)] $Path,
        [Parameter(Mandatory)] $OutputFile
    )

    Get-Childitem $Path | Where-Object Length -ge 10240 | Sort-Object Length > $OutputFile
}

function Show-Time {
    Get-Date -Format "HH:mm:ss"
}

function Get-ByteSize {
    param (
        [Parameter(Mandatory)] $Bytes
    )

    # B
    if ($Bytes -lt 1024) {
        $Bytes.ToString("F") + " B"
    }

    # KB
    elseif ($Bytes -lt (1024 * 1024)) {
        ($Bytes / 1024).ToString("F") + " KB"
    }

    # MB
    elseif ($Bytes -lt (1024 * 1024 * 1024)) {
        ($Bytes / 1024 / 1024).ToString("F") + " MB"
    }

    # GB
    elseif ($Bytes -lt (1024 * 1024 * 1024 * 1024)) {
        ($Bytes / 1024 / 1024 / 1024).ToString("F") + " GB"
    }
}

function Get-Factorial {
    param (
        [Parameter(Mandatory)] $n
    )

    $result = 1

    for ($i = 2; $i -le $n; $i++) {
        $result *= $i
    }

    $result
}

#Show-FileTable "C:\Users\User"
#Write-LargeFiles "C:\Users\User" "result.txt"
#Show-Time
#Get-ByteSize 1025
#Get-ByteSize 1500000
Get-Factorial 5