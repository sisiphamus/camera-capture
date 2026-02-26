# Wait for Camera app to be ready
Start-Sleep -Seconds 3

# Check if Camera app is running
$cameraProc = Get-Process -Name "WindowsCamera" -ErrorAction SilentlyContinue
if (-not $cameraProc) {
    Write-Output "Camera app not found, trying to start..."
    Start-Process "microsoft.windows.camera:"
    Start-Sleep -Seconds 5
    $cameraProc = Get-Process -Name "WindowsCamera" -ErrorAction SilentlyContinue
}

if ($cameraProc) {
    Write-Output "Camera app is running (PID: $($cameraProc.Id))"
} else {
    Write-Output "ERROR: Camera app not running"
    exit 1
}

# Bring Camera app to foreground
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$hwnd = $cameraProc.MainWindowHandle
if ($hwnd -ne [IntPtr]::Zero) {
    [WinAPI]::ShowWindow($hwnd, 9) | Out-Null  # SW_RESTORE
    [WinAPI]::SetForegroundWindow($hwnd) | Out-Null
    Write-Output "Camera window brought to foreground"
}

Start-Sleep -Seconds 2

# Send Enter key to take a photo (Camera app captures on Enter)
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Write-Output "Sent ENTER to capture photo"

# Wait for photo to be saved
Start-Sleep -Seconds 3

# Check for new photo in Camera Roll
$cameraRoll = "C:\Users\towne\OneDrive\Pictures\Camera Roll"
$latestPhoto = Get-ChildItem $cameraRoll -Filter "*.jpg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestPhoto -and $latestPhoto.LastWriteTime -gt (Get-Date).AddMinutes(-2)) {
    Write-Output "SUCCESS: New photo captured: $($latestPhoto.FullName)"
    # Copy to output directory
    Copy-Item $latestPhoto.FullName "C:\Users\towne\Code\Pepper2-master\bot\outputs\camera-capture\webcam_photo.jpg" -Force
    Write-Output "Copied to output directory"
} else {
    Write-Output "No new photo detected in Camera Roll. Latest: $($latestPhoto.Name) at $($latestPhoto.LastWriteTime)"
}
