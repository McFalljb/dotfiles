{
  description = "Example Linux Flake using Home Manager + NixGL + pinned binutils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ghostty, nixgl, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        nixgl.overlay
      ];
    };
  in
  {
    homeConfigurations.mcfalljb = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ({ config, pkgs, ... }: {
          # Simplified NixGL configuration to use system drivers
          nixGL.packages = nixgl.packages.${system};
          # nixGL.defaultWrapper = "nvidia"; # Use system NVIDIA drivers leave commented out
          nixGL.installScripts = [ ];

          home.username = "mcfalljb";
          home.homeDirectory = "/home/mcfalljb";
          home.stateVersion = "23.11";

          home.packages = with pkgs; [
            (config.lib.nixGL.wrap ghostty.packages.${system}.default)
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
            emscripten
            SDL2
            SDL2_mixer
            SDL2_ttf
            SDL2_image
            SDL2_gfx
            SDL2_net
            pkg-config
            cmake
            ninja
            valgrind
            gdb
          ];

          programs.zsh.enable = true;
          home.file.".zshrc".enable = false;
          home.file.".bashrc".enable = false;

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
        pkg-config
        cmake
        gcc
        binutils
        gdb
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
        SDL2
        SDL2_ttf
        SDL2_mixer
        SDL2_image
        SDL2_gfx
        SDL2_net
        libjack2
        alsa-lib
        pulseaudio
      ];

      shellHook = ''
        # Ensure Nix binaries come first in PATH
        export PATH="${pkgs.gcc}/bin:${pkgs.binutils}/bin:$PATH"
        
        # Force the compiler and linker paths
        export CC="${pkgs.gcc}/bin/gcc"
        export CXX="${pkgs.gcc}/bin/g++"
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