Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$slotPort = 8085
$blackjackPort = 8086
$slotPrefix = "http://localhost:$slotPort/"
$blackjackPrefix = "http://localhost:$blackjackPort/"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$slotIndex = Join-Path $root "index.html"
$blackjackIndex = Join-Path $root "blackjack.html"

if (-not (Test-Path -Path $slotIndex)) {
    Write-Host "index.html not found in $root" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path -Path $blackjackIndex)) {
    Write-Host "blackjack.html not found in $root" -ForegroundColor Red
    exit 1
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($slotPrefix)
$listener.Prefixes.Add($blackjackPrefix)

$script:stopRequested = $false
$cancelHandler = [ConsoleCancelEventHandler]{
    param($sender, $eventArgs)
    $eventArgs.Cancel = $true
    $script:stopRequested = $true
    if ($listener.IsListening) {
        $listener.Stop()
    }
}
[Console]::add_CancelKeyPress($cancelHandler)

$listener.Start()
Write-Host "PowerHell Casino Web GUI running:"
Write-Host "Slot:      $slotPrefix"
Write-Host "Blackjack: $blackjackPrefix"
Write-Host "Press Ctrl+C to stop."

try {
    while (-not $script:stopRequested) {
        try {
            $context = $listener.GetContext()
        } catch {
            if ($script:stopRequested) { break }
            continue
        }

        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.AbsolutePath.TrimStart("/")
        if ([string]::IsNullOrWhiteSpace($path)) {
            if ($request.Url.Port -eq $blackjackPort) {
                $path = "blackjack.html"
            } else {
                $path = "index.html"
            }
        }

        $filePath = Join-Path $root $path
        if (-not (Test-Path -Path $filePath -PathType Leaf)) {
            $response.StatusCode = 404
            $bytes = [System.Text.Encoding]::UTF8.GetBytes("Not Found")
            $response.ContentType = "text/plain; charset=utf-8"
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        $ext = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
        switch ($ext) {
            ".html" { $contentType = "text/html; charset=utf-8" }
            ".css"  { $contentType = "text/css; charset=utf-8" }
            ".js"   { $contentType = "application/javascript; charset=utf-8" }
            ".png"  { $contentType = "image/png" }
            ".jpg"  { $contentType = "image/jpeg" }
            ".jpeg" { $contentType = "image/jpeg" }
            ".svg"  { $contentType = "image/svg+xml" }
            default { $contentType = "application/octet-stream" }
        }

        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = $contentType
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.OutputStream.Close()
    }
}
finally {
    if ($listener.IsListening) {
        $listener.Stop()
    }
    $listener.Close()
    [Console]::remove_CancelKeyPress($cancelHandler)
}
