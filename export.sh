#!/usr/bin/env bash
# Pull the live configs on this machine back into the repo, ready to commit.
# Use this on whichever Mac you edited settings on, then commit + push.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

# Copy $1 -> $2 unless $1 is already a symlink into the repo.
grab() {
    local src="$1" dest="$2"
    if [ ! -e "$src" ]; then
        echo "    missing   $src (skipped)"
        return
    fi
    if [ -L "$src" ] && [[ "$(readlink "$src")" == "$DOTFILES"/* ]]; then
        echo "    linked    $src (already tracked)"
        return
    fi
    cp "$src" "$dest"
    echo "    copied    $src"
}

info "Collecting configs into $DOTFILES"
grab "$HOME/.tmux.conf"                        "$DOTFILES/tmux.conf"
grab "$HOME/.zshrc"                            "$DOTFILES/zshrc"
grab "$HOME/.config/starship.toml"             "$DOTFILES/starship.toml"
grab "$HOME/.yabairc"                          "$DOTFILES/yabairc"
grab "$HOME/.skhdrc"                           "$DOTFILES/skhdrc"
grab "$HOME/.config/alacritty.toml"            "$DOTFILES/alacritty.toml"
grab "$HOME/.config/alacritty/alacritty.toml"  "$DOTFILES/alacritty/alacritty.toml"
grab "$HOME/.config/karabiner/karabiner.json"  "$DOTFILES/karabiner.json"
grab "$HOME/.local/bin/tmux-gpu.sh"            "$DOTFILES/scripts/tmux-gpu.sh"
grab "$HOME/.local/bin/tmux-vram.sh"           "$DOTFILES/scripts/tmux-vram.sh"

info "Repo status"
git -C "$DOTFILES" status --short

cat <<'EOF'

Review the diff, then:

    git add -A && git commit -m "Update configs" && git push

Note: launchd plists under launchd/ are NOT auto-exported — the live copies
contain machine-specific paths, while the tracked ones are templated with
__HOME__ / __USER__. Edit those by hand if the agents change.
EOF
