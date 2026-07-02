# Architecture

Agentic Workstation NixOS is a flake-packaged NixOS module plus a small host
initializer for existing NixOS machines.

```text
host initializer/template -> host flake -> NixOS module -> profile package bundle -> host rebuild
```

## Layers

| Layer | Responsibility |
| --- | --- |
| Rust CLI | Read-only planning and lockfile validation. |
| Flake packages | Build the CLI and validation helpers. |
| Dev shells | Provide reproducible contributor environments. |
| Host initializer | Create or refresh managed `flake.nix` and `agentic-workstation.nix` files for an existing host. |
| Flake templates | Provide copyable host-flake skeletons such as `orbstack-coding-agent`. |
| NixOS module | Map workstation profiles to Nixpkgs package bundles and NixOS service toggles. |
| Host flake | Own machine-specific configuration, secrets policy, users, hardware, and deployment. |

## Host Initialization

The `.#nixos-host-init` app is the smooth path for an existing host that already
has `configuration.nix`:

```bash
nix --extra-experimental-features 'nix-command flakes' run \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

It preserves the host's `configuration.nix`, writes managed workstation files,
updates the managed `agentic-workstation-nixos` lock input, and can run
`nixos-rebuild switch`. It does not own hardware, users, networking, secrets, or
other host-local declarations.

## NixOS Module

The module is exposed as:

```nix
agentic-workstation-nixos.nixosModules.default
agentic-workstation-nixos.nixosModules.agentic-workstation
```

It adds packages to `environment.systemPackages` and may enable NixOS-native services such as `programs.direnv` and `virtualisation.docker`.

## Boundaries

The module and initializer avoid Ubuntu-style workstation mutation. They do not:

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
