Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === GUI SETUP ===
$form = New-Object Windows.Forms.Form
$form.Text = "Episode Renamer"
$form.Size = '600,600'
$form.StartPosition = "CenterScreen"

# === Controls ===

# Folder Picker
$folderLabel = New-Object Windows.Forms.Label
$folderLabel.Text = "Folder:"
$folderLabel.Location = '10,20'
$folderLabel.Size = '80,20'
$form.Controls.Add($folderLabel)

$folderBox = New-Object Windows.Forms.TextBox
$folderBox.Size = '400,20'
$folderBox.Location = '100,20'
$form.Controls.Add($folderBox)

$browseButton = New-Object Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Location = '510,20'
$browseButton.Size = '60,20'
$browseButton.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $folderBox.Text = $dialog.SelectedPath
    }
})
$form.Controls.Add($browseButton)

# Show Name
$showLabel = New-Object Windows.Forms.Label
$showLabel.Text = "Show Name:"
$showLabel.Location = '10,60'
$form.Controls.Add($showLabel)

$showBox = New-Object Windows.Forms.TextBox
$showBox.Size = '400,20'
$showBox.Location = '100,60'
$form.Controls.Add($showBox)

# Regex Pattern
$regexLabel = New-Object Windows.Forms.Label
$regexLabel.Text = "Episode Regex:"
$regexLabel.Location = '10,100'
$form.Controls.Add($regexLabel)

$regexBox = New-Object Windows.Forms.TextBox
$regexBox.Size = '400,20'
$regexBox.Location = '100,100'
$regexBox.Text = '\[.*?\] .*? - (\d{1,4})'
$form.Controls.Add($regexBox)

# Season Mapping
$seasonLabel = New-Object Windows.Forms.Label
$seasonLabel.Text = "Season Map:"
$seasonLabel.Location = '10,140'
$form.Controls.Add($seasonLabel)

$seasonBox = New-Object Windows.Forms.TextBox
$seasonBox.Multiline = $true
$seasonBox.ScrollBars = "Vertical"
$seasonBox.Size = '560,100'
$seasonBox.Location = '10,160'
$seasonBox.Text = @"
@{
    1 = @{Start = 1; End = 62}
    2 = @{Start = 63; End = 77}
    3 = @{Start = 78; End = 91}
}
"@
$form.Controls.Add($seasonBox)

# Dry Run Checkbox
$dryRunBox = New-Object Windows.Forms.CheckBox
$dryRunBox.Text = "Dry Run (Preview Only)"
$dryRunBox.Location = '10,270'
$dryRunBox.Checked = $true
$form.Controls.Add($dryRunBox)

# Run Button
$runButton = New-Object Windows.Forms.Button
$runButton.Text = "Run Rename"
$runButton.Location = '250,270'
$form.Controls.Add($runButton)

# Log Output
$logBox = New-Object Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.Size = '560,250'
$logBox.Location = '10,310'
$form.Controls.Add($logBox)

# === Rename Logic ===
$runButton.Add_Click({
    $folderPath = $folderBox.Text
    $showName = $showBox.Text
    $regexPattern = $regexBox.Text
    $dryRun = $dryRunBox.Checked

    try {
        $seasonMap = Invoke-Expression $seasonBox.Text
    } catch {
        $logBox.AppendText("ERROR: Invalid season map format.`r`n")
        return
    }

    $renamePlan = @()
    $logBox.Clear()

    Get-ChildItem -Path $folderPath -Filter *.mkv -File | ForEach-Object {
        $file = $_
        $originalName = $file.Name

        if ($originalName -match $regexPattern) {
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
            $logBox.AppendText("Skipped: '$originalName' (no episode number found)`r`n")
        }
    }

    foreach ($item in $renamePlan) {
        $logBox.AppendText("SOURCE: $($item.OriginalPath)`r`nDEST:   $($item.NewName)`r`n")

        if ($dryRun) {
            $logBox.AppendText("Preview: '$($item.OriginalName)' → '$($item.NewName)'`r`n`r`n")
        } else {
            try {
                Rename-Item -LiteralPath $item.OriginalPath -NewName $item.NewName -Force
                $logBox.AppendText("Renamed: '$($item.OriginalName)' → '$($item.NewName)'`r`n`r`n")
            } catch {
                $logBox.AppendText("ERROR renaming '$($item.OriginalName)': $_`r`n`r`n")
            }
        }
    }

    $logBox.AppendText("Done.`r`n")
})

$form.ShowDialog()