# Contributing

## Set Up

```bash
nix --extra-experimental-features 'nix-command flakes' develop
```

## Validate

```bash
nix --extra-experimental-features 'nix-command flakes' run .#check
nix --extra-experimental-features 'nix-command flakes' flake check
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-targets --all-features
```

When changing the NixOS module, also evaluate a sample host:

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

## Change Rules

- Keep NixOS module behavior declarative.
- Do not add remote installer execution to the module.
- Do not store secrets in examples.
- Prefer Nixpkgs packages over ad hoc downloads.
- Keep Ubuntu VM factory documentation in the Ubuntu edition.

## Pull Requests

- Explain the profile or module behavior changed.
- Include validation commands run.
- Update docs when options, defaults, or supported profiles change.
