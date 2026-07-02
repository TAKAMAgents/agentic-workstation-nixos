# OrbStack Coding Agent NixOS Host

This template turns an existing OrbStack/LXC-style NixOS host into an Agentic
Workstation coding machine.

It expects `configuration.nix` to already exist in the same directory. On
OrbStack, that file usually imports the generated Incus and OrbStack modules.

Apply it with:

```bash
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#nixos
```

The generated module enables the `coding-agent` profile, container activation
compatibility, browser/cloud tools, direnv, and common terminal packages.
