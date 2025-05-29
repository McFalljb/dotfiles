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
          pkgs.stow
          pkgs.fzf
          pkgs.ripgrep
          pkgs.lua54Packages.luarocks
          pkgs.lua
          pkgs.lazygit
          pkgs.glfw
          pkgs.pkg-config
          pkgs.zellij
          pkgs.cmake
          pkgs.clang
          pkgs.devbox
          pkgs.kind
        ];
      homebrew = {
          enable = true;
          brews = [
            "mas"
            "zoxide"
            "sdl2"
            "sdl2_mixer"
            "sdl2_ttf"
            "sdl2_image"
            "sdl2_gfx"
            "sdl2_net"
            "btop"
          ];
          casks = [
            "ghostty"
            "obsidian"
            "blender"
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
      };
      # services.nix-daemon.enable = true;
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      nix.settings = {
        trusted-users = [ "@admin" "mcfalljb" ];
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#mcfalljb
    darwinConfigurations."mcfalljb" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
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
    darwinPackages = self.darwinConfigurations."mcfalljb".pkgs;
  };
}
