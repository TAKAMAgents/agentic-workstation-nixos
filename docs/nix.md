# NixOS Workflow

This repository is a Nix flake with three responsibilities:

- Package the `agentic-workstation` Rust CLI.
- Expose reproducible development shells and checks.
- Expose `nixosModules.default` for NixOS hosts.

It is not the Ubuntu installer edition. Use `agentic-workstation-ubuntu` for apt, cloud-init, and mutating Bash installs.

## NixOS Module

Import the module from a host flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agentic-workstation-nixos.url = "github:hghalebi/agentic-workstation-nixos";
  };

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

Apply the host:

```bash
sudo nixos-rebuild switch --flake .#workstation
```

Print a module import example:

```bash
nix --extra-experimental-features 'nix-command flakes' run .#nixos-module
```

## Options

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
  extraPackages = with pkgs; [ ];

  browserTools.enable = true;
  cloudTools.enable = true;
  onePassword.enable = true;
  factoryTools.enable = false;
  securityTools.enable = false;
  localModelRuntime.enable = false;
  docker.enable = false;
  direnv.enable = true;
};
```

Default boolean values are profile-dependent. For example, `coding-agent` enables browser, cloud, and 1Password packages; `factory` enables factory and security packages; `openclaw-server` enables Docker by default.

`_1password-cli` is unfree in Nixpkgs. Hosts that keep `onePassword.enable = true` must allow that package, for example:

```nix
{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
    ];
}
```

## Development Shells

```bash
nix --extra-experimental-features 'nix-command flakes' develop
nix --extra-experimental-features 'nix-command flakes' develop .#minimal
nix --extra-experimental-features 'nix-command flakes' develop .#coding-agent
nix --extra-experimental-features 'nix-command flakes' develop .#factory
nix --extra-experimental-features 'nix-command flakes' develop .#security
```

Dev shells are for repository work. They do not change the host system.

## Apps

```bash
nix --extra-experimental-features 'nix-command flakes' run . -- --help
nix --extra-experimental-features 'nix-command flakes' run .#plan -- --profile coding-agent
nix --extra-experimental-features 'nix-command flakes' run .#check
nix --extra-experimental-features 'nix-command flakes' run .#nixos-module
```

The `.#doctor`, `.#bootstrap-nix`, `.#e2e`, and `.#docker-smoke` apps remain available for compatibility with the shared source tree, but they are not the primary NixOS host-management path.

## Validation

Run:

```bash
nix --extra-experimental-features 'nix-command flakes' run .#check
nix --extra-experimental-features 'nix-command flakes' flake check
```

Evaluate a sample NixOS host:

```bash
nix --extra-experimental-features 'nix-command flakes' eval --impure --raw --expr "
let
  flake = builtins.getFlake \"path:$PWD\";
  nixpkgs = builtins.getFlake \"github:NixOS/nixpkgs/nixos-unstable\";
  system = \"aarch64-linux\";
  host = nixpkgs.lib.nixosSystem {
    inherit system;
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

## Boundary

Nix owns host package declaration, CLI packaging, and module evaluation. It deliberately does not own Ubuntu-style mutation such as apt repositories, shell dotfile edits, remote install scripts, manifests, cloud-init, or workspace hydration.
