# Documentation Style

This repository optimizes for copy-pasteable NixOS operations.

The editorial model is Stripe-inspired: lead with the fastest successful path,
then show exactly what changed, then reveal deeper configuration.

## DX Contract

Every primary workflow should make the same promise:

1. Initialize or import the workstation module.
2. Review the generated or changed files.
3. Switch the host.
4. Update the pinned input.
5. Roll back with normal NixOS generations when needed.

## Command Rules

- First-run and pre-switch `nix` commands must include `--extra-experimental-features 'nix-command flakes'`.
- Short `nix` commands are acceptable only after text says the generated module has already been switched.
- Mutating commands must say what files or host state they change.
- Keep one canonical command for each workflow; link to `commands.md` instead of copying long variants.
- Validation recipes must use self-contained fixtures unless they explicitly copy a full host config directory.

## Copy Rules

- Put the fastest successful path before optional configuration.
- Explain generated state before deeper architecture.
- Keep public docs concrete and verifiable.
- Avoid internal status phrases such as "maintained host" in public docs.
- Keep Ubuntu installer, cloud-init, and VM factory workflows pointed at the Ubuntu edition.

## Required Checks

Run these before merging doc, initializer, or workflow changes:

```bash
./scripts/docs-dx-check.sh
./scripts/smoke-nixos-host-init.sh
```
