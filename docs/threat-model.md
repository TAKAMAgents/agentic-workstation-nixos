# Threat Model

This edition reduces host mutation by using NixOS declarations.

## Assets

- NixOS host configuration and `flake.lock`.
- Nix store paths built or fetched by the host.
- Service credentials managed outside this repository.
- User shell environment and authentication state.

## Main Risks

| Risk | Mitigation |
| --- | --- |
| Unreviewed package changes | Pin inputs in `flake.lock`; review `nix flake update` diffs. |
| Unfree package policy drift | Use explicit `allowUnfreePredicate` for packages such as `1password-cli`. |
| Secrets in host config | Keep tokens and credentials out of flakes and Git. |
| Accidental Ubuntu workflow use | Treat Bash/cloud-init scripts as compatibility material; use the NixOS module for hosts. |
| Overbroad package bundle | Choose the smallest profile and override package groups when needed. |

## Non-Goals

- Secrets management.
- Auth automation.
- Cloud-init generation.
- Imperative workstation mutation.

## Review Checklist

- Does the host flake pin this module through `flake.lock`?
- Are unfree packages explicitly allowed?
- Are secrets excluded from Git?
- Does the selected profile match the host role?
- Are extra packages declared in the host flake rather than installed manually?
