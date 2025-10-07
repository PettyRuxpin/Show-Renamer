# Show Renamer Script

A customizable PowerShell script to help bulk rename shows.

## Configuration

| Element | What to Change | Example |
|--------|------|---------|
| `$showName` | Set to the name of the show | `"Naruto" or "Breaking Bad"`
| `$folderPath` | Point to the folder with episode files | `"C:\TV\Naruto"`
| `$episodePattern` | Regex to extract episode number | `'Naruto - (\d{3})'`
| `$seasonMap` | Define episode ranges per season | `{ 1 = @{Start=1; End=20} }` 

# Show Renamer GUI

A rough GUI if you don't want to use the script.

🧠 How to Use It
- Paste your episode folder path or use Browse
- Enter the show name (e.g., Naruto)
- Paste or tweak the regex pattern to match filenames
- Paste season mapping as PowerShell code
- Toggle dry run or live rename
- Click Run Rename and watch the log update

DISCLAIMER:
This code has been tested to work in my environment, but can't be guaranteed to work in yours. Use at your own risk.
