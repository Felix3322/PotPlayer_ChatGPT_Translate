#!/usr/bin/env python3
"""Stage only CI-built installers and assemble clearly labelled test-signing output.

Signature verification is performed separately on Windows before `finish` runs.
Neither command changes the unsigned release artifacts or publishes a release.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil

from package_release import INSTALLERS, validate_version

SIGNABLE = ('installer-cpp.exe', 'installer-python.exe', 'installer-inno.exe', 'installer.msi')


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def empty_directory(path: Path) -> None:
    if path.exists() and (not path.is_dir() or any(path.iterdir())):
        raise ValueError(f'Output directory must be empty: {path}')
    path.mkdir(parents=True, exist_ok=True)


def inspect_unsigned(source: Path, commit: str) -> dict:
    if not re.fullmatch(r'[0-9a-f]{40}', commit):
        raise ValueError('Expected a full source commit SHA')
    info = json.loads((source / 'BUILD-INFO.json').read_text(encoding='utf-8'))
    version = validate_version(info['version'])
    if info['source_commit'] != commit or info['source_dirty'] is not False:
        raise ValueError('Refusing artifacts from another commit or dirty source')
    expected = {*INSTALLERS, 'BUILD-INFO.json', f'PotPlayer-ChatGPT-Translate-v{version}-manual.zip'}
    actual = {p.name for p in source.iterdir() if p.is_file() and not p.is_symlink()}
    if actual != expected | {'SHA256SUMS'} or len(list(source.iterdir())) != len(actual):
        raise ValueError('Unexpected or missing unsigned release files')
    seen = set()
    for line in (source / 'SHA256SUMS').read_text(encoding='ascii').splitlines():
        match = re.fullmatch(r'([0-9a-f]{64})  ([^/\\]+)', line)
        if not match or match[2] not in expected or match[2] in seen:
            raise ValueError('Malformed, duplicate or unexpected checksum entry')
        seen.add(match[2])
        if digest(source / match[2]) != match[1]:
            raise ValueError(f'Unsigned artifact checksum mismatch: {match[2]}')
    if seen != expected:
        raise ValueError('Unsigned checksum list is incomplete')
    if digest(source / 'installer.exe') != digest(source / 'installer-cpp.exe'):
        raise ValueError('Native installer aliases differ')
    return info


def prepare(source: Path, output: Path, commit: str) -> None:
    inspect_unsigned(source, commit)
    empty_directory(output)
    for name in SIGNABLE:
        shutil.copyfile(source / name, output / name)


def finish(source: Path, signed: Path, report: Path, output: Path, commit: str,
           request_id: str, request_url: str, artifact_id: str) -> None:
    info = inspect_unsigned(source, commit)
    entries = list(signed.iterdir())
    if {p.name for p in entries} != set(SIGNABLE) or any(not p.is_file() or p.is_symlink() for p in entries):
        raise ValueError('Signed output must contain exactly the four requested installers')
    signatures = json.loads(report.read_text(encoding='utf-8-sig'))
    if not isinstance(signatures, list) or len(signatures) != len(SIGNABLE):
        raise ValueError('Incomplete Windows signature report')
    if {item['file'] for item in signatures} != set(SIGNABLE):
        raise ValueError('Signature report does not match requested installers')
    for item in signatures:
        name = item['file']
        if not item['integrity_verified'] or not item['signer_thumbprint']:
            raise ValueError(f'Signature integrity was not verified: {name}')
        if item['sha256'] != digest(signed / name) or digest(signed / name) == digest(source / name):
            raise ValueError(f'Signed artifact is unchanged or differs from the verified file: {name}')
    if not request_id or not request_url.startswith('https://') or not artifact_id.isdigit():
        raise ValueError('Missing signing request provenance')
    empty_directory(output)
    for name in SIGNABLE:
        shutil.copyfile(signed / name, output / name)
    # Sign the native executable once, then preserve the release alias invariant.
    shutil.copyfile(output / 'installer-cpp.exe', output / 'installer.exe')
    for name in ('BUILD-INFO.json', f'PotPlayer-ChatGPT-Translate-v{info["version"]}-manual.zip'):
        shutil.copyfile(source / name, output / name)
    shutil.copyfile(report, output / 'SIGNATURES.json')
    (output / 'TEST-SIGNING-ONLY.txt').write_text(
        'TEST SIGNING ONLY - NOT A TRUSTED PRODUCTION RELEASE\n'
        'These files were submitted using the SignPath test-signing policy.\n'
        'A successful test does not establish SignPath Foundation approval, public\n'
        'certificate trust, or SmartScreen reputation. Do not distribute as a release.\n'
        'The manual ZIP is unchanged and unsigned. Four outer EXE/MSI files were submitted.\n'
        'The selected SignPath artifact configuration determines nested signing scope.\n'
        'Review that configuration; outer signature checks do not verify nested signatures.\n', encoding='utf-8')
    (output / 'SIGNING-INFO.json').write_text(json.dumps({
        'test_signing_only': True,
        'organization_id': 'a92b315d-b2eb-4998-ae95-5e23493e69d9',
        'project_slug': 'PotPlayer_Chatgpt_Translate',
        'signing_policy_slug': 'test-signing',
        'source_commit': commit,
        'unsigned_github_artifact_id': artifact_id,
        'signing_request_id': request_id,
        'signing_request_url': request_url,
        'signed_files': list(SIGNABLE),
    }, indent=2) + '\n', encoding='utf-8')
    # Never carry the pre-signing SHA256SUMS into the signed bundle.
    checksums = ''.join(f'{digest(path)}  {path.name}\n' for path in sorted(output.iterdir()))
    (output / 'SHA256SUMS').write_text(checksums, encoding='ascii', newline='\n')


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=('prepare', 'finish'))
    parser.add_argument('--unsigned', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--commit', required=True)
    parser.add_argument('--signed', type=Path)
    parser.add_argument('--report', type=Path)
    parser.add_argument('--request-id')
    parser.add_argument('--request-url')
    parser.add_argument('--artifact-id')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.unsigned, args.output, args.commit)
    else:
        if any(value is None for value in (args.signed, args.report, args.request_id, args.request_url, args.artifact_id)):
            parser.error('finish requires signed, report, request-id, request-url and artifact-id')
        finish(args.unsigned, args.signed, args.report, args.output, args.commit,
               args.request_id, args.request_url, args.artifact_id)


if __name__ == '__main__':
    main()
