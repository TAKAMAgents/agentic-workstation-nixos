# Agent Runner

The NixOS edition provides an `agent-runner` package profile, not an agent-runner service installer.

```nix
programs.agentic-workstation = {
  enable = true;
  profile = "agent-runner";
};
```

This profile installs a lean set of tools for autonomous agent machines. It does not:

- Create a systemd runner service.
- Clone a workspace.
- Write runner environment files.
- Manage secrets.

For the Ubuntu service scaffold and workspace hydration workflow, use:

```text
https://github.com/TAKAMAgents/agentic-workstation-ubuntu
```
