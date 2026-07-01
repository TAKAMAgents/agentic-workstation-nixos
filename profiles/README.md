# Profile Files

The `profiles/*.env` files are retained for planner compatibility with the original Bash installer model.

For NixOS hosts, prefer the module option:

```nix
programs.agentic-workstation.profile = "coding-agent";
```

The NixOS module maps profile names to Nixpkgs package bundles in `nix/nixos-module.nix`. It does not execute the Bash installer modules described by these environment files.

Validate planner compatibility:

```bash
nix run . -- plan --profile coding-agent --json
```
