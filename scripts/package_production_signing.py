#!/usr/bin/env python3
"""Assemble a native-only release after Windows production signature verification."""
import argparse
import json
from pathlib import Path
import re
import shutil
from package_test_signing import digest, empty_directory, inspect_unsigned


def finish(source, signed, report, output, commit, request_id, request_url, artifact_id, certificate_sha256):
    info = inspect_unsigned(source, commit)
    entries = list(signed.iterdir())
    if len(entries) != 1 or entries[0].name != 'installer-cpp.exe' or not entries[0].is_file() or entries[0].is_symlink():
        raise ValueError('Expected exactly one signed native installer')
    signatures = json.loads(report.read_text(encoding='utf-8-sig'))
    if not re.fullmatch(r'[0-9A-F]{64}', certificate_sha256):
        raise ValueError('Configure the production certificate SHA256 fingerprint')
    if not isinstance(signatures, list) or len(signatures) != 1:
        raise ValueError('Expected one signature report')
    sig = signatures[0]
    if (sig.get('file') != 'installer-cpp.exe' or sig.get('integrity_verified') is not True
        or sig.get('windows_trust_status') != 'Valid' or sig.get('signer_certificate_sha256', '').upper() != certificate_sha256
        or sig.get('sha256') != digest(entries[0]) or digest(entries[0]) == digest(source / 'installer-cpp.exe')):
        raise ValueError('Production signature, signer, trust or artifact integrity verification failed')
    if not re.fullmatch(r'[0-9a-fA-F-]{36}', request_id) or not request_url.startswith('https://app.signpath.io/') or not artifact_id.isdigit():
        raise ValueError('Invalid signing request provenance')
    empty_directory(output)
    shutil.copyfile(entries[0], output / 'installer-cpp.exe')
    shutil.copyfile(entries[0], output / 'installer.exe')
    for name in ('BUILD-INFO.json', f'PotPlayer-ChatGPT-Translate-v{info["version"]}-manual.zip'):
        shutil.copyfile(source / name, output / name)
    shutil.copyfile(report, output / 'SIGNATURES.json')
    (output / 'SIGNING-INFO.json').write_text(json.dumps({'source_commit': commit, 'policy': 'release-signing', 'scope': 'native-installer-only', 'request_id': request_id, 'request_url': request_url, 'unsigned_artifact_id': artifact_id, 'certificate_sha256': certificate_sha256}, indent=2) + '\n', encoding='utf-8')
    (output / 'SHA256SUMS').write_text(''.join(f'{digest(p)}  {p.name}\n' for p in sorted(output.iterdir())), encoding='ascii', newline='\n')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    for name in ('unsigned', 'signed', 'report', 'output'):
        p.add_argument('--' + name, type=Path, required=True)
    for name in ('commit', 'request-id', 'request-url', 'artifact-id', 'certificate-sha256'):
        p.add_argument('--' + name, required=True)
    a = p.parse_args()
    finish(a.unsigned, a.signed, a.report, a.output, a.commit, a.request_id, a.request_url, a.artifact_id, a.certificate_sha256)
