{ pkgs, ... }:

{
  # agentic-workstation-nixos:managed-host-module
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.agentic-workstation = {
    enable = true;
    profile = "coding-agent";

    containerCompatibility.enable = true;
    docker.enable = false;
    onePassword.enable = false;

    direnv.enable = true;
    browserTools.enable = true;
    cloudTools.enable = true;

    extraPackages = with pkgs; [
      neovim
      zellij
      nodejs_22
      git
      gh
      curl
      wget
      jq
      ripgrep
      fd
      bat
      eza
      htop
      just
      tmux
    ];
  };
}
