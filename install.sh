#!/bin/bash

cleanup() {
  echo "Cleaning up..."
  rm -rf ~/.nix ~/.local/bin/nix-user-chroot ~/.local/bin/with-nix ~/.local/bin/enter-nix
  echo "Removed all directories and files added by this installation script. You may want to check your ~/.zshrc to revert any changes."
}

fail() {
  echo "FAIL: $1"
  echo "You may need to remove ~/.nix and check ~/.zshrc if the installation is incomplete."
  exit 1
}

hardfail() {
  cleanup
  fail "$1"
}

echo "This installer will add the with-nix and enter-nix scripts to your ~/.local/bin directory. It will then proceed to run the Nix installer, adding the relevant configurations to your ~/.zshrc."
echo ""

mkdir -p ~/.local/bin || hardfail "Couldn't create ~/.local/bin directory."
declare -A files=(
    ["https://github.com/nix-community/nix-user-chroot/releases/download/1.2.2/nix-user-chroot-bin-1.2.2-x86_64-unknown-linux-musl"]="$HOME/.local/bin/nix-user-chroot"
    ["https://github.com/alecks/nix-dice/raw/refs/heads/main/with-nix.sh"]="$HOME/.local/bin/with-nix"
    ["https://github.com/alecks/nix-dice/raw/refs/heads/main/enter-nix.sh"]="$HOME/.local/bin/enter-nix"
)

for url in "${!files[@]}"; do
    dest="${files[$url]}"
    curl -L "$url" -o "$dest" || fail "Download failed for $url"
    chmod +x "$dest"
done

ZSHRC="$HOME/.zshrc"
RC_NIX_SETUP='
# START NIX FOR DICE
export PATH="$HOME/.local/bin:$PATH"
# If we haven'\''t already asked to enter nix, ask.
if [[ -z "$DONE_NIX_CHECK" ]]; then
  exec enter-nix zsh
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

mkdir -p -m 0755 ~/.nix || hardfail "Couldn't to create ~/.nix directory"

echo "START OF NIX INSTALL SCRIPT"
~/.local/bin/nix-user-chroot ~/.nix bash -c "curl -L https://nixos.org/nix/install | bash" || fail "Nix install script failed."

cat <<EOF

DONE: Nix for DICE has been installed. Please restart your shell and enter zsh. You will be prompted to answer y/n to enter the Nix environment.

You will then be able to use:
  nix-env -i <package>   # to install packages
  nix-shell -p <package> # to try out a package in a temporary environment
Refer to the Nix documentation for more info.

To enter the Nix environment every time without prompting, add this to the top of your .zshrc:
  export BYPASS_NIX_CHECK=1

To always enter the normal environment by default, add:
  export BYPASS_NIX_CHECK_NORMAL=1

Then, you can manually open a Nix shell by running:
  with-nix zsh

EOF

