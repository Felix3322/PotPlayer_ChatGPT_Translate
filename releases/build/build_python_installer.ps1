<#
.SYNOPSIS
Build the offline Python installer from this checkout on Windows.
.DESCRIPTION
Requires Python 3.12 x64 with requirements-build.txt installed. The release
packager must stamp the staged root .as files before calling this script.
Only the verified installer-python.exe is written to OutputDir. Generated
source, PyInstaller's cache/spec/work files, and intermediate binaries live in
a unique system temporary directory, which is removed after success or failure.
This builds an unsigned executable; it never starts or installs the result.
.EXAMPLE
python -m pip install -r C:\source\releases\build\requirements-build.txt
& C:\source\releases\build\build_python_installer.ps1 -Version 1.9.5 -OutputDir C:\artifacts
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9][0-9A-Za-z.+_-]*$')]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'Build the Python installer on Windows; PyInstaller cannot cross-compile Windows executables.'
}
if (-not [System.IO.Path]::IsPathRooted($OutputDir) -or $OutputDir -notmatch '^(?:[A-Za-z]:[\\/]|\\\\[^\\]+\\[^\\]+)') {
    throw 'OutputDir must be a fully qualified absolute Windows path.'
}

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$outputPath = [System.IO.Path]::GetFullPath($OutputDir)
$python = @(Get-Command python -CommandType Application -ErrorAction Stop)[0].Source

# Use Python's native path/subprocess APIs for argument quoting, UTF-8 source,
# temporary-directory cleanup, and exact inspection of the finished CArchive.
# The helper is ASCII-only, so Windows PowerShell's pipeline encoding is safe.
$buildHelper = @'
import ast
import importlib.metadata
import json
import marshal
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import tempfile


def check_dependencies(requirements):
    failures = []
    for line in requirements.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        # This file is intentionally a simple, fully pinned Windows snapshot.
        name, expected = line.split("==", 1)
        try:
            actual = importlib.metadata.version(name)
        except importlib.metadata.PackageNotFoundError:
            actual = "not installed"
        if actual != expected:
            failures.append(f"{name}: expected {expected}, found {actual}")
    if failures:
        raise RuntimeError(
            "Install requirements-build.txt into a clean Python 3.12 x64 environment:\n"
            + "\n".join(failures)
        )


