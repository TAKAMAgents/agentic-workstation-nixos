# Agentic Workstation NixOS

[![CI](https://github.com/TAKAMAgents/agentic-workstation-nixos/actions/workflows/ci.yml/badge.svg)](https://github.com/TAKAMAgents/agentic-workstation-nixos/actions/workflows/ci.yml)
[![Security](https://github.com/TAKAMAgents/agentic-workstation-nixos/actions/workflows/security.yml/badge.svg)](https://github.com/TAKAMAgents/agentic-workstation-nixos/actions/workflows/security.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![NixOS](https://img.shields.io/badge/NixOS-module-blue.svg)](docs/nix.md)

Turn an existing NixOS machine into a reproducible agentic coding workstation.

This repository is the NixOS edition of Agentic Workstation. It provides:

- A NixOS module: `agentic-workstation-nixos.nixosModules.default`
- A host initializer: `.#nixos-host-init`
- A template for OrbStack/LXC coding hosts: `#orbstack-coding-agent`
- The `agentic-workstation` planning and lockfile validation CLI
- Reproducible dev shells and CI checks

The README follows a Stripe-style DX pattern: give the fastest working path
first, show exactly what state changes, then reveal deeper configuration options.

Ubuntu apt installs, cloud-init VM factory flows, remote installer audits, and
imperative shell mutation live in the Ubuntu edition:

```text
https://github.com/TAKAMAgents/agentic-workstation-ubuntu
```

## Quick Start

Run this on an existing NixOS host that already has `/etc/nixos/configuration.nix`:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

For OrbStack/LXC hosts, the initializer detects the container environment and
enables activation compatibility. To be explicit:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --container-compat \
  --switch
```

For bare-metal or VM NixOS hosts:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --no-container-compat \
  --switch
```

## What The Initializer Does

`nixos-host-init` makes the host reproducible without taking ownership of the
whole machine.

It does:

- Preserve the existing `/etc/nixos/configuration.nix`
- Write a managed `/etc/nixos/flake.nix`
- Write a managed `/etc/nixos/agentic-workstation.nix`
- Update only the managed `agentic-workstation-nixos` input in `flake.lock`
- Run `nixos-rebuild switch` when `--switch` is passed
- Back up unmanaged target files before replacement when `--force` is used

It does not:

- Rewrite users, networking, hardware, Incus, or OrbStack host files
- Store or request secrets
- Edit shell dotfiles or Git config
- Run curl-piped installers
- Clone or hydrate workspaces
- Configure apt repositories or cloud-init

## Generated Host Shape

The generated host flake imports the local host configuration, this upstream
module, and a small workstation module:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agentic-workstation-nixos.url = "github:TAKAMAgents/agentic-workstation-nixos";
  };

  outputs = { self, nixpkgs, agentic-workstation-nixos, ... }: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        agentic-workstation-nixos.nixosModules.default
        ./agentic-workstation.nix
      ];
    };
  };
}
```

The generated workstation module looks like this:

```nix
{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.agentic-workstation = {
    enable = true;
    profile = "coding-agent";

    containerCompatibility.enable = true;
    docker.enable = false;
    onePassword.enable = false;

    direnv.enable = true;
    browserTools.enable = true;
    cloudTools.enable = true;

    extraPackages = with pkgs; [
      neovim
      zellij
      nodejs_22
      git
      gh
      curl
      wget
      jq
      ripgrep
      fd
      bat
      eza
      htop
      just
      tmux
    ];
  };
}
```

## Choose Your Path

| Use case | Command |
| --- | --- |
| Existing NixOS host | `nix run --refresh github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- --target /etc/nixos --switch` |
| Existing OrbStack/LXC host | Add `--container-compat` |
| Existing bare-metal or VM host | Add `--no-container-compat` |
| Inspect files before switching | `nix flake init -t github:TAKAMAgents/agentic-workstation-nixos#orbstack-coding-agent` |
| Fully custom host flake | Import `agentic-workstation-nixos.nixosModules.default` manually |

## Manual Module Import

Use this when you already own a host flake and want direct control:

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

Apply it:

```bash
sudo nixos-rebuild switch --flake .#workstation
```

## Profiles

Profiles choose package bundles and a few NixOS-native service defaults.

| Profile | Behavior |
| --- | --- |
| `minimal` | CLI, core shell tools, Git, jq, and shell quality tools. |
| `base-image` | Same lightweight bundle as `minimal`. |
| `coding-agent` | Default interactive development bundle with runtimes, GitHub CLI, shells, data tools, and helpers. |
| `human-dev` | Human-operated development bundle, currently aligned with `coding-agent`. |
| `agent-runner` | Lean autonomous-agent package bundle. |
| `factory` | Coding bundle plus artifact and security tooling available in Nixpkgs. |
| `security` | Security review tooling such as Syft, Grype, Cosign, Trivy, Gitleaks, and Hadolint. |
| `local-llm` | Coding bundle plus local model runtime packages available in Nixpkgs. |
| `openclaw-server` | Server-oriented bundle; can enable Docker through NixOS. |

Set a profile with the initializer:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --profile factory \
  --switch
```

Or manually:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "factory";
};
```

## Important Options

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";

  browserTools.enable = true;
  cloudTools.enable = true;
  onePassword.enable = false;
  docker.enable = false;
  direnv.enable = true;
  containerCompatibility.enable = true;

  extraPackages = with pkgs; [
    terraform
  ];
};
```

`containerCompatibility.enable` is for OrbStack/LXC-style NixOS containers that
cannot mount debugfs or reliably reload D-Bus during activation.

`_1password-cli` is unfree in Nixpkgs. Hosts that set
`onePassword.enable = true` must allow that package explicitly.

## Update A Generated Host

Rerun the initializer:

```bash
nix --extra-experimental-features 'nix-command flakes' run --refresh \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

Or update the managed input directly:

```bash
nix flake update agentic-workstation-nixos --flake /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## Roll Back

Use normal NixOS rollback tools:

```bash
sudo nixos-rebuild switch --rollback
```

## Authentication

The module installs tools. It does not authenticate them.

After switching, log in only to services you use:

```bash
gh auth login
op account add
gcloud auth login --no-launch-browser
hcloud context create default
hf auth login
```

Keep tokens out of flakes, generated modules, and Git.

## Development

Open a dev shell:

```bash
nix --extra-experimental-features 'nix-command flakes' develop
```

Run checks:

```bash
nix --extra-experimental-features 'nix-command flakes' run .#check
nix --extra-experimental-features 'nix-command flakes' flake check
```

Run the CLI:

```bash
nix --extra-experimental-features 'nix-command flakes' run . -- plan --profile coding-agent --json
nix --extra-experimental-features 'nix-command flakes' run . -- verify-lockfile
```

## Documentation

- [docs/nix.md](docs/nix.md): NixOS workflow, initializer, templates, and module import.
- [docs/architecture.md](docs/architecture.md): layers, responsibilities, and boundaries.
- [docs/profiles.md](docs/profiles.md): profile-to-package-bundle mapping.
- [docs/use-cases.md](docs/use-cases.md): choosing profiles and entry points.
- [docs/vm-lifecycle.md](docs/vm-lifecycle.md): host initialization, updates, commits, and rollback.
- [docs/auth.md](docs/auth.md): authentication commands and secret boundaries.
- [commands.md](commands.md): command reference.

## License

MIT. See [LICENSE](LICENSE).
