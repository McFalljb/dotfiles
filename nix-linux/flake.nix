{
  description = "My Linux Flake using Home Manager on non-NixOS (Pop!_OS, Ubuntu, etc.)";

  inputs = {
    # Bring in Nixpkgs (unstable branch as an example)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Bring in Home Manager, referencing the same nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    sharedUserPackages = pkgs: [
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
      pkgs.fzf
      pkgs.ripgrep
      pkgs.lua54Packages.luarocks
      pkgs.lua
      pkgs.lazygit
      pkgs.glfw
    ];

    nixpkgs.config.allowUnfree = true;
    nix.settings.trusted-users = [ "@admin" "mcfaljb" ];
  in {
    homeManagerConfigurations.myLinuxUser =
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        modules = [
          {
            home.packages = sharedUserPackages pkgs;

            home.sessionVariables = {
              EDITOR = "vim";
              GIT_EDITOR = "vim";
              NODE_ENV = "development";
            };

            programs.zsh = {
              enable = true;
            };

            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          }
        ];
      };
  }
}
