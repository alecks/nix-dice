#!/bin/bash

if command -v nix-user-chroot 2>/dev/null; then
    exec nix-user-chroot ~/.nix "$@"
else
    echo "nix-user-chroot could not be found, continuing without Nix"
    exec "$@"
fi
