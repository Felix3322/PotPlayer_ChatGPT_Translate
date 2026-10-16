# Release packaging and CI

The `Build release packages` workflow runs regression tests and builds the same
installer set on pull requests, pushes to `master`, manual runs, and **every tag
push**. A tag must be a release version such as `v1.9.5`, `1.9.5` or `v1.9.5-rc.1`.
Non-tag builds use the version in the root `VERSION` file (currently `1.9.6`);
tag builds use the tag version. CI checks executable product-name and version
metadata before uploading packages.
Invalid/non-version tags fail early rather than publishing mislabeled packages.
Windows Installer restricts the numeric components to `255.255.65535`. The full
release version remains visible, but MSI compares only the numeric core. Build
metadata (`+...`) and numeric prerelease identifiers with leading zeros are rejected.
Uninstall
the MSI before switching prerelease/stable builds of the same numeric version.
Tags containing a prerelease suffix publish a GitHub prerelease, not the latest
stable release.

## Published assets

- `installer.exe`: native C++ installer, the default download
- `installer-cpp.exe`: byte-identical native installer under its explicit name
- `installer-python.exe`: independent Python/PyInstaller build
- `installer-inno.exe`: Inno Setup installer
- `installer.msi`: Windows Installer package with both plugin variants; configure
  model, API endpoint and key in PotPlayer after installing
- `PotPlayer-ChatGPT-Translate-vVERSION-manual.zip`: manual installation payload,
  documentation and GPLv3 license
- `BUILD-INFO.json`: source commit, version and staged plugin hashes
- `SHA256SUMS`: SHA-256 checksums for all other assets

These are unsigned packages. Native/Python/Inno retain their existing configuration
wizards. MSI is an offline payload installer and does not contact an API. Select
one installation method for each target folder; back up your plugin files and
settings before changing installer formats. See [MSI details](../installer/msi/README.md).

For Foundation setup review, use the separate manual
[SignPath test-signing workflow](SIGNPATH-TEST-SIGNING.md). Both workflows reuse
`build-packages.yml`; test signing never publishes or overwrites release assets.

## Build locally on Windows

Requirements: Windows x64, PowerShell **7**, Python **3.12 x64**, Visual Studio 2022 C++ build tools
and Windows SDK, Inno Setup 6.5+, and .NET SDK 8+. WiX 5.0.2 and its matching UI
extension are downloaded from the official NuGet feed into a temporary local tool
folder by the MSI build; no global WiX installation is changed.

```powershell
python -m venv .venv
./.venv/Scripts/Activate.ps1
python -m pip install -r releases/build/requirements-build.txt
./scripts/build_release.ps1 -Version v1.9.5 -OutputDir C:\build\potplayer-v1.9.5
```

Use an empty output directory. The build runs in a fresh temporary staging tree,
reads current source, stamps both plugins and installer versions, and verifies the
embedded native and Python payloads. It never uses old `releases/latest` binaries,
changes source versions in your checkout, or touches API credentials. The ZIP is
verified by byte comparison and every asset is checksummed. ZIP metadata uses the
commit timestamp for reproducibility; Windows EXE/MSI builds are not claimed to
be byte-for-byte reproducible across toolchain updates.

Portable-only packaging works on Linux/macOS/Windows with Python 3.10+:

```sh
python3 scripts/package_release.py portable --version v1.9.5 --output-dir dist/manual
```

This produces the manual ZIP and metadata/checksums, not Windows installers.

## Publish a new release

After the release workflow is merged and its Windows build passes, tag that
commit and push the tag. Tags must point to a commit containing this workflow.

```sh
git switch master
git pull --ff-only
git tag v1.9.5
git push origin v1.9.5
```

The tag run validates both full AngelScript plugins (mocked PotPlayer host), builds
all formats on Windows, verifies/checksums the assets, and uploads them to a draft
GitHub Release. Only after all uploads succeed is the release published. PR,
branch and manual builds only provide downloadable Actions artifacts using
`VERSION`, and cannot publish a release. Ordinary build/test jobs get
`contents: read`; only the tag publication job gets `contents: write`. No PAT or
new repository secret is needed. Existing Gemini workflows are independent.

The workflow refuses to replace an existing release or overwrite its assets.
If an upload failed and left a draft, inspect that draft before removing it and
re-running publication. Never move an already-published tag to replace a release;
use a new version. Push tags with your normal authenticated Git client or GitHub
account; a tag pushed using another workflow's default `GITHUB_TOKEN` does not
normally trigger a new workflow.

## Validation boundaries

`tests/run_tests.py` compiles both production scripts with official AngelScript
2.38.0 and checks 222 mocked-host runtime assertions / 50 request JSON payloads.
`tests/test_release_packaging.py` checks exact version stamping, source isolation,
ZIP membership, reproducible ZIP bytes, checksums and fail-fast missing assets.
Windows CI also exercises MSI rejection of invalid/unmanaged targets, install,
payload hashes, repair and uninstall in a synthetic PotPlayer-folder fixture,
checking that unrelated files survive. This proves package lifecycle behavior,
compilation and embedded payload integrity, not a complete
interactive installation into a real PotPlayer instance or provider acceptance.
API calls are not made by these tests. Tool versions are recorded in each run.
