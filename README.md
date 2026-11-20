# Lyrics Glass
<img width="800" height="449" alt="Eminem-Stan2026-11-2102-38-32-ezgif com-optimize" src="https://github.com/user-attachments/assets/141e1321-07e1-4164-9aa9-bf5c66fdcd73" />

A floating, oil-on-glass lyrics window for Spotify via **Spicetify**, featuring glowing, animated, time-synced lyrics and dynamic album art colors.

## Features
- **Oil-on-Glass UI:** Translucent frosted glass window with animated iridescent sheen and ambient color blobs.
- **Dynamic Album Colors:** Automatically extracts colors from the currently playing track's album art.
- **Time-Synced Lyrics:** Smoothly scrolls and highlights active lines in real time (powered by Spotify and LRCLIB). Click any line to seek to that timestamp.
- **Draggable & Resizable:** Drag the header to move the window anywhere, drag the bottom-right corner to resize, and your layout is saved automatically.

## Installation (Windows)

### Option 1: One-Line PowerShell Install (Recommended)
Open **PowerShell** and run:
```powershell
irm https://github.com/akshithvoddi77/spotify_glass_lyrics/main/install-lyrics-glass.ps1 | iex

```
*(This automatically installs Spicetify if needed, copies `lyrics-glass.js` to your Extensions folder, and applies it to Spotify.)*

### Option 2: Local Installer Script
1. Download `install-lyrics-glass.ps1` from this repository.
2. Open PowerShell and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "\$env:USERPROFILE\Downloads\install-lyrics-glass.ps1"
   ```

### Option 3: Manual Install (Windows / macOS / Linux)
1. Download `lyrics-glass.js` and place it inside your Spicetify `Extensions` folder:
   - **Windows:** `%appdata%\spicetify\Extensions\`
   - **macOS / Linux:** `~/.config/spicetify/Extensions/`
2. Run the following commands in your terminal:
   ```bash
   spicetify config extensions lyrics-glass.js
   spicetify apply
   ```

## Usage
- **Toggle Window:** Click the **music-note icon** in Spotify's top bar, or press **`Alt + L`**.
- **Move:** Click and drag the top header bar.
- **Resize:** Drag the bottom-right corner of the window.
- **Seek:** Click on any synced lyric line to jump to that part of the song.
