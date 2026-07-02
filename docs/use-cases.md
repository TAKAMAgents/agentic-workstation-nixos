# Use Cases

Choose the smallest NixOS profile that matches the machine's job.

## Interactive Coding Machine

For an existing host, prefer the initializer:

```bash
nix --extra-experimental-features 'nix-command flakes' run \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

For manual flakes:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
};
```

## OrbStack Or LXC Coding Container

```bash
nix --extra-experimental-features 'nix-command flakes' run \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --switch
```

This path enables `containerCompatibility` automatically when OrbStack/LXC is
detected. For manual flakes:

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
  containerCompatibility.enable = true;
  docker.enable = false;
  onePassword.enable = false;
};
```

## Security Review Machine

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "security";
};
```

## Full Factory Machine

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "factory";
};
```

## Local Model Machine

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "local-llm";
};
```

## Server-Oriented Host

For existing NixOS hosts, generate the flake first and then edit
`agentic-workstation.nix`:

```bash
nix --extra-experimental-features 'nix-command flakes' run \
  github:TAKAMAgents/agentic-workstation-nixos#nixos-host-init -- \
  --target /etc/nixos \
  --profile openclaw-server \
  --docker
```

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "openclaw-server";
  docker.enable = true;
};
```

This installs server-oriented packages and enables Docker through NixOS. It does not create `/opt/openclaw`, write secrets templates, or install Ubuntu service files.

## Disposable Ubuntu VM Factory

Use the Ubuntu edition instead:

```text
https://github.com/TAKAMAgents/agentic-workstation-ubuntu
```
