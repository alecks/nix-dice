#!/bin/bash

cleanup() {
  echo "Cleaning up..."
  rm -rf ~/.nix ~/.local/bin/nix-user-chroot ~/.local/bin/with-nix ~/.local/bin/enter-nix
  echo "Removed all directories and files added by this installation script. You may want to check your ~/.zshrc to revert any changes."
}

fail() {
  echo "FAIL: $1"
  cleanup
  exit 1
}

echo "This installer will add the with-nix and enter-nix scripts to your ~/.local/bin directory. It will then proceed to run the Nix installer, adding the relevant configurations to your ~/.zshrc."
echo ""

mkdir -p ~/.local/bin || fail "Couldn't create ~/.local/bin directory"
curl -L https://github.com/nix-community/nix-user-chroot/releases/download/1.2.2/nix-user-chroot-bin-1.2.2-x86_64-unknown-linux-musl -o ~/.local/bin/nix-user-chroot
# TODO: enter-nix and with-nix

ZSHRC="$HOME/.zshrc"
RC_NIX_SETUP='
# START NIX FOR DICE
export PATH="$HOME/.local/bin:$PATH"
# If we haven'\''t already asked to enter nix, ask.
if [[ -z "$DONE_NIX_CHECK" ]]; then
  exec enter-nix zsh "$@"
fi
# END NIX FOR DICE

'
touch "$ZSHRC"

if ! grep -q "exec enter-nix zsh" "$ZSHRC"; then
  # Prepend to zshrc
  echo "$RC_NIX_SETUP" | cat - "$ZSHRC" > "$ZSHRC.tmp" && mv "$ZSHRC.tmp" "$ZSHRC"
  echo "Nix setup successfully added to ~/.zshrc."
else
  echo "Nix setup already present in ~/.zshrc, skipping..."
fi

mkdir -m 0755 ~/.nix || fail "Couldn't to create ~/.nix directory"

echo "START OF NIX INSTALL SCRIPT"
~/.local/bin/nix-user-chroot ~/.nix bash -c "curl -L https://nixos.org/nix/install | bash" || fail "Nix install script failed."

echo ""
echo "DONE: Please restart your shell and enter zsh. You will be prompted to answer y/n to enter the Nix environment."
echo "You will then be able to use nix-env -i <package> to install packages. Refer to the Nix documentation for more info."
echo ""
echo "To enter the Nix environment every time without prompting, add the following to your .zshrc:"
echo "export BYPASS_NIX_CHECK=1"
echo ""
echo "To always enter the normal environment by default add the following:"
"export BYPASS_NIX_CHECK_NORMAL=1"
echo ""
echo "Then you can manually open a Nix shell by running with-nix zsh."
echo "Otherwise, you will be prompted every time."
