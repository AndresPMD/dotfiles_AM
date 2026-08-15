#!/usr/bin/env bash
# Install these dotfiles onto this machine.
# Idempotent: safe to re-run. Existing real files are backed up to *.bak-<timestamp>.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$1"; }

# Symlink $1 -> $2, backing up whatever is already at $2.
link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "    ok        $dest"
        return
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mv "$dest" "$dest.bak-$STAMP"
        echo "    backed up $dest -> $(basename "$dest").bak-$STAMP"
    fi
    ln -s "$src" "$dest"
    echo "    linked    $dest"
}

# ---------------------------------------------------------------- dependencies
info "Checking Homebrew packages"
if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew not found. Install it first: https://brew.sh"
    exit 1
fi

# yabai and skhd come from a personal tap, not homebrew-core.
if ! brew tap | grep -qx "asmvik/formulae"; then
    echo "    tapping   asmvik/formulae"
    brew tap asmvik/formulae
fi
brew trust asmvik/formulae 2>/dev/null || true

for pkg in yabai skhd tmux jq starship lazygit; do
    if brew list --formula "$pkg" >/dev/null 2>&1; then
        echo "    ok        $pkg"
    else
        echo "    installing $pkg"
        brew install "$pkg"
    fi
done

# font-hack-nerd-font moved from homebrew/cask-fonts into homebrew/cask; tap
# only as a fallback for older Homebrew.
for cask in karabiner-elements alacritty font-hack-nerd-font; do
    if brew list --cask "$cask" >/dev/null 2>&1; then
        echo "    ok        $cask"
    else
        echo "    installing $cask"
        brew install --cask "$cask" || {
            brew tap homebrew/cask-fonts 2>/dev/null || true
            brew install --cask "$cask"
        }
    fi
done

# ------------------------------------------------------------------- oh-my-zsh
info "Checking oh-my-zsh"
ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d "$ZSH_DIR" ]; then
    echo "    ok        oh-my-zsh"
else
    echo "    installing oh-my-zsh"
    # --keep-zshrc so the installer does not clobber the config we link below.
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended --keep-zshrc
fi

# These two are listed in zshrc's plugins=() but are NOT bundled with oh-my-zsh.
# Without them zsh prints "plugin not found" on every startup.
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
clone_plugin() {
    local url="$1" dir="$ZSH_CUSTOM/plugins/$2"
    if [ -d "$dir" ]; then
        echo "    ok        $2"
    else
        echo "    cloning   $2"
        git clone --depth 1 "$url" "$dir"
    fi
}
mkdir -p "$ZSH_CUSTOM/plugins"
clone_plugin https://github.com/zsh-users/zsh-autosuggestions      zsh-autosuggestions
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting  zsh-syntax-highlighting

# --------------------------------------------------------------------- symlink
info "Linking configs"
link "$DOTFILES/tmux.conf"            "$HOME/.tmux.conf"
link "$DOTFILES/zshrc"                "$HOME/.zshrc"
link "$DOTFILES/starship.toml"        "$HOME/.config/starship.toml"
link "$DOTFILES/yabairc"              "$HOME/.yabairc"
link "$DOTFILES/skhdrc"               "$HOME/.skhdrc"
# Alacritty reads .config/alacritty/alacritty.toml FIRST and .config/alacritty.toml
# only if that is absent — see the README note. Both are linked to mirror this
# machine exactly.
link "$DOTFILES/alacritty.toml"           "$HOME/.config/alacritty.toml"
link "$DOTFILES/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
link "$DOTFILES/scripts/tmux-gpu.sh"  "$HOME/.local/bin/tmux-gpu.sh"
link "$DOTFILES/scripts/tmux-vram.sh" "$HOME/.local/bin/tmux-vram.sh"
chmod +x "$DOTFILES/scripts/"*.sh "$DOTFILES"/*.sh

# Karabiner-Elements rewrites karabiner.json in place on every settings change,
# which clobbers a symlink. So this one is a copy, not a link.
info "Installing karabiner.json (copy — Karabiner overwrites symlinks)"
if pgrep -qx "Karabiner-Elements" 2>/dev/null; then
    warn "Karabiner-Elements is running; quit it or it will overwrite this file."
fi
mkdir -p "$HOME/.config/karabiner"
if [ -e "$HOME/.config/karabiner/karabiner.json" ]; then
    cp "$HOME/.config/karabiner/karabiner.json" \
       "$HOME/.config/karabiner/karabiner.json.bak-$STAMP"
    echo "    backed up existing karabiner.json"
fi
cp "$DOTFILES/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
echo "    copied    ~/.config/karabiner/karabiner.json"

# ---------------------------------------------------------------------- launchd
info "Installing launchd agents"
mkdir -p "$HOME/Library/LaunchAgents"
for plist in "$DOTFILES/launchd/"*.plist; do
    name="$(basename "$plist")"
    dest="$HOME/Library/LaunchAgents/$name"
    sed -e "s|__HOME__|$HOME|g" -e "s|__USER__|$(id -un)|g" "$plist" > "$dest"
    launchctl unload "$dest" 2>/dev/null || true
    launchctl load -w "$dest" 2>/dev/null || warn "could not load ${name%.plist}"
    echo "    loaded    ${name%.plist}"
done

# -------------------------------------------------------------------------- tpm
info "Installing tmux plugin manager"
if [ -x "$DOTFILES/clone_tpm.sh" ]; then
    "$DOTFILES/clone_tpm.sh"
else
    warn "clone_tpm.sh missing or not executable"
fi

cat <<'EOF'

Done. Remaining manual steps:

  1. Open Karabiner-Elements once and grant Input Monitoring in
     System Settings > Privacy & Security. Confirm "Default profile" is
     selected (caps_lock -> hyper).

  2. Grant Accessibility to yabai AND skhd in
     System Settings > Privacy & Security > Accessibility.

  3. Start tmux and press <prefix> + I (capital i) to install plugins.

  4. Copy ~/.secrets.zsh over from the other Mac BY HAND (scp/AirDrop, not
     git). zshrc sources it if present; without it those vars are silently unset.

  5. Space-switching hotkeys (hyper-1..9) require SIP to be partially
     disabled. See the README section "SIP and what does not work".

EOF
