{ self }:

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.agentic-workstation;
  system = pkgs.stdenv.hostPlatform.system;
  cliPackage = self.packages.${system}.default;

  basePackages = with pkgs; [
    bash
    curl
    fd
    fzf
    git
    git-lfs
    gnugrep
    gnumake
    jq
    lsof
    ncdu
    ripgrep
    tmux
    unzip
    wget
    zip
  ];

  runtimePackages = with pkgs; [
    cargo
    gcc
    go
    nodejs
    python3
    rustc
    rustfmt
    rustup
    uv
  ];

  qualityPackages = with pkgs; [
    actionlint
    bats
    pre-commit
    shellcheck
    shfmt
    yamllint
  ];

  dataPackages = with pkgs; [
    dnsutils
    hyperfine
    postgresql
    redis
    sqlite
  ];

  helperPackages = with pkgs; [
    delta
    duf
    gh
    just
    mise
    yq
    zellij
  ];

  browserPackages = lib.optionals cfg.browserTools.enable (with pkgs; [
    playwright-driver
  ]);

  cloudPackages = lib.optionals cfg.cloudTools.enable (with pkgs; [
    google-cloud-sdk
    hcloud
  ]);

  onePasswordPackages = lib.optionals cfg.onePassword.enable (with pkgs; [
    _1password-cli
  ]);

  factoryPackages = lib.optionals cfg.factoryTools.enable (with pkgs; [
    age
    ffmpeg
    imagemagick
    pandoc
    poppler-utils
    tesseract
    tree
  ]);

  securityPackages = lib.optionals cfg.securityTools.enable (with pkgs; [
    cosign
    gitleaks
    grype
    hadolint
    syft
    trivy
  ]);

  localModelPackages = lib.optionals cfg.localModelRuntime.enable (with pkgs; [
    ollama
  ]);

  profilePackages = {
    minimal = basePackages ++ qualityPackages;
    base-image = basePackages ++ qualityPackages;
    coding-agent = basePackages ++ runtimePackages ++ qualityPackages ++ dataPackages ++ helperPackages;
    human-dev = basePackages ++ runtimePackages ++ qualityPackages ++ dataPackages ++ helperPackages;
    agent-runner = basePackages ++ runtimePackages ++ qualityPackages ++ helperPackages;
    factory = basePackages ++ runtimePackages ++ qualityPackages ++ dataPackages ++ helperPackages ++ factoryPackages ++ securityPackages;
    security = basePackages ++ runtimePackages ++ qualityPackages ++ dataPackages ++ helperPackages ++ securityPackages;
    local-llm = basePackages ++ runtimePackages ++ qualityPackages ++ helperPackages ++ localModelPackages;
    openclaw-server = basePackages ++ runtimePackages ++ qualityPackages ++ dataPackages ++ helperPackages;
  };
in
{
  options.programs.agentic-workstation = {
    enable = lib.mkEnableOption "Agentic Workstation NixOS package bundle";

    package = lib.mkOption {
      type = lib.types.package;
      default = cliPackage;
      defaultText = lib.literalExpression "self.packages.\${pkgs.stdenv.hostPlatform.system}.default";
      description = "Agentic Workstation CLI package to install.";
    };

    profile = lib.mkOption {
      type = lib.types.enum (builtins.attrNames profilePackages);
      default = "coding-agent";
      description = "Agentic Workstation profile to approximate with NixOS packages.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install with the selected profile.";
    };

    browserTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem cfg.profile [ "coding-agent" "human-dev" "factory" ];
      defaultText = lib.literalExpression ''true for "coding-agent", "human-dev", and "factory"'';
      description = "Install browser automation support available from Nixpkgs.";
    };

    cloudTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem cfg.profile [ "coding-agent" "human-dev" "factory" "openclaw-server" ];
      defaultText = lib.literalExpression ''true for "coding-agent", "human-dev", "factory", and "openclaw-server"'';
      description = "Install cloud CLIs available from Nixpkgs.";
    };

    onePassword.enable = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem cfg.profile [ "coding-agent" "human-dev" "factory" "openclaw-server" ];
      defaultText = lib.literalExpression ''true for "coding-agent", "human-dev", "factory", and "openclaw-server"'';
      description = "Install the 1Password CLI from Nixpkgs.";
    };

    factoryTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem cfg.profile [ "factory" ];
      defaultText = lib.literalExpression ''true for "factory"'';
      description = "Install artifact and factory helper tools available from Nixpkgs.";
    };

    securityTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem cfg.profile [ "factory" "security" ];
      defaultText = lib.literalExpression ''true for "factory" and "security"'';
      description = "Install security review tools available from Nixpkgs.";
    };

    localModelRuntime.enable = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem cfg.profile [ "local-llm" ];
      defaultText = lib.literalExpression ''true for "local-llm"'';
      description = "Install local model runtime packages available from Nixpkgs.";
    };

    docker.enable = lib.mkOption {
      type = lib.types.bool;
      default = lib.elem cfg.profile [ "openclaw-server" ];
      defaultText = lib.literalExpression ''true for "openclaw-server"'';
      description = "Enable Docker through the NixOS virtualisation module.";
    };

    direnv.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable direnv through the NixOS programs module.";
    };

    containerCompatibility.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Apply OrbStack/LXC-friendly activation workarounds by suppressing
        debugfs mounting and avoiding D-Bus reloads during NixOS switches.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages =
        [ cfg.package ]
        ++ profilePackages.${cfg.profile}
        ++ browserPackages
        ++ cloudPackages
        ++ onePasswordPackages
        ++ cfg.extraPackages;

      programs.direnv.enable = lib.mkIf cfg.direnv.enable true;
      virtualisation.docker.enable = lib.mkIf cfg.docker.enable true;
    }

    (lib.mkIf cfg.containerCompatibility.enable {
      systemd.suppressedSystemUnits = [
        "sys-kernel-debug.mount"
      ];
      systemd.services.dbus = {
        reloadIfChanged = lib.mkForce false;
        restartIfChanged = lib.mkForce false;
      };
      systemd.services."dbus-broker" = {
        reloadIfChanged = lib.mkForce false;
        restartIfChanged = lib.mkForce false;
      };
      systemd.user.services.dbus = {
        reloadIfChanged = lib.mkForce false;
        restartIfChanged = lib.mkForce false;
      };
      systemd.user.services."dbus-broker" = {
        reloadIfChanged = lib.mkForce false;
        restartIfChanged = lib.mkForce false;
      };
    })
  ]);
}
