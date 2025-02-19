# Dotfiles

## Build linux

nix shell nixpkgs#home-manager
NIXPKGS_ALLOW_UNFREE=1 nix run home-manager/release-23.11 -- switch --impure --flake ~/dotfiles/nix-linux#mcfalljb

nix flake update

To run programs requring opengl
nix develop --impure /home/mcfalljb/dotfiles/nix-linux --command bash -c './build.sh watch'

### Regs

home-manager
nix package manager

## Build Macos

### Regs

nix-darwin
nix package manager
