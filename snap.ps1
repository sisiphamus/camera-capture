# Bring Camera app to foreground and take a photo
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

$cameraProc = Get-Process -Name "WindowsCamera" -ErrorAction SilentlyContinue
if (-not $cameraProc) {
    Start-Process "microsoft.windows.camera:"
    Start-Sleep -Seconds 4
    $cameraProc = Get-Process -Name "WindowsCamera" -ErrorAction SilentlyContinue
}

if (-not $cameraProc) {
    Write-Output "ERROR: Camera app not running"
    exit 1
}

$hwnd = $cameraProc.MainWindowHandle
[WinAPI]::ShowWindow($hwnd, 9) | Out-Null
[WinAPI]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep -Seconds 2

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
Start-Sleep -Seconds 3

$cameraRoll = "C:\Users\towne\OneDrive\Pictures\Camera Roll"
$latestPhoto = Get-ChildItem $cameraRoll -Filter "*.jpg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestPhoto -and $latestPhoto.LastWriteTime -gt (Get-Date).AddMinutes(-1)) {
    Write-Output "SUCCESS: $($latestPhoto.FullName)"
    Copy-Item $latestPhoto.FullName "C:\Users\towne\Code\Pepper2-master\bot\outputs\camera-capture\webcam_photo.jpg" -Force
} else {
    Write-Output "WARN: No new photo. Latest: $($latestPhoto.Name) at $($latestPhoto.LastWriteTime)"
}
