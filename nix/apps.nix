{ pkgs, src, agenticWorkstation, checkScript, dockerSmokeScript, e2eScript }:

let
  planScript = pkgs.writeShellApplication {
    name = "agentic-workstation-plan";
    runtimeInputs = [ agenticWorkstation ];
    text = ''
      set -euo pipefail
      exec agentic-workstation plan "$@"
    '';
  };

  doctorScript = pkgs.writeShellApplication {
    name = "agentic-workstation-doctor";
    runtimeInputs = with pkgs; [
      bash
      jq
    ];
    text = ''
      set -euo pipefail
      exec bash ${src}/scripts/doctor.sh "$@"
    '';
  };

  bootstrapNixScript = pkgs.writeShellApplication {
    name = "agentic-workstation-bootstrap-nix";
    runtimeInputs = with pkgs; [
      bash
      coreutils
      curl
      git
      gnugrep
    ];
    text = ''
      set -euo pipefail
      exec bash ${src}/scripts/bootstrap-nix.sh "$@"
    '';
  };

  nixosModuleScript = pkgs.writeShellApplication {
    name = "agentic-workstation-nixos-module";
    runtimeInputs = with pkgs; [
      coreutils
    ];
    text = ''
      set -euo pipefail
      cat <<'USAGE'
Add this flake module to a NixOS host:

{
  inputs.agentic-workstation.url = "github:TAKAMAgents/agentic-workstation-nixos";

  outputs = { self, nixpkgs, agentic-workstation, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        agentic-workstation.nixosModules.default
        {
          programs.agentic-workstation = {
            enable = true;
            profile = "coding-agent";
          };
        }
      ];
    };
  };
}
USAGE
    '';
  };

  app = program: description: {
    type = "app";
    inherit program;
    meta.description = description;
  };
in
{
  apps = {
    bootstrap = app "${bootstrapNixScript}/bin/agentic-workstation-bootstrap-nix" "Install Nix when needed, clone the repo, build the CLI, and realize checks.";
    bootstrap-nix = app "${bootstrapNixScript}/bin/agentic-workstation-bootstrap-nix" "Alias for the Nix bootstrap app.";
    check = app "${checkScript}/bin/agentic-workstation-check" "Run repository static checks and Bats unit tests.";
    default = app "${agenticWorkstation}/bin/agentic-workstation" "Run the Agentic Workstation CLI.";
    docker-smoke = app "${dockerSmokeScript}/bin/agentic-workstation-docker-smoke" "Build Ubuntu Docker smoke-test images.";
    doctor = app "${doctorScript}/bin/agentic-workstation-doctor" "Run host readiness checks.";
    e2e = app "${e2eScript}/bin/agentic-workstation-e2e" "Run the Nix bootstrap end-to-end smoke test.";
    nixos-module = app "${nixosModuleScript}/bin/agentic-workstation-nixos-module" "Print a NixOS module import example.";
    plan = app "${planScript}/bin/agentic-workstation-plan" "Render an install plan with the Agentic Workstation CLI.";
  };
}
