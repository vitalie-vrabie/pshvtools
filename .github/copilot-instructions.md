# Copilot Instructions

## Project Guidelines
- WIP releases should not be marked stable; the installer warning must fire unless explicitly marked stable.
- Compaction should be applied to the exported image (backup) rather than the original VM, except when the VM is not running at export time, in which case the VM disks can be compacted before export.
