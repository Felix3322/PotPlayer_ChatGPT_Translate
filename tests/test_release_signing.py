"""Test signing boundaries without credentials, Windows, or the SignPath service."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import package_test_signing as signing

COMMIT = 'a' * 40


class TestSigningPackaging(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.unsigned = self.root / 'unsigned'
        self.unsigned.mkdir()
        for name in signing.INSTALLERS:
            (self.unsigned / name).write_bytes(b'MZ unsigned ' + name.encode())
        (self.unsigned / 'installer.exe').write_bytes((self.unsigned / 'installer-cpp.exe').read_bytes())
        (self.unsigned / 'PotPlayer-ChatGPT-Translate-v1.9.6-manual.zip').write_bytes(b'unchanged manual payload')
        (self.unsigned / 'BUILD-INFO.json').write_text(json.dumps({
            'version': '1.9.6', 'source_commit': COMMIT, 'source_dirty': False,
        }))
        self.checksums()

    def checksums(self):
        (self.unsigned / 'SHA256SUMS').write_text(''.join(
            f'{signing.digest(p)}  {p.name}\n' for p in sorted(self.unsigned.iterdir()) if p.name != 'SHA256SUMS'
        ))

    def test_prepare_selects_only_current_native_installer(self):
        output = self.root / 'input'
        signing.prepare(self.unsigned, output, COMMIT)
        self.assertEqual({p.name for p in output.iterdir()}, {'installer-cpp.exe'})
        for path in output.iterdir():
            self.assertEqual(path.read_bytes(), (self.unsigned / path.name).read_bytes())
        with self.assertRaises(ValueError):
            signing.prepare(self.unsigned, output, COMMIT)

    def test_rejects_wrong_commit_dirty_source_and_changed_files(self):
        with self.assertRaises(ValueError):
            signing.inspect_unsigned(self.unsigned, 'b' * 40)
        (self.unsigned / 'installer.msi').write_bytes(b'tampered')
        with self.assertRaises(ValueError):
            signing.inspect_unsigned(self.unsigned, COMMIT)
        self.checksums()
        path = self.unsigned / 'BUILD-INFO.json'
        info = json.loads(path.read_text()); info['source_dirty'] = True
        path.write_text(json.dumps(info)); self.checksums()
        with self.assertRaises(ValueError):
            signing.inspect_unsigned(self.unsigned, COMMIT)

    def test_rejects_unexpected_missing_and_duplicate_checksum_entries(self):
        manifest = self.unsigned / 'SHA256SUMS'
        original = manifest.read_text()
        for value in (original + original.splitlines()[0] + '\n', original.split('\n', 1)[1],
                      '0' * 64 + '  ../secret\n', '0' * 64 + '  installer-cpp.exe\n'):
            manifest.write_text(value)
            with self.subTest(value=value), self.assertRaises(ValueError):
                signing.inspect_unsigned(self.unsigned, COMMIT)
        manifest.write_text(original)
        (self.unsigned / 'old.exe').write_bytes(b'stale')
        with self.assertRaises(ValueError):
            signing.inspect_unsigned(self.unsigned, COMMIT)

    def make_signed(self):
        signed = self.root / 'signed'; signed.mkdir()
        report = self.root / 'signatures.json'
        results = []
        for name in signing.SIGNABLE:
            path = signed / name
            path.write_bytes((self.unsigned / name).read_bytes() + b' synthetic test signature')
            results.append({'file': name, 'integrity_verified': True,
                            'signer_thumbprint': 'synthetic fixture only', 'sha256': signing.digest(path)})
        report.write_text(json.dumps(results))
        return signed, report

    def finish(self, signed, report, output):
        signing.finish(self.unsigned, signed, report, output, COMMIT, 'test-request',
                       'https://app.signpath.io/test-request', '123')

    def test_finish_labels_test_outputs_restores_alias_and_rehashes(self):
        signed, report = self.make_signed()
        output = self.root / 'output'
        self.finish(signed, report, output)
        self.assertEqual((output / 'installer.exe').read_bytes(), (output / 'installer-cpp.exe').read_bytes())
        self.assertNotEqual((output / 'SHA256SUMS').read_bytes(), (self.unsigned / 'SHA256SUMS').read_bytes())
        notice = (output / 'TEST-SIGNING-ONLY.txt').read_text()
        self.assertIn('NOT A TRUSTED PRODUCTION RELEASE', notice)
        self.assertIn('Only the native installer-cpp.exe was submitted as one raw PE artifact', notice)
        self.assertIn('Python, Inno and MSI installers are not signed or included', notice)
        self.assertNotIn('Only the outer EXE/MSI files were signed', notice)
        info = json.loads((output / 'SIGNING-INFO.json').read_text())
        self.assertTrue(info['test_signing_only'])
        self.assertEqual(info['signing_scope'], 'native-installer-only')
        self.assertEqual(info['input_artifact_format'], 'raw-pe')
        self.assertEqual(info['signed_files'], ['installer-cpp.exe'])
        self.assertEqual({p.name for p in output.glob('*.exe')}, {'installer-cpp.exe', 'installer.exe'})
        self.assertFalse((output / 'installer.msi').exists())
        for line in (output / 'SHA256SUMS').read_text().splitlines():
            checksum, name = line.split('  ')
            self.assertEqual(checksum, hashlib.sha256((output / name).read_bytes()).hexdigest())
        for name in ('BUILD-INFO.json', 'PotPlayer-ChatGPT-Translate-v1.9.6-manual.zip'):
            self.assertEqual((output / name).read_bytes(), (self.unsigned / name).read_bytes())
        # The unsigned input bundle and its checksums are never changed.
        signing.inspect_unsigned(self.unsigned, COMMIT)

    def test_finish_rejects_unverified_unchanged_and_tampered_signed_files(self):
        signed, report = self.make_signed()
        results = json.loads(report.read_text())
        results[0]['integrity_verified'] = False
        report.write_text(json.dumps(results))
        with self.assertRaises(ValueError):
            self.finish(signed, report, self.root / 'out')
        results[0]['integrity_verified'] = True
        report.write_text(json.dumps(results))
        (signed / signing.SIGNABLE[0]).write_bytes(b'changed after verification')
        with self.assertRaises(ValueError):
            self.finish(signed, report, self.root / 'out')
        path = signed / signing.SIGNABLE[0]
        path.write_bytes((self.unsigned / path.name).read_bytes())
        results[0]['sha256'] = signing.digest(path)
        report.write_text(json.dumps(results))
        with self.assertRaises(ValueError):
            self.finish(signed, report, self.root / 'out')

    def test_finish_rejects_extra_missing_or_non_native_outputs(self):
        signed, report = self.make_signed()
        extra = signed / 'installer-python.exe'
        extra.write_bytes(b'unexpected signed installer')
        with self.assertRaises(ValueError):
            self.finish(signed, report, self.root / 'out')
        extra.unlink()
        native = signed / 'installer-cpp.exe'
        native.rename(signed / 'unexpected.exe')
        with self.assertRaises(ValueError):
            self.finish(signed, report, self.root / 'out')
        (signed / 'unexpected.exe').unlink()
        with self.assertRaises(ValueError):
            self.finish(signed, report, self.root / 'out')

    def test_finish_requires_one_native_signature_report_entry(self):
        signed, report = self.make_signed()
        original = json.loads(report.read_text())
        for results in ([], original * 2, original[0], [dict(original[0], file='installer-python.exe')]):
            report.write_text(json.dumps(results))
            with self.subTest(results=results), self.assertRaises(ValueError):
                self.finish(signed, report, self.root / 'out')

    def test_workflow_defaults_to_project_configuration_with_test_policy(self):
        # Guard the integration contract without adding a YAML dependency to CI.
        # actionlint separately validates the complete workflow syntax.
        workflow = (ROOT / '.github/workflows/signpath-test.yml').read_text()
        inputs = workflow.split('    inputs:', 1)[1].split('\npermissions:', 1)[0]
        self.assertIn('      artifact_configuration_slug:', inputs)
        self.assertIn('        required: false', inputs)
        self.assertIn("        default: ''", inputs)
        self.assertNotIn('default: test-installers', inputs)
        self.assertIn('          signing-policy-slug: test-signing', workflow)
        self.assertIn('          artifact-configuration-slug: ${{ inputs.artifact_configuration_slug }}', workflow)
        self.assertNotIn('ARTIFACT_CONFIGURATION', workflow)
        self.assertIn('if [[ -z "$SIGNPATH_API_TOKEN" ]]', workflow)
        upload = workflow.split('        id: unsigned', 1)[1].split('      - name: Submit', 1)[0]
        self.assertIn('actions/upload-artifact@cf430e030ddbb5b0abf93d22962f4752f3646cd9', upload)
        self.assertIn('          archive: false', upload)
        self.assertIn('          path: signing-input/installer-cpp.exe', upload)
        self.assertNotIn('          name:', upload)
        self.assertIn('          skip-decompress: true', workflow)
        self.assertIn('-ReportPath SIGNATURES.json -NativeOnly', workflow)

    def test_optional_zip_template_is_separate_from_native_review_scope(self):
        ns = {'s': 'http://signpath.io/artifact-configuration/v1'}
        tree = ET.parse(ROOT / '.signpath/test-installers.xml')
        archive = tree.getroot().find('s:zip-file', ns)
        self.assertIsNotNone(archive)
        self.assertEqual({item.attrib['path'] for item in archive}, set(signing.INSTALLERS) - {'installer.exe'})
        self.assertEqual(signing.SIGNABLE, ('installer-cpp.exe',))
        for item in archive:
            self.assertIsNotNone(item.find('s:authenticode-sign', ns))
            self.assertNotIn('*', item.attrib['path'])
            self.assertEqual(len(item), 1, 'Only outer files should be signed')


if __name__ == '__main__':
    unittest.main()
