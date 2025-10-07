# === CONFIGURATION ===

# Toggle dry run mode: $true = preview only, $false = actually rename
$dryRun = $true

# Show name (used in output filename)
$showName = "One Piece"

# Folder containing your files
$folderPath = "D:\TempMediaDownloads\OnePiece"

# Regex pattern to extract episode number (customize per show)
# Example: "[Group] Show Name - 123 [720p]..." → captures 123
$episodePattern = '\[.*?\] .*? - (\d{1,4})'

# Season mapping: episode ranges per season
# Customize this per show
$seasonMap = @{
    1 = @{Start = 1; End = 62}
    2 = @{Start = 63; End = 77}
    3 = @{Start = 78; End = 91}
    # Add more seasons as needed
}

# === SCRIPT LOGIC ===

# Log file
$logFile = Join-Path $folderPath "RenameLog.txt"
if (Test-Path $logFile) { Remove-Item $logFile }

# Build rename plan
$renamePlan = @()

Get-ChildItem -Path $folderPath -Filter *.mkv -File | ForEach-Object {
    $file = $_
    $originalName = $file.Name

    if ($originalName -match $episodePattern) {
        $episodeNum = [int]$matches[1]

        foreach ($season in $seasonMap.Keys) {
            $range = $seasonMap[$season]
            if ($episodeNum -ge $range.Start -and $episodeNum -le $range.End) {
                $episodeInSeason = $episodeNum - $range.Start + 1
                $newName = "$showName - S{0:D2}E{1:D2}.mkv" -f $season, $episodeInSeason
                $renamePlan += [PSCustomObject]@{
                    OriginalPath = $file.FullName
                    OriginalName = $originalName
                    NewName = $newName
                }
                break
            }
        }
    } else {
        $logEntry = "Skipped: '$originalName' (no episode number found)"
        Write-Host $logEntry
        Add-Content -Path $logFile -Value $logEntry
    }
}

# Apply rename plan
foreach ($item in $renamePlan) {
    $logEntry = @"
SOURCE: $($item.OriginalPath)
DEST:   $($item.NewName)
"@

    if ($dryRun) {
        $logEntry += "Preview: '$($item.OriginalName)' → '$($item.NewName)'"
    } else {
        try {
            Rename-Item -LiteralPath $item.OriginalPath -NewName $item.NewName -Force
            $logEntry += "Renamed: '$($item.OriginalName)' → '$($item.NewName)'"
        } catch {
            $logEntry += "ERROR renaming '$($item.OriginalName)': $_"
        }
    }

    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}