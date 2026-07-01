# NixOS Host Lifecycle

This edition assumes the machine is managed by a version-controlled NixOS flake.

## 1. Import The Module

```nix
{
  inputs.agentic-workstation-nixos.url = "github:TAKAMAgents/agentic-workstation-nixos";

  outputs = { self, nixpkgs, agentic-workstation-nixos, ... }: {
    nixosConfigurations.workstation = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        agentic-workstation-nixos.nixosModules.default
        {
          programs.agentic-workstation = {
            enable = true;
            profile = "coding-agent";
          };
        }
      ];
    };
  };
}
```

## 2. Apply Changes

```bash
sudo nixos-rebuild switch --flake .#workstation
```

## 3. Commit The Machine State

```bash
git add flake.nix flake.lock configuration.nix
git commit -m "feat: enable agentic workstation profile"
```

## 4. Update The Module

```bash
nix flake update agentic-workstation-nixos
sudo nixos-rebuild switch --flake .#workstation
git add flake.lock
git commit -m "chore: update agentic workstation module"
```

## 5. Roll Back

Use normal NixOS rollback tools:

```bash
sudo nixos-rebuild switch --rollback
```

or select an older generation at boot when the host has a bootloader-managed generation menu.

## Ubuntu VM Factory

Cloud-init, snapshots, Hetzner VM creation, and workspace hydration are Ubuntu edition workflows.
