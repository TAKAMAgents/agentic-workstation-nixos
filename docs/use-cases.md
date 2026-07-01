# Use Cases

Choose the smallest NixOS profile that matches the machine's job.

## Interactive Coding Machine

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "coding-agent";
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
