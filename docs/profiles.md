# Profiles

Profiles in this edition are NixOS package bundle selectors. They approximate the original workstation roles with packages available in Nixpkgs.

Use a profile:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
};
```

## Available Profiles

| Profile | NixOS module behavior |
| --- | --- |
| `minimal` | Core CLI/shell/Git tools plus shell quality checks. |
| `base-image` | Same lightweight bundle as `minimal`; useful for shared base declarations. |
| `coding-agent` | Default interactive development bundle: runtimes, GitHub CLI, shells, data tools, and helpers. |
| `human-dev` | Human-operated development bundle, currently aligned with `coding-agent`. |
| `agent-runner` | Lean autonomous runtime bundle without browser or broad factory extras by default. |
| `factory` | Coding bundle plus artifact and security tooling available in Nixpkgs. |
| `security` | Security review tools such as Syft, Grype, Cosign, Trivy, Gitleaks, and Hadolint. |
| `local-llm` | Coding bundle plus local model runtime packages available in Nixpkgs. |
| `openclaw-server` | Server-oriented bundle; enables Docker by default through NixOS when `docker.enable` is left at its profile default. |

## Option Overrides

Profile defaults can be overridden:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
  onePassword.enable = false;
  docker.enable = true;
  extraPackages = with pkgs; [ terraform ];
};
```

## Differences From Ubuntu Profiles

The Ubuntu edition runs modules such as `base`, `docker`, `cloud`, `config`, `workspace`, and `manifest` imperatively. The NixOS edition does not run those modules. It translates profile intent into Nix declarations only.

The Rust CLI can still render read-only plans:

```bash
nix run . -- plan --profile coding-agent --json
```

Treat those plans as compatibility/planning output, not as the NixOS module implementation.
