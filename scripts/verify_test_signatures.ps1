param(
    [Parameter(Mandatory = $true)][string]$ArtifactDirectory,
    [Parameter(Mandatory = $true)][string]$ReportPath,
    [switch]$NativeOnly
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:OS -ne 'Windows_NT') { throw 'Authenticode verification requires Windows.' }
if (-not ('AuthenticodeIntegrity' -as [type])) {
    Add-Type -Path (Join-Path $PSScriptRoot 'AuthenticodeIntegrity.cs')
}
Add-Type -AssemblyName System.Security.Cryptography.Pkcs
$names = @('installer-cpp.exe', 'installer-python.exe', 'installer-inno.exe', 'installer.msi')
if ($NativeOnly) { $names = @('installer-cpp.exe') }
if ($NativeOnly) {
    $entries = @(Get-ChildItem -LiteralPath $ArtifactDirectory -Force)
    if ($entries.Count -ne 1 -or $entries[0].Name -cne 'installer-cpp.exe' -or $entries[0].PSIsContainer -or ($entries[0].Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw 'Native-only signed output must contain exactly installer-cpp.exe.'
    }
}
$results = [System.Collections.Generic.List[object]]::new()
$failures = [System.Collections.Generic.List[string]]::new()
foreach ($name in $names) {
    $result = [ordered]@{ file = $name; integrity_verified = $false }
    try {
        $path = (Resolve-Path -LiteralPath (Join-Path $ArtifactDirectory $name)).Path
        $cms = [System.Security.Cryptography.Pkcs.SignedCms]::new()
        $cms.Decode([AuthenticodeIntegrity]::ReadEmbeddedSignature($path))
        if ($cms.SignerInfos.Count -ne 1 -or $cms.ContentInfo.ContentType.Value -ne '1.3.6.1.4.1.311.2.1.4') {
            throw 'Expected one primary Authenticode signer and SPC_INDIRECT_DATA content.'
        }
        # Multiple nested signatures require matching digest/signature selection.
        foreach ($attribute in $cms.SignerInfos[0].UnsignedAttributes) {
            if ($attribute.Oid.Value -eq '1.3.6.1.4.1.311.2.4.1') { throw 'Nested signatures are outside this test scope.' }
        }
        $cms.CheckSignature($true) # Cryptography only; do not trust/import a test root.
        [AuthenticodeIntegrity]::VerifyFileDigest($path)
        $certificate = $cms.SignerInfos[0].Certificate
        if ($null -eq $certificate) { throw 'The embedded signer certificate is missing.' }
        $result.integrity_verified = $true
        $result.signer_subject = $certificate.Subject
        $result.signer_thumbprint = $certificate.Thumbprint
        $result.signer_certificate_sha256 = $certificate.GetCertHashString([System.Security.Cryptography.HashAlgorithmName]::SHA256)
        $result.sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
        # Informational only: UnknownError may mean an untrusted root or another
        # failure. It never substitutes for either explicit integrity check above.
        $signature = Get-AuthenticodeSignature -LiteralPath $path
        $result.windows_trust_status = $signature.Status.ToString()
        $result.windows_trust_message = $signature.StatusMessage
    }
    catch {
        $result.error = $_.Exception.Message
        $failures.Add("${name}: $($_.Exception.Message)")
    }
    $results.Add($result)
}
ConvertTo-Json -InputObject @($results.ToArray()) -Depth 5 | Set-Content -LiteralPath $ReportPath -Encoding utf8
if ($failures.Count -gt 0) { throw ($failures -join "`n") }
Write-Host "Verified embedded signature cryptography and covered file digests for $($names.Count) installer(s). Public trust and Foundation approval are not established."
