# Agentic Workstation NixOS

[![CI](https://github.com/hghalebi/agentic-workstation-nixos/actions/workflows/ci.yml/badge.svg)](https://github.com/hghalebi/agentic-workstation-nixos/actions/workflows/ci.yml)
[![Security](https://github.com/hghalebi/agentic-workstation-nixos/actions/workflows/security.yml/badge.svg)](https://github.com/hghalebi/agentic-workstation-nixos/actions/workflows/security.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![NixOS](https://img.shields.io/badge/NixOS-module-blue.svg)](docs/nix.md)

Build repeatable NixOS workstations for agentic software development.

This edition is a Nix flake and NixOS module. It installs the `agentic-workstation` planning CLI and profile-shaped package bundles through normal NixOS configuration.

The Ubuntu Bash installer, apt commands, cloud-init VM factory flow, and remote installer audit live in the separate Ubuntu edition:

```text
https://github.com/hghalebi/agentic-workstation-ubuntu
```

## Quick Start

Add the module to a NixOS flake:

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

Inspect the module example from a checkout:

```bash
nix --extra-experimental-features 'nix-command flakes' run .#nixos-module
```

## Module Options

Minimal module usage:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
};
```

Common options:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "factory";

  browserTools.enable = true;
  cloudTools.enable = true;
  onePassword.enable = false;
  docker.enable = true;
  direnv.enable = true;

  extraPackages = with pkgs; [
    terraform
  ];
};
```

Profiles currently accepted by the module:

| Profile | NixOS behavior |
| --- | --- |
| `minimal` | CLI, core shell tools, Git, jq, shell quality tools. |
| `base-image` | Same lightweight package bundle as `minimal`. |
| `coding-agent` | Default interactive coding package bundle. |
| `human-dev` | Same package class as `coding-agent` for larger human-operated machines. |
| `agent-runner` | Lean autonomous-agent package bundle. |
| `factory` | Coding bundle plus artifact and security tooling available in Nixpkgs. |
| `security` | Security review package bundle. |
| `local-llm` | Coding bundle plus local model runtime packages available in Nixpkgs. |
| `openclaw-server` | Server-oriented bundle; can enable Docker through NixOS. |

## Boundaries

This NixOS edition does:

- Install the Rust `agentic-workstation` CLI.
- Add profile-shaped package bundles to `environment.systemPackages`.
- Enable NixOS-native services such as Docker and direnv when requested.
- Provide reproducible dev shells and flake validation.

This NixOS edition does not:

- Run remote install scripts.
- Mutate shell dotfiles.
- Write `/var/lib/agentic-workstation/manifest.json`.
- Configure apt repositories.
- Render or apply cloud-init.
- Clone or hydrate workspaces.
- Automate service authentication.

Authentication remains explicit. After enabling the module, run login commands for the services you use, such as `gh auth login`, `op account add`, `gcloud auth login`, or `hcloud context create`.

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

Run the planning CLI:

```bash
nix --extra-experimental-features 'nix-command flakes' run . -- plan --profile coding-agent --json
nix --extra-experimental-features 'nix-command flakes' run . -- verify-lockfile
```

## Docs

- [docs/nix.md](docs/nix.md): NixOS module and flake workflows.
- [docs/architecture.md](docs/architecture.md): module architecture and boundaries.
- [docs/profiles.md](docs/profiles.md): profile-to-package-bundle mapping.
- [docs/use-cases.md](docs/use-cases.md): choosing module profiles.
- [docs/vm-lifecycle.md](docs/vm-lifecycle.md): version-controlled NixOS host lifecycle.
- [docs/auth.md](docs/auth.md): authentication commands and secret boundaries.
- [commands.md](commands.md): command reference for this edition.

## License

MIT. See [LICENSE](LICENSE).
