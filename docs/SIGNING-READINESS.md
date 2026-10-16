# Code signing policy — preparation status

This project does not currently claim approval by SignPath Foundation or an active
Foundation release certificate. Test signatures must not be advertised as trusted
release signatures. See the [Foundation conditions](https://signpath.org/terms).

A separate, opt-in [SignPath test-signing workflow](SIGNPATH-TEST-SIGNING.md) is
available for setup review. It uses only the `test-signing` policy and keeps test
outputs in clearly labelled Actions artifacts. Ordinary releases remain unsigned.

## Source and downloads

The canonical repository is https://github.com/Felix3322/PotPlayer_ChatGPT_Translate.
Download releases from its GitHub Releases page. Third-party tutorials are usage
references, not authoritative distribution channels or endorsements.

The release workflow builds from the checked-out revision using
`scripts/build_release.ps1`. `BUILD-INFO.json` records the source revision and staged
payload hashes; `SHA256SUMS` records asset hashes. These records assist inspection;
they do not replace SignPath origin verification or authenticate unsigned downloads.
Historical binaries under `releases/latest` and `releases/archive` are not inputs to
the current release build and must not be submitted as verified CI outputs.

## Privacy and system changes

Translation sends subtitle text, the selected model, and (in context mode) previous
subtitles to the configured API endpoint. Authentication sends the configured API
key to that endpoint. API verification also sends test requests; the Inno installer
can verify when advancing the configuration page, with a skip option. Local Ollama
endpoints keep processing local only when the endpoint actually runs locally.

Installer configuration can write the API key into the installed AngelScript file
as a plaintext default. Treat installed scripts, backups and diagnostic material as
potentially sensitive; do not share configured copies. Prefer HTTPS for remote
endpoints. Provider retention and billing depend on the selected provider: consult
[OpenAI](https://openai.com/policies/privacy-policy/),
[Google](https://policies.google.com/privacy), or your custom endpoint operator.
No claim is made here about the privacy behavior of PotPlayer itself.

Installers copy plugin files into the selected PotPlayer translation directory;
configuration-capable installers can modify script defaults. EXE installers can
register an uninstaller and write Windows uninstall registry entries. MSI supports
repair and uninstall through Windows Apps & Features. For manual installations,
close PotPlayer and delete only the installed variant's `.as` and `.ico` files.
Back up custom settings before replacing files or changing installer formats.

## Required before Foundation release signing

- Confirm the exact artifact scope with the application record.
- Record actual authors, reviewers and signing approvers; do not infer these roles
  from commit authorship. All team members need MFA for GitHub and SignPath.
- Verify the generated product-name and version metadata in the native and Python
  executables on Windows before configuring SignPath metadata restrictions.
- Review the licenses and notices of all bundled runtime components. PotPlayer is
  a separately installed host, not software this project should sign or bundle.
- Configure the SignPath GitHub integration, trusted origin verification, artifact
  selection, metadata restrictions and manual release approval. Restrict signing
  to authorized releases; do not submit arbitrary pull-request builds for release signing.
- Return the signed artifacts to the publication pipeline and recompute checksums
  after signing. Never publish test-signed builds as production releases.
- When service is actually active, add the required attribution: “Free code signing
  provided by SignPath.io, certificate by SignPath Foundation” and link this policy
  from release/download pages. That attribution is a future requirement, not a
  statement that service is currently provided.