def prepare_source(source, destination, version):
    text = source.read_text(encoding="utf-8-sig")
    # Fail closed when the source no longer has exactly one version assignment.
    text, count = re.subn(
        r'^PLUGIN_VERSION\s*=\s*"[^"\r\n]*"\s*$',
        lambda _: "PLUGIN_VERSION = " + json.dumps(version),
        text,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise RuntimeError(f"Expected one PLUGIN_VERSION assignment, found {count}")
    ast.parse(text, filename=str(source))
    destination.write_text(text, encoding="utf-8", newline="\n")


def verify_archive(executable, resources, prepared_source):
    # Reading the archive does not run the installer or request elevation.
    from PyInstaller.archive.readers import CArchiveReader

    archive = CArchiveReader(str(executable))
    for source in resources:
        name = source.name
        if name not in archive.toc:
            raise RuntimeError(f"Missing bundled payload: {name}")
        if archive.extract(name) != source.read_bytes():
            raise RuntimeError(f"Bundled payload differs from staged source: {name}")

    # Compare the compiled entrypoint as well, including the requested version.
    # Code-object equality ignores filenames, which PyInstaller anonymizes.
    entrypoint = prepared_source.stem
    if entrypoint not in archive.toc:
        raise RuntimeError(f"Missing bundled entrypoint: {entrypoint}")
    actual = marshal.loads(archive.extract(entrypoint))
    expected = compile(prepared_source.read_bytes(), str(prepared_source), "exec", optimize=0)
    if actual != expected:
        raise RuntimeError("Bundled Python entrypoint differs from versioned source")
    print(f"Verified {len(resources)} embedded payloads and the versioned Python entrypoint.")


def main():
    root, version, output_dir = sys.argv[1:]
    if sys.platform != "win32" or sys.version_info[:2] != (3, 12) or struct.calcsize("P") != 8:
        raise RuntimeError("Use Windows with Python 3.12 x64 to build this installer")
    root = Path(root).resolve(strict=True)
    output_dir = Path(output_dir)
    if not output_dir.is_absolute():
        raise RuntimeError("OutputDir must be absolute")
    build_dir = root / "releases" / "build"
    check_dependencies(build_dir / "requirements-build.txt")
    subprocess.run([sys.executable, "-m", "pip", "check"], check=True)

    resources = [
        root / "SubtitleTranslate - ChatGPT.as",
        root / "SubtitleTranslate - ChatGPT.ico",
        root / "SubtitleTranslate - ChatGPT - Without Context.as",
        root / "SubtitleTranslate - ChatGPT - Without Context.ico",
        root / "LICENSE",
        root / "icon.ico",
        build_dir / "language_strings.json",
        build_dir / "model_token_limits.json",
    ]
    for source in [build_dir / "installer.py", *resources]:
        if not source.is_file():
            raise FileNotFoundError(f"Required source file is missing: {source}")

    with tempfile.TemporaryDirectory(prefix="potplayer-python-build-") as temporary_dir:
        temporary = Path(temporary_dir)
        prepared_source = temporary / "installer_preped.py"
        prepare_source(build_dir / "installer.py", prepared_source, version)
        environment = os.environ.copy()
        environment["PYINSTALLER_CONFIG_DIR"] = str(temporary / "cache")
        environment["PYTHONDONTWRITEBYTECODE"] = "1"
        environment["PYTHONHASHSEED"] = "0"
        match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)(?:-[A-Za-z0-9.-]+)?", version)
        if not match:
            raise ValueError("Invalid Windows file version")
        numeric = tuple(map(int, match.groups())) + (0,)
        if any(part > 65535 for part in numeric):
            raise ValueError("Windows version component exceeds 65535")
        fields = {
            "CompanyName": "Felix3322",
            "FileDescription": "PotPlayer ChatGPT Translate installer",
            "FileVersion": version,
            "InternalName": "installer-python",
            "OriginalFilename": "installer-python.exe",
            "ProductName": "PotPlayer ChatGPT Translate",
            "ProductVersion": version,
        }
        strings = ",".join(f"StringStruct({key!r}, {value!r})" for key, value in fields.items())
        version_file = temporary / "version-info.txt"
        version_file.write_text(
            f"VSVersionInfo(ffi=FixedFileInfo(filevers={numeric!r}, prodvers={numeric!r}, "
            "mask=0x3f, flags=0, OS=0x40004, fileType=1, subtype=0, date=(0, 0)), "
            f"kids=[StringFileInfo([StringTable('040904b0', [{strings}])]), "
            "VarFileInfo([VarStruct('Translation', [1033, 1200])])])",
            encoding="utf-8",
        )
        command = [
            sys.executable, "-m", "PyInstaller",
            "--noconfirm", "--clean", "--onefile", "--windowed", "--noupx",
            "--optimize", "0",
            "--name", "installer-python",
            "--distpath", str(temporary / "dist"),
            "--workpath", str(temporary / "work"),
            "--specpath", str(temporary),
            "--icon", str(root / "icon.ico"),
            "--version-file", str(version_file),
            "--collect-all", "openai",
            "--recursive-copy-metadata", "openai",
            "--hidden-import", "win32com.client",
            "--hidden-import", "pythoncom",
            "--hidden-import", "pywintypes",
            "--hidden-import", "PyQt6.QtCore",
            "--hidden-import", "PyQt6.QtGui",
            "--hidden-import", "PyQt6.QtWidgets",
        ]
        for source in resources:
            command.extend(["--add-data", str(source) + os.pathsep + "."])
        command.append(str(prepared_source))
        subprocess.run(command, cwd=temporary, env=environment, check=True)
        executable = temporary / "dist" / "installer-python.exe"
        if not executable.is_file() or executable.stat().st_size == 0:
            raise RuntimeError("PyInstaller did not produce a non-empty installer-python.exe")
        verify_archive(executable, resources, prepared_source)

        # Publish only a validated build. Never recursively clean OutputDir.
        output_dir.mkdir(parents=True, exist_ok=True)
        final_executable = output_dir / "installer-python.exe"
        shutil.copyfile(executable, final_executable)
        print(f"Python installer build finished: {final_executable}")


if __name__ == "__main__":
    main()
'@

$buildHelper | & $python - $projectRoot $Version $outputPath
if ($LASTEXITCODE -ne 0) {
    throw "Python installer build failed with exit code $LASTEXITCODE."
}
