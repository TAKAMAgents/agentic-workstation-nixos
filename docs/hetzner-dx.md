# Hetzner And VM Factory Boundary

This NixOS edition does not implement a Hetzner VM factory.

The old combined project included Ubuntu-focused helpers for:

- Rendering cloud-init.
- Creating Hetzner Cloud VMs.
- Building reusable Ubuntu base snapshots.
- Hydrating Git workspaces on first boot.

Those workflows belong to the Ubuntu edition:

```text
https://github.com/TAKAMAgents/agentic-workstation-ubuntu
```

For NixOS hosts on Hetzner, manage the machine with a host flake and normal
NixOS deployment tooling. If the host already has `configuration.nix`, the
initializer can create the workstation flake without enabling container
compatibility:

```bash
nix --extra-experimental-features 'nix-command flakes' run \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --no-container-compat
```

For manual host flakes, import this module and apply with:

```bash
sudo nixos-rebuild switch --flake .#host
```
