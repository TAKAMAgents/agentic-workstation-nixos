# Roadmap

## Current Features

- NixOS module exported as `nixosModules.default`.
- Profile-shaped package bundles.
- Optional Docker and direnv NixOS service integration.
- Rust CLI package and read-only planner.
- Reproducible dev shells and flake checks.

## Next Work

- Add module tests for each profile bundle.
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
