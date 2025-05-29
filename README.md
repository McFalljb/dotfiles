# Dotfiles

## Build Macos

### Initial Setup
```bash
# Install nix-darwin for the first time
nix run nix-darwin -- switch --flake ~/dotfiles/nix-darwin
```

### Regular Operations
```bash
# Update flake inputs
nix flake update

# Apply configuration changes
darwin-rebuild switch --flake ~/dotfiles/nix-darwin

# Build without applying (dry run)
darwin-rebuild build --flake ~/dotfiles/nix-darwin

# Check what would change
darwin-rebuild build --flake ~/dotfiles/nix-darwin --show-trace
```

### Debugging & Maintenance
```bash
# Rollback to previous generation
darwin-rebuild rollback

# List system generations
nix-env --list-generations --profile /nix/var/nix/profiles/system

# Garbage collect old generations
sudo nix-collect-garbage -d

# Check homebrew status (managed by nix-darwin)
brew list
brew outdated

# Verify nix-darwin service
sudo launchctl list | grep nix-daemon
```
