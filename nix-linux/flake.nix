{
  description = "Example Linux Flake using Home Manager + NixGL on non-NixOS (NVIDIA)";

  inputs = {
    # 1. Bring in an up-to-date nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # 2. Bring in Home Manager (following the same nixpkgs)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: Additional flakes; e.g. ghostty
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # 3. Bring in the nixGL flake (for non-NixOS GPU/OpenGL)
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ghostty, nixgl, ... }:
  let
    system = "x86_64-linux";

    # Inject the nixGL overlay so pkgs includes pkgs.nixGLNvidia, etc.
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
      overlays = [
        nixgl.overlay
      ];
    };
  in
  {
    homeConfigurations.mcfalljb = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      # The modules array is where we configure the user's Home Manager options
      modules = [
        ({ config, pkgs, ... }: {
          # Set up NixGL configuration
          nixGL.packages = nixgl.packages.${system};
          nixGL.defaultWrapper = "nvidia";
          nixGL.installScripts = [ "nvidia" ];

          home.username = "mcfalljb";
          home.homeDirectory = "/home/mcfalljb";
          home.stateVersion = "23.11";

          # Example of other packages in the user environment
          home.packages = with pkgs; [
            # Wrap GUI applications with NixGL
            (config.lib.nixGL.wrap ghostty.packages.${system}.default)
            # Keep other packages as is
            vim
            neovim
            packer
            terraform
            nodejs_23
            docker
            jq
            go
            zig
            tmux
            lazydocker
            obsidian
            stow
            fzf
            ripgrep
            lua54Packages.luarocks
            lua
            lazygit
            glfw
            zoxide
            home-manager
            zsh
          ];

          programs.zsh.enable = true;
          home.file.".zshrc".enable = false;
          home.file.".bashrc".enable = false;

          # Let the user environment have the new Nix CLI features
          nix = {
            package = pkgs.nix;
            settings = {
              experimental-features = [ "nix-command" "flakes" ];
              keep-outputs = true;
              keep-derivations = true;
              max-free = 1073741824;  # 1 GiB
              min-free = 262144000;   # 250 MB
              builders-use-substitutes = true;
              auto-optimise-store = true;
              max-jobs = "auto";
              substitute = true;
            };
          };
        })
      ];
    };
  };
}
