# Security

## Report Privately

Do not open public issues for:

- Credential leaks.
- Supply-chain compromise.
- Auth token exposure.
- Vulnerabilities in generated examples that could expose secrets.

Use GitHub private vulnerability reporting when available.

## Scope

In scope for this NixOS edition:

- NixOS module options.
- Generated host flake and module examples.
- `nixos-host-init` behavior that writes managed NixOS configuration files.
- Flake package definitions.
- Dev shell and CI validation.
- Documentation that could lead users to insecure host configuration.

Out of scope for this edition:

- Ubuntu apt installer behavior.
- cloud-init VM factory flows.
- Remote installer execution.

Those belong to `agentic-workstation-ubuntu`.

## Secret Handling

- Do not commit tokens, API keys, or service account files.
- Keep secrets out of flakes and NixOS modules.
- Use host-level secret management for declared secrets.
- Keep auth flows manual unless a dedicated secret-management integration is added.

## Supply Chain

- Review `flake.lock` updates.
- For generated hosts, `nixos-host-init` refreshes only the managed `agentic-workstation-nixos` input.
- Prefer Nixpkgs packages.
- Use explicit unfree package predicates instead of broad unfree enablement when practical.
- Keep package additions tied to a profile or documented option.
