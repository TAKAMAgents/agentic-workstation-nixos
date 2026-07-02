# Commands

The canonical command reference is [../commands.md](../commands.md).

The supported NixOS path is:

```bash
nix --extra-experimental-features 'nix-command flakes' run \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
nix --extra-experimental-features 'nix-command flakes' run .#nixos-module
nix --extra-experimental-features 'nix-command flakes' run .#nixos-host-init -- --target /etc/nixos
nix --extra-experimental-features 'nix-command flakes' run .#check
nix --extra-experimental-features 'nix-command flakes' flake check
sudo nixos-rebuild switch --flake .#workstation
```

Use `agentic-workstation-ubuntu` for Ubuntu install commands.
