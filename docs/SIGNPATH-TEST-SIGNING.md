# SignPath test signing / 测试签名

This is an opt-in, manual test for the Foundation setup review. It does **not**
enable production signing, publish a GitHub Release, or establish Foundation
approval. A test certificate is not a publicly trusted release certificate.

**Current review scope: the native `installer-cpp.exe` only.** Python, Inno and
MSI installers are still built/tested, but are not signed by this workflow and
are not included in its test-signed bundle.

## One-time setup / 首次配置

1. In GitHub, add the repository Actions secret **`SIGNPATH_API_TOKEN`** under
   **Settings → Secrets and variables → Actions**. Enter the token there only;
   never put its value in source, workflow inputs, issues, or logs.
2. In SignPath, use these configured identifiers:
   - Organization: `a92b315d-b2eb-4998-ae95-5e23493e69d9`
   - Project: `PotPlayer_Chatgpt_Translate`
   - Signing policy: `test-signing`, using the **test certificate**
   - The token's user must be a **Submitter** for that policy. An API token by
     itself does not grant submitter permission.
3. Keep the existing **`test-signing` signing policy** and default artifact
   configuration with a top-level **`<pe-file>`**. Leave the workflow's optional
   artifact configuration input **empty**. The workflow uploads the native EXE
   as one raw GitHub artifact (`archive: false`), not a ZIP, matching that existing
   configuration without changing any SignPath settings. Signing-policy and
   artifact-configuration slugs are separate: `test-signing` remains the policy.
   No new `test-installers` configuration is required. The repository's optional
   [four-installer ZIP template](../.signpath/test-installers.xml) is **not used**
   by this native-only workflow; do not apply it for this run.
