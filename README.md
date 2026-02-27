# camera-capture

I needed my AI assistant to see. Not metaphorically -- literally take a photo through the webcam so it could look at something I was pointing at. Sounds simple until you try doing it from PowerShell on Windows.

So I built it three times.

**capture.ps1** goes straight for the throat: loads WinRT assemblies, initializes `MediaCapture`, writes a JPEG to an in-memory `InMemoryRandomAccessStream`. WinRT's async model doesn't play nice with synchronous PowerShell, so there's a pair of `Await`/`AwaitAction` helpers that bridge that gap manually. This is the "correct" approach, and it's about as pleasant as you'd expect correct-on-Windows to be.

**snap.ps1** takes a completely different philosophy. It launches the Camera app via `microsoft.windows.camera:`, yanks the window to the foreground with `user32.dll SetForegroundWindow`, then literally sends an Enter keystroke through `SendKeys` to press the shutter button. Then it grabs the newest file from Camera Roll.

**take_photo.ps1** is snap.ps1 grown up -- better error handling, a 2-minute recency check to make sure you're actually getting a fresh photo and not last Tuesday's accidental selfie.

Three scripts, three philosophies: the right way, the creative way, the reliable way.
