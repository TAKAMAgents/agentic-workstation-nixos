# Status

This page tracks NixOS edition reliability targets.

| Target | Current |
| --- | --- |
| NixOS module exported as `nixosModules.default` | Implemented |
| CLI package builds through flake | Implemented |
| Named dev shells evaluate | Implemented |
| `nix flake check` passes | Implemented |
| Sample NixOS toplevel evaluation | Covered by CI and nightly profile checks |
| Ubuntu Bash installer support | Out of scope for this edition |
| Cloud-init and Hetzner factory support | Out of scope for this edition |
| Remote installer audit | Out of scope for supported NixOS path |

Update this page when the module surface or CI guarantees change.
