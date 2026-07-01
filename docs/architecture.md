# Architecture

Agentic Workstation NixOS is a flake-packaged NixOS module.

```text
flake input -> NixOS module -> profile package bundle -> host rebuild
```

## Layers

| Layer | Responsibility |
| --- | --- |
| Rust CLI | Read-only planning and lockfile validation. |
| Flake packages | Build the CLI and validation helpers. |
| Dev shells | Provide reproducible contributor environments. |
| NixOS module | Map workstation profiles to Nixpkgs package bundles and NixOS service toggles. |
| Host flake | Own machine-specific configuration, secrets policy, users, hardware, and deployment. |

## NixOS Module

The module is exposed as:

```nix
agentic-workstation-nixos.nixosModules.default
agentic-workstation-nixos.nixosModules.agentic-workstation
```

It adds packages to `environment.systemPackages` and may enable NixOS-native services such as `programs.direnv` and `virtualisation.docker`.

## Boundaries

The module avoids imperative host mutation. It does not:

- Run curl-piped installers.
- Configure apt repositories.
- Edit `.bashrc`, `.zshrc`, or Git config.
- Write install manifests.
- Run auth flows.
- Render cloud-init.
- Clone or hydrate project workspaces.

Those behaviors belong to the Ubuntu edition.

## Compatibility Source

Some Bash scripts and cloud files remain in the source tree because the Rust planner, docs history, and validation harness were split from the original combined repository. They are compatibility material, not the supported NixOS installation interface.
