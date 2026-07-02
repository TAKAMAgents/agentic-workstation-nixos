# NixOS Workflow

This repository is a Nix flake with five responsibilities:

- Package the `agentic-workstation` Rust CLI.
- Expose reproducible development shells and checks.
- Expose `nixosModules.default` for NixOS hosts.
- Expose `.#nixos-host-init` for existing-host setup.
- Expose host flake templates for inspectable setup.

It is not the Ubuntu installer edition. Use `agentic-workstation-ubuntu` for apt, cloud-init, and mutating Bash installs.

## NixOS Host Workflow

### Smooth Host Initialization

On an existing NixOS host that already has `configuration.nix`, create or
refresh a managed Agentic Workstation host flake:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

By default the initializer:

- Detects the host name and CPU system.
- Preserves the existing `configuration.nix`.
- Writes managed `flake.nix` and `agentic-workstation.nix` files.
- Enables the `coding-agent` profile.
- Enables container activation compatibility when OrbStack/LXC is detected.
- Updates the managed `agentic-workstation-nixos` lock input.
- Runs `nixos-rebuild switch` when `--switch` is passed.

If `flake.nix` or `agentic-workstation.nix` already exists and was not created
by this tool, rerun with `--force` to back it up and replace it.

For manual setup, initialize the OrbStack coding-agent template in a directory
that already contains `configuration.nix`:

```bash
nix --extra-experimental-features 'nix-command flakes' flake init \
  -t github:TAKAMAgents/agentic-workstation-nixos#orbstack-coding-agent
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#nixos
```

### Manual Module Import

Import the module from a host flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agentic-workstation-nixos.url = "github:TAKAMAgents/agentic-workstation-nixos";
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
sudo env NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild switch --flake .#workstation
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
  containerCompatibility.enable = false;
};
```

Default boolean values are profile-dependent. For example, `coding-agent` enables browser, cloud, and 1Password packages; `factory` enables factory and security packages; `openclaw-server` enables Docker by default.

Enable `containerCompatibility` for OrbStack/LXC-style NixOS containers that cannot mount debugfs or reliably reload D-Bus during activation:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
  containerCompatibility.enable = true;
};
```

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
nix --extra-experimental-features 'nix-command flakes' run .#nixos-host-init -- --target /etc/nixos
nix --extra-experimental-features 'nix-command flakes' run .#nixos-module
```

`.#nixos-host-init` is the primary host-management helper for existing NixOS
machines. The `.#doctor`, `.#bootstrap-nix`, `.#e2e`, and `.#docker-smoke` apps
remain available for compatibility with the shared source tree, but they are not
the primary NixOS host-management path.

## Templates

```bash
nix --extra-experimental-features 'nix-command flakes' flake init \
  -t github:TAKAMAgents/agentic-workstation-nixos#orbstack-coding-agent
```

Templates are useful when you want to inspect or commit the generated files
before switching. They expect an existing `configuration.nix` in the target
directory.

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
