#!/bin/sh

# Initialize an empty list/string to hold the combined result
combined="nix shell"

# Loop through every argument passed to the script
for arg in "$@"; do
    # Add nixpkgs# to the current argument
    nix_item="nixpkgs#$arg"
    
    # Combine or append them (here we space-separate them)
    combined="$combined $nix_item"
done
# Remove leading whitespace
combined=$(echo "$combined" | sed 's/^[[:space:]]*//')

# Output the result
echo "$combined"

