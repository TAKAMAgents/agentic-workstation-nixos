#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

failed=false
match_file="$(mktemp)"
trap 'rm -f "$match_file"' EXIT

check_absent() {
  local pattern=$1
  local message=$2

  if grep -RInE "$pattern" README.md commands.md docs CONTRIBUTING.md templates >"$match_file"; then
    echo "docs dx check failed: $message" >&2
    cat "$match_file" >&2
    failed=true
  fi
}

check_absent 'Stripe-style|maintained OrbStack' \
  "public docs should avoid internal/meta positioning language"
check_absent "cp /etc/nixos/configuration\\.nix \"\\\$tmpdir/configuration\\.nix\"" \
  "host-init validation docs must use a self-contained fixture or copy the full host directory"
check_absent '(^|[^-])nix run --refresh github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init' \
  "first-run GitHub initializer commands must include explicit Nix feature flags"
check_absent '(^|[^-])nix flake (init|update)' \
  "pre-switch Nix flake commands in docs must include explicit Nix feature flags or be described as post-switch shorthand"

if [[ "$failed" == "true" ]]; then
  exit 1
fi

echo "docs dx check passed"
