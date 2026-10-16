# Local cryptographic fixtures only: no network, SignPath secret or trusted root.
param([Parameter(Mandatory = $true)][string]$UnsignedDirectory)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('potplayer-signature-tests-' + [guid]::NewGuid().ToString('N'))
$rsa = [System.Security.Cryptography.RSA]::Create(2048)
$certificate = $null
try {
    New-Item -ItemType Directory -Path $temp | Out-Null
    $fixtures = Join-Path $temp 'fixtures'
    New-Item -ItemType Directory -Path $fixtures | Out-Null
    $names = @('installer-cpp.exe', 'installer-python.exe', 'installer-inno.exe', 'installer.msi')
    foreach ($name in $names) {
        Copy-Item -LiteralPath (Join-Path $UnsignedDirectory $name) -Destination (Join-Path $fixtures $name)
    }
    $report = Join-Path $temp 'report.json'
    $verify = Join-Path $root 'scripts/verify_test_signatures.ps1'
    function Assert-Rejected([string]$Case) {
        $rejected = $false
        try { & $verify -ArtifactDirectory $fixtures -ReportPath $report }
        catch { $rejected = $true }
        if (-not $rejected) { throw "Verifier accepted invalid fixture: $Case" }
        Write-Host "PASS rejected $Case"
    }
    Assert-Rejected 'unsigned EXE/MSI files'

    # Generate a short-lived in-memory fixture certificate, never add it to Root
    # or TrustedPublisher. It cannot grant access to SignPath or any other system.
    $request = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new(
        'CN=PotPlayer CI test fixture only', $rsa,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256,
        [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    $usage = [System.Security.Cryptography.OidCollection]::new()
    [void]$usage.Add([System.Security.Cryptography.Oid]::new('1.3.6.1.5.5.7.3.3'))
    $request.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension]::new($usage, $true))
    $request.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509KeyUsageExtension]::new(
        [System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::DigitalSignature, $true))
    $certificate = $request.CreateSelfSigned([DateTimeOffset]::UtcNow.AddMinutes(-5), [DateTimeOffset]::UtcNow.AddHours(1))
    foreach ($name in $names) {
        $signed = Set-AuthenticodeSignature -LiteralPath (Join-Path $fixtures $name) -Certificate $certificate -HashAlgorithm SHA256
        if ($null -eq $signed.SignerCertificate) { throw "Could not sign fixture: $name" }
    }
    & $verify -ArtifactDirectory $fixtures -ReportPath $report
    $results = @(Get-Content -LiteralPath $report -Raw | ConvertFrom-Json)
    if ($results.Count -ne 4 -or @($results | Where-Object { -not $_.integrity_verified }).Count -gt 0) {
        throw 'The four untrusted signed fixtures were not all verified.'
    }
    Write-Host 'PASS untrusted self-signed EXE/MSI fixture cryptography and file digests'

    $native = Join-Path $fixtures 'installer-cpp.exe'
    $original = [System.IO.File]::ReadAllBytes($native)
    $tampered = $original.Clone()
    # DOS stub contents are covered by Authenticode and do not alter PE offsets.
    $tampered[0x40] = $tampered[0x40] -bxor 1
    [System.IO.File]::WriteAllBytes($native, $tampered)
    Assert-Rejected 'content-tampered EXE'
    [System.IO.File]::WriteAllBytes($native, $original)

    $tampered = $original.Clone()
    $peOffset = [BitConverter]::ToInt32($tampered, 0x3c)
    $optionalOffset = $peOffset + 24
    $magic = [BitConverter]::ToUInt16($tampered, $optionalOffset)
    $directoryOffset = if ($magic -eq 0x20b) { $optionalOffset + 112 } else { $optionalOffset + 96 }
    $certificateOffset = [BitConverter]::ToInt32($tampered, $directoryOffset + 32)
    if ($certificateOffset -le 0) { throw 'Fixture has no PE certificate table.' }
    $tampered[$certificateOffset + 8] = $tampered[$certificateOffset + 8] -bxor 1
    [System.IO.File]::WriteAllBytes($native, $tampered)
    Assert-Rejected 'signature-tampered EXE'
    [System.IO.File]::WriteAllBytes($native, $original)

    $msi = Join-Path $fixtures 'installer.msi'
    $tampered = [System.IO.File]::ReadAllBytes($msi)
    $tampered[4096] = $tampered[4096] -bxor 1
    [System.IO.File]::WriteAllBytes($msi, $tampered)
    Assert-Rejected 'content-tampered MSI'
}
finally {
    if ($null -ne $certificate) { $certificate.Dispose() }
    $rsa.Dispose()
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
