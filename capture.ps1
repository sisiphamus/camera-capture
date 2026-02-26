Add-Type -AssemblyName System.Runtime.WindowsRuntime

# Load WinRT assemblies
[Windows.Media.Capture.MediaCapture, Windows.Media.Capture, ContentType = WindowsRuntime] | Out-Null
[Windows.Media.MediaProperties.ImageEncodingProperties, Windows.Media.MediaProperties, ContentType = WindowsRuntime] | Out-Null
[Windows.Storage.Streams.InMemoryRandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime] | Out-Null

# Helper to await WinRT async operations
function Await($WinRtTask, $ResultType) {
    $asTask = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' } | Select-Object -First 1
    if ($ResultType) {
        $asTaskGeneric = $asTask.MakeGenericMethod($ResultType)
    } else {
        $asTaskGeneric = [System.WindowsRuntimeSystemExtensions].GetMethod('AsTask', [Type[]]@([Windows.Foundation.IAsyncAction]))
    }
    $netTask = $asTaskGeneric.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    if ($ResultType) { $netTask.Result }
}

function AwaitAction($WinRtTask) {
    $asTask = [System.WindowsRuntimeSystemExtensions].GetMethod('AsTask', [Type[]]@([Windows.Foundation.IAsyncAction]))
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
}

try {
    $capture = New-Object Windows.Media.Capture.MediaCapture
    AwaitAction ($capture.InitializeAsync())

    Start-Sleep -Seconds 2

    $stream = New-Object Windows.Storage.Streams.InMemoryRandomAccessStream
    $props = [Windows.Media.MediaProperties.ImageEncodingProperties]::CreateJpeg()
    AwaitAction ($capture.CapturePhotoToStreamAsync($props, $stream))

    $stream.Seek(0)
    $reader = New-Object System.IO.BinaryReader([System.IO.WindowsRuntimeStreamExtensions]::AsStream($stream.GetInputStreamAt(0)))
    $bytes = $reader.ReadBytes($stream.Size)
    [System.IO.File]::WriteAllBytes('C:\Users\towne\Code\Pepper2-master\bot\outputs\camera-capture\webcam_photo.jpg', $bytes)

    $reader.Close()
    $stream.Dispose()
    $capture.Dispose()

    Write-Output "SUCCESS: Image captured and saved"
} catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    Write-Output $_.Exception.GetType().FullName
}
