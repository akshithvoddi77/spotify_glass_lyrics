# Lyrics Glass

A floating lyrics window for Spotify on Windows. It looks like oil on frosted glass: translucent, blurred, glowing, and animated. It's a [Spicetify](https://spicetify.app) extension, and one PowerShell command installs it.

## Features

- **Glass window.** Heavy backdrop blur, a soft rim highlight, and a slowly rotating rainbow film like an oil slick. Only the lyrics window gets this look; the rest of Spotify is unchanged.
- **Glow that follows the song.** The active line glows in colors taken from the album art, so every track looks different.
- **Synced and animated.** The current line scales up and fills with light as it's sung. Nearby lines fade and blur by distance, and the list scrolls smoothly to keep the active line centered.
- **Click to seek.** Click any line to jump to that moment.
- **Movable and resizable.** Drag the header to move it and drag the bottom-right corner to resize. Position and size are remembered.
- **Reliable lyrics.** It uses Spotify's own lyrics first and falls back to [LRCLIB](https://lrclib.net) if Spotify has none. Unsynced lyrics show as a plain scrolling list.
- **Reduced motion.** Respects your system's "reduce motion" setting.

## Requirements

- Windows 10 or 11
- The regular Spotify desktop app from [spotify.com](https://www.spotify.com/download). The Microsoft Store version doesn't work with Spicetify.
- PowerShell (already included with Windows)

## Install

Paste this into PowerShell, replacing `YOUR_USER` with the GitHub account that hosts this repo:

```powershell
iwr -useb https://raw.githubusercontent.com/YOUR_USER/spotify_glass_lyrics/main/install-lyrics-glass.ps1 | iex
```

The installer will:

1. Install the Spicetify CLI if it isn't already installed.
2. Save the extension to `%APPDATA%\spicetify\Extensions\lyrics-glass.js`.
3. Enable it and apply it to Spotify.

Spotify restarts when the install finishes.

### Install from a downloaded file

If you downloaded `install-lyrics-glass.ps1` instead, run it with its full path:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\install-lyrics-glass.ps1"
```

## Usage

| Action | How |
| --- | --- |
| Open or close the lyrics window | Click the music-note button in Spotify's top bar, or press **Alt+L** |
| Move the window | Drag its header |
| Resize the window | Drag the bottom-right corner |
| Jump to a part of the song | Click a lyric line |

## Update

After a Spotify update, the extension can disappear. Bring it back with:

```powershell
spicetify apply
```

To update Lyrics Glass itself, run the install command again.

## Uninstall

```powershell
spicetify config extensions lyrics-glass.js-
spicetify apply
```

To remove Spicetify entirely, run `spicetify restore` first, then delete `%APPDATA%\spicetify` and `%LOCALAPPDATA%\spicetify`.

## Troubleshooting

**"The argument ... to the -File parameter does not exist"**
PowerShell can't find the file in its current folder. Use the full path to the file, or use the `iwr ... | iex` command above.

**"spicetify is not recognized"**
Close PowerShell, open a new window, and run the installer again so the updated PATH is picked up.

**No top-bar button after install**
Fully quit Spotify (check the system tray), reopen it, and run `spicetify apply`. If the button is still missing, run `spicetify update` to get the latest Spicetify and try again.

**"No lyrics found for this track"**
Neither Spotify nor LRCLIB has lyrics for that song. Instrumentals and very new releases often have none.

**Lyrics are slightly early or late**
Synced lyrics come from third-party timing data, so small offsets can happen on some tracks.

**The installer errors on a security setting**
Run it with `-ExecutionPolicy Bypass` as shown in the local-file install above.

## How it works

- Lyrics come from Spotify's internal lyrics service, with LRCLIB as a fallback.
- Colors come from the album art through Spicetify's color extractor.
- The glass effect uses CSS `backdrop-filter`, layered gradients, and blend modes. It blurs what's behind the window inside Spotify; it can't blur your desktop, because Spotify's window isn't transparent at the operating-system level.

## Files

| File | Purpose |
| --- | --- |
| `lyrics-glass.js` | The extension source. Readable and easy to edit. |
| `install-lyrics-glass.ps1` | The one-step installer. It contains an encoded copy of `lyrics-glass.js`. |

### Customizing

Colors, blur strength, glow size, font size, and window size are all in the CSS block at the top of `lyrics-glass.js`. After editing, copy the file to `%APPDATA%\spicetify\Extensions\` and run `spicetify apply`.

If you change `lyrics-glass.js` and want the installer to match, regenerate the encoded copy inside `install-lyrics-glass.ps1`.

## Notes

This project isn't affiliated with or endorsed by Spotify. It relies on Spotify's internal lyrics service, which Spotify can change at any time; the LRCLIB fallback keeps lyrics working if that happens. Modifying the Spotify client may go against Spotify's terms of service, so use it at your own discretion.

## Credits

- [Spicetify](https://github.com/spicetify) for making Spotify extensions possible
- [LRCLIB](https://lrclib.net) for free synced lyrics
