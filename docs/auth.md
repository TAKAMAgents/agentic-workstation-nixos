# Authentication

The NixOS module installs tools. It does not authenticate them.

After applying a host configuration, run only the auth commands for services you use:

```bash
gh auth login
op account add
gcloud auth login --no-launch-browser
gcloud auth application-default login --no-launch-browser
hcloud context create default
hf auth login
```

Some tools may not be installed by a selected profile or may require `extraPackages`.

## Secret Boundaries

- Do not put tokens in `flake.nix`, NixOS modules, or committed config files.
- Prefer service-native credential stores.
- Keep `.env` files and rendered secrets out of Git.
- Use host-level secret tooling such as SOPS, agenix, or a managed secret store when secrets must be declared.

## Check Availability

```bash
command -v gh
command -v op
command -v gcloud
command -v hcloud
```

The Ubuntu edition includes a broader `scripts/auth-status.sh` helper. In this NixOS edition, host config should be the source of truth for what is installed.
