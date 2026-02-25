---
# Release Notes - PSHVTools v1.1.4

Release date: 2026-02-01

This release marks `1.1.4` as the latest stable release. It focuses on improved backup cancellation cleanup, a module export fix, and refreshed documentation.

Highlights
- Backup: Ctrl+C now triggers reliable cleanup and stops run-scoped 7z processes before stopping jobs.
- Module: Removed the duplicate `Clone-VM` export definition.
- Docs: Updated command examples and installer guidance to match current parameters and filenames.

Changes
- Bumped internal installer stable marker: `MyAppLatestStableVersion` → `1.1.4` (`installer/PSHVTools-Installer.iss`).
- Updated release notes in `scripts/pshvtools.psd1`.
- Documentation updates in `docs/README.md`, `docs/QUICKSTART.md`, `docs/CHANGELOG.md`, and `docs/installer/INNO_SETUP_INSTALLER.md`.

How to publish this release
- Preferred (interactive): run the release helper locally with the `gh` CLI installed and authenticated:

  powershell -ExecutionPolicy Bypass -File installer\Publish-GitHubRelease.ps1

- Non-interactive (REST API): set an environment variable `GITHUB_TOKEN` with a token that has `repo` permissions and run the script on a machine with network access.

Preview/WhatIf

To preview actions without publishing:

  powershell -ExecutionPolicy Bypass -File installer\Publish-GitHubRelease.ps1 -WhatIf

For full changelog details, see `docs/CHANGELOG.md`.

---
