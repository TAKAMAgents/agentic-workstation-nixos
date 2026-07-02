# Release Pipeline

This edition uses Release Please for the NixOS flake/module repository.

## Automated Flow

1. Conventional commits land on `main`.
2. Release Please opens or updates a release PR.
3. Merging the release PR updates `CHANGELOG.md`, bumps versions, and creates a GitHub release/tag.

## Version Policy

- Patch: documentation fixes, package list corrections, CI fixes.
- Minor: new module options, initializer behavior, profile behavior changes, new templates, or new package groups.
- Major: incompatible option names, profile removals, initializer behavior that rewrites broader host state, or changed default behavior with broad host impact.

## Manual Pre-release Checks

```bash
nix --extra-experimental-features 'nix-command flakes' run .#check
nix --extra-experimental-features 'nix-command flakes' flake check
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-targets --all-features
```

Evaluate a sample host when module options changed:

```bash
nix --extra-experimental-features 'nix-command flakes' eval --impure --raw --expr "
let
  flake = builtins.getFlake \"path:$PWD\";
  nixpkgs = builtins.getFlake \"github:NixOS/nixpkgs/nixos-unstable\";
  host = nixpkgs.lib.nixosSystem {
    system = \"aarch64-linux\";
    modules = [
      flake.nixosModules.default
      {
        boot.loader.grub.enable = false;
        fileSystems.\"/\" = {
          device = \"none\";
          fsType = \"tmpfs\";
        };
        system.stateVersion = \"26.05\";
        nixpkgs.config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [ \"1password-cli\" ];
        programs.agentic-workstation.enable = true;
      }
    ];
  };
in
host.config.system.build.toplevel.drvPath
"
```

Test host initialization behavior when `nixos-host-init` or templates changed:

```bash
tmpdir="$(mktemp -d)"
cp /etc/nixos/configuration.nix "$tmpdir/configuration.nix"
nix --extra-experimental-features 'nix-command flakes' run .#nixos-host-init -- \
  --target "$tmpdir" \
  --source "path:$PWD" \
  --container-compat \
  --no-lock
nix --extra-experimental-features 'nix-command flakes' flake check --no-build "$tmpdir"
```
