# Roadmap

## Current Features

- NixOS module exported as `nixosModules.default`.
- Reproducible host initializer exported as `.#nixos-host-init`.
- OrbStack/LXC coding-agent template exported as `#orbstack-coding-agent`.
- Profile-shaped package bundles.
- Container activation compatibility for OrbStack/LXC-style NixOS hosts.
- Optional Docker and direnv NixOS service integration.
- Rust CLI package and read-only planner.
- Reproducible dev shells and flake checks.

## Next Work

- Add module tests for each profile bundle.
- Add a NixOS test that exercises `nixos-host-init` against a generated host fixture.
- Document exact package membership per profile in generated form.
- Add a NixOS VM test once the module grows service behavior.
- Split legacy Ubuntu compatibility files out of this repo when no longer needed for planner parity.
- Add examples for Home Manager, agenix, and SOPS integration.

## Non-Goals

- apt repository management.
- Remote installer execution.
- cloud-init rendering.
- Workspace cloning or hydration.
- Dotfile mutation.
- Authentication automation.

Use `agentic-workstation-ubuntu` for Ubuntu VM factory workflows.
