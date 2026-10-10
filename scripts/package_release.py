#!/usr/bin/env python3
"""Stage current source and assemble versioned, checksummed release assets.

Only staging copies are version-stamped. Tracked historical installers are never
copied. Portable ZIPs use fixed metadata and the commit time for reproducibility.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PLUGINS = ("SubtitleTranslate - ChatGPT.as", "SubtitleTranslate - ChatGPT - Without Context.as")
PAYLOAD = (*PLUGINS, *(str(Path(p).with_suffix('.ico')) for p in PLUGINS))
DOCS = ("LICENSE", "README.md", "docs/readme_zh.md", "docs/readme_zh-tw.md", "docs/BUILDING.md", "docs/SIGNING-READINESS.md", "installer/msi/README.md")
INSTALLERS = ("installer.exe", "installer-cpp.exe", "installer-python.exe", "installer-inno.exe", "installer.msi")
BUILD_EXTENSIONS = {'.py', '.ps1', '.bat', '.h', '.cpp', '.rc', '.manifest', '.json', '.txt', '.iss', '.isl', '.wxs', '.wxl', '.rtf'}
VERSION_PATTERN = re.compile(r'v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-([A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*))?(?:\+([A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*))?\Z')


def validate_version(version: str) -> str:
    match = VERSION_PATTERN.fullmatch(version)
    if not match or len(version) > 80:
        raise ValueError('Use a release version such as v1.9.5 or v1.9.5-rc.1 (no spaces or path separators)')
    if any(int(v) > limit for v, limit in zip(match.groups()[:3], (255, 255, 65535))):
        raise ValueError('MSI version components must be <=255.255.65535')
    if match.group(5):
        raise ValueError('MSI releases do not support +build metadata; use a distinct numeric version or -prerelease label')
    if match.group(4) and any(part.isdigit() and len(part) > 1 and part.startswith('0') for part in match.group(4).split('.')):
        raise ValueError('Numeric prerelease identifiers cannot have leading zeros')
    return version.removeprefix('v')


def stamp_script(data: bytes, version: str) -> bytes:
    pattern = rb'(string\s+GetVersion\(\)\s*\{\s*return\s+")[^"]+("\s*;)'
    result, count = re.subn(pattern, lambda m: m[1] + version.encode('ascii') + m[2], data)
    if count != 1:
        raise ValueError('Expected exactly one GetVersion() in each plugin')
    return result


def git(root: Path, *args: str) -> str:
    return subprocess.check_output(['git', '-C', str(root), *args], text=True).strip()


def stage_source(root: Path, stage: Path, version: str) -> dict:
    normalized = validate_version(version)
    if stage.exists() and any(stage.iterdir()):
        raise ValueError(f'Staging directory must be empty: {stage}')
    stage.mkdir(parents=True, exist_ok=True)
    for relative in (*PAYLOAD, *DOCS, 'icon.ico'):
        source = root / relative
        destination = stage / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        data = source.read_bytes()
        if relative in PLUGINS:
            data = stamp_script(data, normalized)
        destination.write_bytes(data)
    # Explicit text/source allowlist excludes releases/latest and historical EXEs.
    for directory in ('releases/build', 'installer'):
        for source in sorted((root / directory).rglob('*')):
            if not source.is_file() or source.suffix not in BUILD_EXTENSIONS:
                continue
            relative = source.relative_to(root)
            if any(part in {'generated', 'build', 'dist', '__pycache__'} for part in source.relative_to(root / directory).parts[:-1]):
                continue
            destination = stage / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)
    metadata = {
        'version': normalized,
        'source_commit': git(root, 'rev-parse', 'HEAD'),
        'source_commit_time': int(git(root, 'show', '-s', '--format=%ct', 'HEAD')),
        'source_dirty': bool(git(root, 'status', '--porcelain', '--untracked-files=no')),
        'plugin_sha256': {name: hashlib.sha256((stage / name).read_bytes()).hexdigest() for name in PLUGINS},
    }
    (stage / 'BUILD-INFO.json').write_text(json.dumps(metadata, indent=2) + '\n', encoding='utf-8')
    (stage / 'INSTALL.txt').write_text(
        'PotPlayer ChatGPT Translate ' + normalized + '\n\n'
        'Manual install / 手动安装\n'
        '1. Close PotPlayer. Back up your existing plugin .as/.ico files and settings.\n'
        '2. Copy the desired .as file and its matching .ico into your actual PotPlayer\\Extension\\Subtitle\\Translate folder.\n'
        '   Both variants can be installed side by side. Do not copy the documentation into that folder.\n'
        '3. Restart PotPlayer and choose the plugin in subtitle translation settings.\n'
        '4. Configure model, endpoint and API key in PotPlayer. For compatible providers, add thinking=disabled to turn off thinking.\n'
        '   See README.md or docs/readme_zh.md for provider compatibility and detailed options.\n'
        'Uninstall: close PotPlayer and remove only the corresponding .as and .ico files.\n'
        'No credentials are included in this package. No live API requests were made during its build.\n', encoding='utf-8')
    return metadata


def create_zip(stage: Path, output: Path, metadata: dict) -> Path:
    path = output / f'PotPlayer-ChatGPT-Translate-v{metadata["version"]}-manual.zip'
    # ZIP cannot represent dates before 1980. Strip seconds' low bit explicitly.
    epoch = max(metadata['source_commit_time'], 315532800)
    date = list(time.gmtime(epoch)[:6]); date[-1] -= date[-1] % 2
    with zipfile.ZipFile(path, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name in sorted((*PAYLOAD, *DOCS, 'BUILD-INFO.json', 'INSTALL.txt')):
            info = zipfile.ZipInfo(name, tuple(date))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, (stage / name).read_bytes(), compresslevel=9)
    with zipfile.ZipFile(path) as archive:
        if archive.testzip() is not None:
            raise ValueError('ZIP integrity check failed')
        for name in PAYLOAD:
            if archive.read(name) != (stage / name).read_bytes():
                raise ValueError(f'ZIP payload mismatch: {name}')
    return path


def finalize(stage: Path, output: Path, require_installers: bool = False) -> list[Path]:
    metadata = json.loads((stage / 'BUILD-INFO.json').read_text(encoding='utf-8'))
    validate_version(metadata['version'])
    output.mkdir(parents=True, exist_ok=True)
    assets = []
    if require_installers:
        for name in INSTALLERS:
            path = output / name
            with path.open('rb') as stream:
                magic = stream.read(8)
            expected = b'\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1' if name.endswith('.msi') else b'MZ'
            if not magic.startswith(expected) or path.stat().st_size < 10000:
                raise ValueError(f'Not a valid installer container: {name}')
            assets.append(path)
        if (output / 'installer.exe').read_bytes() != (output / 'installer-cpp.exe').read_bytes():
            raise ValueError('installer.exe must be an exact alias of installer-cpp.exe')
    assets.append(create_zip(stage, output, metadata))
    shutil.copyfile(stage / 'BUILD-INFO.json', output / 'BUILD-INFO.json')
    assets.append(output / 'BUILD-INFO.json')
    expected_names = {path.name for path in assets} | {'SHA256SUMS'}
    extra = {p.name for p in output.iterdir()} - expected_names
    if extra:
        raise ValueError(f'Refusing to package unexpected/stale output files: {sorted(extra)}')
    checksums = ''.join(f'{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}\n' for path in sorted(assets))
    (output / 'SHA256SUMS').write_text(checksums, encoding='ascii', newline='\n')
    assets.append(output / 'SHA256SUMS')
    return assets


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    stage = commands.add_parser('stage')
    stage.add_argument('--version', required=True)
    stage.add_argument('--root', type=Path, default=ROOT)
    stage.add_argument('--stage-dir', required=True, type=Path)
    finish = commands.add_parser('finalize')
    finish.add_argument('--stage-dir', required=True, type=Path)
    finish.add_argument('--output-dir', required=True, type=Path)
    finish.add_argument('--require-installers', action='store_true')
    portable = commands.add_parser('portable')
    portable.add_argument('--version', required=True)
    portable.add_argument('--root', type=Path, default=ROOT)
    portable.add_argument('--output-dir', required=True, type=Path)
    args = parser.parse_args()
    if args.command == 'stage':
        print(json.dumps(stage_source(args.root.resolve(), args.stage_dir.resolve(), args.version), indent=2))
    elif args.command == 'finalize':
        print('\n'.join(map(str, finalize(args.stage_dir.resolve(), args.output_dir.resolve(), args.require_installers))))
    else:
        with tempfile.TemporaryDirectory(prefix='potplayer-release-') as directory:
            staging = Path(directory)
            stage_source(args.root.resolve(), staging, args.version)
            print('\n'.join(map(str, finalize(staging, args.output_dir.resolve()))))


if __name__ == '__main__':
    main()
