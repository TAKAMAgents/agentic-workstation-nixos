#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

if [[ "${NIX_CONFIG:-}" != *"flakes"* ]]; then
  if [[ -n "${NIX_CONFIG:-}" ]]; then
    export NIX_CONFIG="$NIX_CONFIG"$'\n''experimental-features = nix-command flakes'
  else
    export NIX_CONFIG="experimental-features = nix-command flakes"
  fi
fi

host_dir="$(mktemp -d)"
cleanup() {
  if [[ "${HOST_INIT_SMOKE_KEEP:-}" == "1" ]]; then
    echo "kept host fixture: $host_dir"
  else
    rm -rf "$host_dir"
  fi
}
trap cleanup EXIT

system="${HOST_INIT_SMOKE_SYSTEM:-$(nix eval --impure --raw --expr 'builtins.currentSystem')}"

cat >"$host_dir/configuration.nix" <<'NIX'
{ pkgs, ... }:

{
  boot.loader.grub.enable = false;
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };
  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "1password-cli" ];
}
NIX

nix run .#nixos-host-init -- \
  --target "$host_dir" \
  --host ci \
  --system "$system" \
  --source "path:$PWD" \
  --container-compat \
  --no-lock

nix flake check --no-build "$host_dir"
nix eval --impure --raw --expr "
let
  host = (builtins.getFlake \"path:$host_dir\").nixosConfigurations.ci;
in
if host.config.programs.agentic-workstation.containerCompatibility.enable
then \"ok\"
else throw \"container compatibility was not enabled\"
"
