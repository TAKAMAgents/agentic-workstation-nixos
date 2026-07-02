# Command Reference

This reference covers the NixOS edition. Ubuntu apt, cloud-init, and Bash installer commands live in `agentic-workstation-ubuntu`.

## Module Example

```bash
nix --extra-experimental-features 'nix-command flakes' run .#nixos-module
```

## Host Initialization

Create or refresh `/etc/nixos` from the published repo and switch. This is the
fast path for an existing NixOS coding host:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

From a checkout, use the local app:

```bash
nix --extra-experimental-features 'nix-command flakes' run .#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

Initialize only the files in the current directory:

```bash
nix --extra-experimental-features 'nix-command flakes' flake init \
  -t github:TAKAMAgents/agentic-workstation-nixos#orbstack-coding-agent
```

Refresh only the managed upstream input for a generated host flake:

```bash
nix --extra-experimental-features 'nix-command flakes' flake update agentic-workstation-nixos --flake /etc/nixos
```

After the generated module has been switched once, short `nix` commands are
acceptable because the host config enables `nix-command` and `flakes`.

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

For a generated `/etc/nixos` host:

```bash
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake /etc/nixos#nixos
```

From a separate host config flake that imports `agentic-workstation-nixos.nixosModules.default`:

```bash
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#workstation
```

Update the pinned module:

```bash
nix --extra-experimental-features 'nix-command flakes' flake update agentic-workstation-nixos
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#workstation
```
