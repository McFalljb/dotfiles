{
  description = "Example Linux Flake using Home Manager + NixGL + pinned binutils";

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
          # nixGL.packages = nixgl.packages;
          # nixGL.defaultWrapper = "mesa";
          # nixGL.offloadWrapper = "nvidiaPrime";
          # nixGL.installScripts = [ "mesa" "nvidiaPrime" ];

          # programs.mpv = {
          #   enable = true;
          #   package = config.lib.nixGL.wrap pkgs.mpv;
          # };

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
            gh
            python314
            gcc
            imagemagick
            gimp
            aseprite
            blender
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
              substituters = [
                "https://cache.nixos.org"
                "https://nix-community.cachix.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
            };
          };
        })
      ];
    };

    # Development shell with OpenGL support
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        # Development tools
        pkg-config
        cmake
        gcc11
        binutils
        gdb

        # GL libraries
        nixgl.packages.${system}.nixGLNvidia
        glew
        glfw
        freeglut
        xorg.libX11
        xorg.libXrandr
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXi
        xorg.libXext
        xorg.libXxf86vm
        xorg.libXfixes
        libGL
        libGLU
      ];

      shellHook = ''
        # Ensure Nix binaries come first in PATH
        export PATH="${pkgs.gcc11}/bin:${pkgs.binutils}/bin:$PATH"
        
        # Force the compiler and linker paths
        export CC="${pkgs.gcc11}/bin/gcc"
        export CXX="${pkgs.gcc11}/bin/g++"
        export LD="${pkgs.binutils}/bin/ld"
        
        # Set up OpenGL environment with nixGL
        alias glxinfo="nixGLNvidia glxinfo"
        alias glxgears="nixGLNvidia glxgears"
        
        echo "Shell environment:"
        echo "  CC: $CC"
        echo "  CXX: $CXX"
        echo "  LD: $LD"
        echo "  GCC version: $($CC --version | head -n1)"
        echo "  DISPLAY: $DISPLAY"
        
        # Wrap the program with nixGL
        if [ -n "$1" ]; then
          exec nixGLNvidia "$@"
        fi
      '';
    };
  };
}
