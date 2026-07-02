{
  # agentic-workstation-nixos:managed-host-flake
  description = "Agentic Workstation NixOS host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agentic-workstation-nixos.url = "github:TAKAMAgents/agentic-workstation-nixos";
  };

  outputs = { self, nixpkgs, agentic-workstation-nixos, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        agentic-workstation-nixos.nixosModules.default
        ./agentic-workstation.nix
      ];
    };
  };
}
