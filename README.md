# Camera Capture

Three different PowerShell approaches to capturing photos from a Windows webcam. Each script solves the same problem a completely different way.

## The Scripts

### `capture.ps1` - The Right Way (WinRT)
Uses the Windows Runtime `MediaCapture` API directly from PowerShell. Loads WinRT assemblies, initializes the camera, captures a JPEG to an in-memory stream, and writes the bytes to a file. Custom `Await` and `AwaitAction` helper functions bridge WinRT's async APIs to synchronous PowerShell execution.

This is the technically correct approach. It's also the most code.

### `snap.ps1` - The Creative Way (UI Automation)
Launches the Windows Camera app via `microsoft.windows.camera:` URI scheme, brings its window to the foreground using `SetForegroundWindow` from user32.dll, and sends an `{ENTER}` keystroke via `SendKeys` to trigger the shutter. Then grabs the latest photo from Camera Roll.

This is the "work smarter not harder" approach.

### `take_photo.ps1` - The Reliable Way (Enhanced UI Automation)
Same strategy as `snap.ps1` but with better error handling, longer waits, and a 2-minute recency window for detecting new photos.

## Why This Exists

These scripts were built to give Pepper (my AI assistant) the ability to see. All three save output to the bot's outputs directory, so Claude can capture and analyze photos as part of task execution.

## Tech

PowerShell, WinRT (Windows.Media.Capture), Win32 API (user32.dll), System.Windows.Forms
