# Show Renamer

A customizable PowerShell script to help bulk rename shows.

## Configuration

| Element | What to Change | Example |
|--------|------|---------|
| `$showName` | Set to the name of the show | `"Naruto" or "Breaking Bad"`
| `$folderPath` | Point to the folder with episode files | `"C:\TV\Naruto"`
| `$episodePattern` | Regex to extract episode number | `'Naruto - (\d{3})'`
| `$seasonMap` | Define episode ranges per season | `{ 1 = @{Start=1; End=20} }`
