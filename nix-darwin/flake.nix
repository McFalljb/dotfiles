{
  description = "System Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.mkalias
          pkgs.vim
          pkgs.neovim
          pkgs.packer
          pkgs.terraform
          pkgs.nodejs_23
          pkgs.docker
          pkgs.jq
          pkgs.go
          pkgs.zig
          pkgs.tmux
          pkgs.lazydocker
          pkgs.obsidian
          pkgs.stow
        ];
      homebrew = {
          enable = true;
          brews = [
            "mas"
          ];
          casks = [
            "ghostty"
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
      };
      services.nix-daemon.enable = true;
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      nix.settings = {
        trusted-users = [ "@admin" "mcfalljb" ];  # Replace mcfalljb with your username if different
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mcfalljb
    darwinConfigurations."mcfalljb" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # Added this line
      modules = [
      configuration
      nix-homebrew.darwinModules.nix-homebrew
      {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "mcfalljb";
          };
        }
      ];

    };
    darwinPackages = self.darwinConfigurations."mcfalljb".pkgs;  # Fixed configuration(s)
  };
}
