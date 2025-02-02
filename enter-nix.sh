#!/bin/bash

# Tell the shell we've already checked, so it doesn't call us again.
export DONE_NIX_CHECK=1

# If we are already in the nix environment or the user wants to bypass to the normal environment, bypass.
if [[ -n "$BYPASS_NIX_CHECK_NORMAL" ]] || [[ -d "$HOME/.nix-profile" ]]; then
    exec "$@"
    exit 0
fi

# If the user doesn't want to bypass, continue.
if [[ -z "$BYPASS_NIX_CHECK" ]]; then
    echo "Would you like to enter the Nix environment? (Y/n)"
    read -r response

    case "$response" in
        [nN]*)
            echo "Staying in the normal environment."
            exec "$@"
            exit 0
            ;;
        *)
            echo "Entering the Nix environment..."
            ;;
    esac
fi

export IN_NIX=1
exec nix-user-chroot ~/.nix "$@"