4. Link the project's trusted build system to **GitHub.com** and the canonical
   repository. Complete any SignPath GitHub App installation/access steps required
   by your SignPath setup. These are account/access changes for the maintainer;
   the workflow does not grant them. See [official GitHub integration setup](https://docs.signpath.io/trusted-build-systems/github).
5. Review and merge the workflow change into `master` before the first manual run.
   GitHub requires a `workflow_dispatch` workflow on the default branch to show
   **Run workflow**. This document does not authorize merging or changing branch
   protection, signing policy permissions, or production certificates.

中文要点：把令牌仅保存为 GitHub Actions 机密 `SIGNPATH_API_TOKEN`；确认令牌所属用户
是 `test-signing` 的 Submitter，并且该策略使用测试证书。继续使用已有的
`test-signing` 签名策略；运行时将可选的制品配置输入留空，使用项目默认配置。
不必先创建 `test-installers`。签名策略 slug 和制品配置 slug 是两个不同字段。
本次仅提交原生 `installer-cpp.exe`，以原始 EXE 格式匹配已有的 `<pe-file>` 默认配置，
不再上传四文件 ZIP；无需修改 SignPath 设置。Python、Inno、MSI 不在本次签名范围内。
项目需关联 GitHub 可信构建来源，代码合并到 `master` 后才能首次手动运行。

## Run and collect review evidence / 运行与审核材料

1. Open **Actions → SignPath test signing → Run workflow**.
2. Select the reviewed source branch (normally `master`). Leave
   `artifact_configuration_slug` **empty** to use the project's default. Supply
   an override only if you know the slug of an appropriate existing artifact
   configuration. The signing policy remains fixed at **`test-signing`**.
3. The workflow runs the same source builds, regression tests, executable metadata
   checks, MSI lifecycle tests, and signature-verifier fixture tests as release CI.
   It never reads historical binaries under `releases/latest` or `releases/archive`.
4. It uploads the current native EXE using the pinned official
   `actions/upload-artifact` v7 with **`archive: false`**, then submits that GitHub
   artifact ID through the official SignPath action. In raw mode GitHub uses the
   filename `installer-cpp.exe` as the artifact name, regardless of the `name`
   input. The SignPath action uses **`skip-decompress: true`** to download the
   signed PE unchanged. GitHub supplies origin information;
   merely uploading a locally built file with `Submit-SigningRequest` is not a
   substitute for this trusted-build integration.
5. If your test policy requires approval, open the signing request in SignPath and
   approve it there. The job waits up to 20 minutes for signing. A timeout is not
   evidence of success; inspect the request before retrying.
6. On success, save the Actions run URL, SignPath signing request URL from the job
   summary, and **`TEST-ONLY-signpath-<commit>`** artifact. The artifact contains
   `SIGNING-INFO.json`, `SIGNATURES.json`, `TEST-SIGNING-ONLY.txt`, and freshly
   calculated `SHA256SUMS`. Actions artifacts expire after 14 days.
7. Confirm the signer certificate fingerprint in `SIGNATURES.json` matches the
   test certificate shown in SignPath. Provide the run/request links for setup
   review. A green run is not a promise that Foundation will approve the project.

中文：运行完成后保留 Actions 运行链接、SignPath 签名请求链接和
`TEST-ONLY-signpath-<commit>` 文件。核对 `SIGNATURES.json` 中的证书指纹与
SignPath 测试证书一致。这些材料用于审核，测试包不要作为正式版本发布。

## Exact artifact scope

The signing input is exactly one source-built, checksum-checked native PE:
**`installer-cpp.exe`**. It is uploaded without a ZIP wrapper. The project default
`<pe-file><authenticode-sign /></pe-file>` configuration signs that outer file.
The workflow does not change the configuration, signing policy, or permissions.

The signed response must contain exactly `installer-cpp.exe`; additional,
missing or renamed files fail validation. After cryptographic verification,
`installer.exe` is copied from it so the native aliases stay identical.
The test bundle also contains the unchanged unsigned manual ZIP and source
`BUILD-INFO.json`, plus test-only notices, signature/provenance reports and new
checksums. It **does not contain** Python, Inno or MSI installers. The complete
unsigned `release-assets-<commit>` artifact remains separate and unchanged.

This is a native-installer integration test, not evidence of signing all package
formats or embedded components. The optional four-installer ZIP XML is retained
only as a separate reference for a future explicitly configured multi-file flow.

## Verification and trust boundaries

The Windows verifier checks the embedded CMS signature cryptography with
`SignedCms.CheckSignature(true)` and the Authenticode-covered file digest with
`WinVerifyTrust` in hash-only mode. It supports one primary signature, rejects
nested signatures, and imports no certificates into Windows trust stores.
Ordinary Windows trust status is recorded separately, including any untrusted
root error. That status is never treated as a substitute for integrity checks.
An expected signer is established by comparing its fingerprint to SignPath,
not merely by the certificate's display name.

CI exercises freshly signed, untrusted in-memory test-certificate fixtures plus
unsigned, content-tampered EXE/MSI and signature-tampered EXE failures. It also
checks the native-only verifier and rejects extra files. On pull requests, CI
uploads a real native PE with `archive: false`, downloads it with a pinned
`actions/download-artifact` v8 and `skip-decompress: true`, and compares its exact
SHA-256 digest and PE header. This proves raw GitHub transport without contacting
SignPath or using its secret. Actual SignPath acceptance and signature download
are tested only by a real manual SignPath run.

This workflow has read-only repository permissions, no release-upload step, no
tag/push/PR signing trigger, and no configurable production policy. PR CI builds
and tests without the SignPath secret. Production releases keep the existing
unsigned behavior. See [signing readiness](SIGNING-READINESS.md).

## Troubleshooting

- Missing secret: add `SIGNPATH_API_TOKEN` in GitHub Actions secrets, then rerun.
- Forbidden/submitter error: verify the token's user is a submitter on the exact
  project and `test-signing` policy; do not broaden production access.
- Unknown artifact configuration: remove an unintended override to use the
  project default, or confirm the actual artifact configuration slug. Do not put
  the signing policy slug in this field unless it is also a real configuration.
- File/configuration mismatch: this workflow requires the existing single-PE
  configuration, not the optional ZIP template. Confirm the unsigned artifact is
  `installer-cpp.exe` and the upload step reports raw mode (`archive: false`).
  If the error names the old `signpath-test-unsigned-<commit>.zip`, it is an older
  workflow revision: start a new run on the corrected `master` after merge.
  Do not change policy or credential permissions to work around a format error.
- Origin error: verify the SignPath project's GitHub trusted-build integration
  and GitHub App access required by your setup. Do not bypass origin checks by
  switching to a direct upload.
- Signature verification failure: inspect the diagnostic `SIGNATURES.json`.
  Never mark an unsigned, changed, or unverifiable file as successfully signed.

References: [GitHub raw artifact upload](https://github.com/actions/upload-artifact#upload-an-individual-file-unzipped),
[SignPath action inputs and default configuration](https://docs.signpath.io/trusted-build-systems/github#action-input-parameters),
[SignPath artifact configurations](https://docs.signpath.io/artifact-configuration/),
[configuration syntax](https://docs.signpath.io/artifact-configuration/syntax),
[project/submitter setup](https://docs.signpath.io/projects),
[Microsoft SignedCms](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.pkcs.signedcms.checksignature),
[WinVerifyTrust](https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust).
