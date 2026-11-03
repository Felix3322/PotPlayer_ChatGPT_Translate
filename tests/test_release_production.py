"""Offline checks for production-only packaging and release boundaries."""
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
from test_release_signing import TestSigningPackaging, COMMIT
import package_production_signing as production


class ProductionSigning(TestSigningPackaging):
    def test_production_gate_and_checksums(self):
        signed, report = self.make_signed()
        results = json.loads(report.read_text())
        results[0].update(windows_trust_status='Valid', signer_certificate_sha256='A' * 64)
        report.write_text(json.dumps(results))
        args = (self.unsigned, signed, report, self.root / 'production', COMMIT,
                '12345678-1234-1234-1234-123456789abc', 'https://app.signpath.io/request', '42')
        for fingerprint in ('B' * 64, '', 'test-signing'):
            with self.assertRaises(ValueError): production.finish(*args, fingerprint)
        results[0]['windows_trust_status'] = 'UnknownError'; report.write_text(json.dumps(results))
        with self.assertRaises(ValueError): production.finish(*args, 'A' * 64)
        results[0]['windows_trust_status'] = 'Valid'; report.write_text(json.dumps(results))
        production.finish(*args, 'A' * 64)
        out = args[3]
        self.assertFalse((out / 'TEST-SIGNING-ONLY.txt').exists())
        self.assertFalse((out / 'installer.msi').exists())
        self.assertEqual((out / 'installer.exe').read_bytes(), (out / 'installer-cpp.exe').read_bytes())
        for line in (out / 'SHA256SUMS').read_text().splitlines():
            checksum, name = line.split('  ')
            self.assertEqual(checksum, production.digest(out / name))

    def test_workflow_permission_boundaries(self):
        text = (ROOT / '.github/workflows/release.yml').read_text()
        sign = text.split('  sign:\n', 1)[1].split('\n  release:\n', 1)[0]
        self.assertIn("(github.event_name == 'push' || github.event_name == 'workflow_dispatch') && startsWith(github.ref, 'refs/tags/')", sign)
        self.assertIn('environment: signpath-production', sign)
        self.assertIn('secrets.SIGNPATH_PRODUCTION_API_TOKEN', sign)
        self.assertIn('signing-policy-slug: release-signing', sign)
        self.assertNotIn('contents: write', sign)
        self.assertIn('needs: sign', text.split('  release:\n', 1)[1])
        self.assertNotIn('SIGNPATH_PRODUCTION_API_TOKEN', (ROOT / '.github/workflows/signpath-test.yml').read_text())

if __name__ == '__main__': unittest.main()
