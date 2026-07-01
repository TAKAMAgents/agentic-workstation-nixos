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

For NixOS hosts on Hetzner, manage the machine with a host flake and normal NixOS deployment tooling. Import this module from that host flake and apply with:

```bash
sudo nixos-rebuild switch --flake .#host
```
