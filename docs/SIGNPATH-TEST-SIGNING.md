# SignPath test signing / 测试签名

This is an opt-in, manual test for the Foundation setup review. It does **not**
enable production signing, publish a GitHub Release, or establish Foundation
approval. A test certificate is not a publicly trusted release certificate.

## One-time setup / 首次配置

1. In GitHub, add the repository Actions secret **`SIGNPATH_API_TOKEN`** under
   **Settings → Secrets and variables → Actions**. Enter the token there only;
   never put its value in source, workflow inputs, issues, or logs.
2. In SignPath, confirm these exact values (project slug capitalization matters):
   - Organization: `a92b315d-b2eb-4998-ae95-5e23493e69d9`
   - Project: `PotPlayer_Chatgpt_Translate`
   - Signing policy: `test-signing`, using the **test certificate**
   - The token's user must be a **Submitter** for that policy. An API token by
     itself does not grant submitter permission.
3. Create an artifact configuration with slug **`test-installers`**, using
   [the complete XML](../.signpath/test-installers.xml). If you already have an
   equivalent configuration, enter its actual slug when running the workflow.
   This repository file is a template; committing it does not configure SignPath.
4. Link the project's trusted build system to **GitHub.com** and the canonical
   repository. Complete any SignPath GitHub App installation/access steps required
   by your SignPath setup. These are account/access changes for the maintainer;
   the workflow does not grant them. See [official GitHub integration setup](https://docs.signpath.io/trusted-build-systems/github).
5. Review and merge the workflow change into `master` before the first manual run.
   GitHub requires a `workflow_dispatch` workflow on the default branch to show
   **Run workflow**. This document does not authorize merging or changing branch
   protection, signing policy permissions, or production certificates.

中文要点：把令牌仅保存为 GitHub Actions 机密 `SIGNPATH_API_TOKEN`；确认令牌所属用户
是 `test-signing` 的 Submitter，并且该策略使用测试证书。在 SignPath 新建
`test-installers` 制品配置，完整粘贴本仓库 XML，并关联 GitHub 可信构建来源。
代码合并到 `master` 后才能首次从 Actions 页面手动运行。

## Run and collect review evidence / 运行与审核材料

1. Open **Actions → SignPath test signing → Run workflow**.
2. Select the reviewed source branch (normally `master`). Leave the artifact
   configuration as `test-installers`, unless you configured an equivalent slug.
3. The workflow runs the same source builds, regression tests, executable metadata
   checks, MSI lifecycle tests, and signature-verifier fixture tests as release CI.
   It never reads historical binaries under `releases/latest` or `releases/archive`.
4. It uploads a new unsigned GitHub Actions artifact, then submits that artifact ID
   through the official SignPath action. GitHub supplies origin information;
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

The unsigned GitHub artifact is a ZIP containing four files at its root:

- `installer-cpp.exe`: current native installer
- `installer-python.exe`: current Python/PyInstaller installer
- `installer-inno.exe`: current Inno installer
- `installer.msi`: current MSI package

The XML requires these exact files and restricts the three EXEs to the expected
product name. Only the **outer** files receive Authenticode signatures. It does
not independently sign embedded Python/runtime components, MSI custom actions,
Inno uninstallers, PotPlayer, the manual ZIP, or `.as`/`.ico` files. Production
deep-signing scope must be agreed separately with SignPath.

After signing, `installer.exe` is copied from the signed `installer-cpp.exe` so
the aliases stay identical. The unsigned manual ZIP and source `BUILD-INFO.json`
are carried over unchanged. The original unsigned artifact is never modified,
and its pre-signing checksums are never reused for signed outputs.

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
unsigned, content-tampered EXE/MSI and signature-tampered EXE failures. These local
fixtures do not contact SignPath. Actual service, token, policy, origin and XML
acceptance are tested only by a real manual SignPath run.

This workflow has read-only repository permissions, no release-upload step, no
tag/push/PR signing trigger, and no configurable production policy. PR CI builds
and tests without the SignPath secret. Production releases keep the existing
unsigned behavior. See [signing readiness](SIGNING-READINESS.md).

## Troubleshooting

- Missing secret: add `SIGNPATH_API_TOKEN` in GitHub Actions secrets, then rerun.
- Forbidden/submitter error: verify the token's user is a submitter on the exact
  project and `test-signing` policy; do not broaden production access.
- Unknown artifact configuration or file mismatch: compare the selected slug and
  XML to `.signpath/test-installers.xml`. The outer uploaded container is a ZIP.
- Origin error: verify the SignPath project's GitHub trusted-build integration
  and GitHub App access required by your setup. Do not bypass origin checks by
  switching to a direct upload.
- Signature verification failure: inspect the diagnostic `SIGNATURES.json`.
  Never mark an unsigned, changed, or unverifiable file as successfully signed.

References: [SignPath artifact configurations](https://docs.signpath.io/artifact-configuration/),
[configuration syntax](https://docs.signpath.io/artifact-configuration/syntax),
[project/submitter setup](https://docs.signpath.io/projects),
[Microsoft SignedCms](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.pkcs.signedcms.checksignature),
[WinVerifyTrust](https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust).
