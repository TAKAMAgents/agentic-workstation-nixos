# Remote Installer Policy

The supported NixOS module path does not run remote installer scripts.

Packages should come from:

- Nixpkgs.
- The local Rust package built by this flake.
- Explicit `extraPackages` in the host configuration.

The source tree still contains some legacy Ubuntu scripts split from the original combined repository. They are kept for compatibility and validation history, but they are not the NixOS installation interface.

Use the Ubuntu edition for remote installer audit policy:

```text
https://github.com/TAKAMAgents/agentic-workstation-ubuntu
```
