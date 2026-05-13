default:
    @just --list

# Builds and run the raspberry pi variant
run_minimal:
    nix run .#minimalist

# Builds and runs the full variant
run_full:
    nix run .#full

# Build raspberry pi variant
# and symlink to ./result
build_minimal:
    nix build .#minimalist

# Build full variant
# and symlink to ./result
build_full:
    nix build .#full

# Check the nix files
check:
    nix flake check

# This updates dependencies from nix store.
# You should also git fetch && git pull
update:
    nix flake update

# Garbage collect old build results
gc:
    rm -f result
    nix-collect-garbage -d

