# Command Reference

This reference covers the NixOS edition. Ubuntu apt, cloud-init, and Bash installer commands live in `agentic-workstation-ubuntu`.

## Module Example

```bash
nix --extra-experimental-features 'nix-command flakes' run .#nixos-module
```

## Build And Run CLI

```bash
nix --extra-experimental-features 'nix-command flakes' build
./result/bin/agentic-workstation --help
nix --extra-experimental-features 'nix-command flakes' run . -- plan --profile coding-agent --json
nix --extra-experimental-features 'nix-command flakes' run . -- verify-lockfile
```

## Development Shells

```bash
nix --extra-experimental-features 'nix-command flakes' develop
nix --extra-experimental-features 'nix-command flakes' develop .#minimal
nix --extra-experimental-features 'nix-command flakes' develop .#coding-agent
nix --extra-experimental-features 'nix-command flakes' develop .#factory
nix --extra-experimental-features 'nix-command flakes' develop .#security
```

## Validation

```bash
nix --extra-experimental-features 'nix-command flakes' run .#check
nix --extra-experimental-features 'nix-command flakes' flake check
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-targets --all-features
```

## Host Apply

From a separate host config flake that imports `agentic-workstation-nixos.nixosModules.default`:

```bash
sudo nixos-rebuild switch --flake .#workstation
```

Update the pinned module:

```bash
nix flake update agentic-workstation-nixos
sudo nixos-rebuild switch --flake .#workstation
```
