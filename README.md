# Dotfiles

macOS window management and terminal config: Karabiner-Elements, yabai, skhd,
tmux, zsh, starship.

## Layout

```
karabiner.json              caps_lock -> hyper (cmd+ctrl+opt+shift)
yabairc                     yabai tiling: layout, gaps, per-app float rules
skhdrc                      all the hyper-key window bindings
tmux.conf                   catppuccin status bar, CPU/RAM/GPU readout, plugins
zshrc                       shell config
starship.toml               prompt (see caveat below — not currently loaded)
alacritty.toml              terminal: Hack Nerd Font, colours, opacity
alacritty/alacritty.toml    shift+return binding (takes precedence — see caveat)
scripts/                    tmux-gpu.sh, tmux-vram.sh (status bar helpers)
launchd/                    user agents that keep yabai and skhd running at login
install.sh                  repo -> machine
export.sh                   machine -> repo (run before committing changes)
clone_tpm.sh                fetches the tmux plugin manager
runme.sh                    shim to install.sh
```

Not tracked, deliberately: `~/.secrets.zsh` (tokens — copy it by hand) and
`~/.config/nvim`.

## Install on a new Mac

```bash
git clone https://github.com/AndresPMD/dotfiles_AM.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs the Homebrew deps, symlinks the configs, writes the launchd
agents with this machine's `$HOME` substituted in, and clones TPM. It backs up
anything it would overwrite to `*.bak-<timestamp>` and is safe to re-run. It is
path-relative, so the clone directory can be named anything.

**yabai and skhd come from the personal tap `asmvik/formulae`**
(https://github.com/asmvik/homebrew-formulae), not homebrew-core. `install.sh`
taps and trusts it automatically. Versions in use: yabai 7.1.25, skhd 0.3.9,
tmux 3.7b, jq 1.8.2.

`install.sh` also handles the things `zshrc` needs but does not ship:
oh-my-zsh, the `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins
(listed in `plugins=()` but *not* bundled with oh-my-zsh — zsh errors on every
startup without them), `starship`, `lazygit`, and `font-hack-nerd-font`
(without it the tmux status bar and prompt render as tofu boxes).

Then, by hand:

1. **Karabiner-Elements** — launch it once, grant Input Monitoring under
   System Settings > Privacy & Security, and check that "Default profile" is
   selected. This is what turns caps_lock into hyper; without it every `hyper -`
   binding in `skhdrc` is dead.
2. **Accessibility** — grant it to *both* yabai and skhd under
   System Settings > Privacy & Security > Accessibility.
3. **tmux** — start a session and press `prefix` + `I` (capital i) to install plugins.
4. **`~/.secrets.zsh`** — copy it across by hand (scp/AirDrop, never git).
   `zshrc` sources it if present. A missing file is silent — the variables
   are just unset.

## Config caveats

**Alacritty loads only one of the two files.** The documented search order is
`$XDG_CONFIG_HOME/alacritty/alacritty.toml`, then `$XDG_CONFIG_HOME/alacritty.toml` —
first match wins, and there is no implicit merge. So `alacritty/alacritty.toml`
(the shift+return binding) shadows `alacritty.toml` (fonts, colours, opacity),
which means the big config is probably not being applied. Both are tracked here
so the second Mac mirrors the first exactly rather than silently diverging. To
actually load both, add `import = ["~/.config/alacritty.toml"]` to the top of
`alacritty/alacritty.toml`, or fold the binding into the main file and delete
the directory one.

**Starship is installed but not loaded.** `starship.toml` is tracked and
`install.sh` installs the binary, but `zshrc` sets `ZSH_THEME="robbyrussell"`
and has no `starship init` line. Add `eval "$(starship init zsh)"` at the end
of `zshrc` (and clear `ZSH_THEME`) if you want the prompt back.

## Pushing changes back

Edit configs in place at their normal paths, then:

```bash
cd ~/dotfiles && ./export.sh
git add -A && git commit -m "Update configs" && git push
```

Everything except `karabiner.json` is symlinked, so `export.sh` is mostly a
no-op for those — it exists because Karabiner-Elements rewrites its JSON in
place and would clobber a symlink.

## SIP and what does not work

System Integrity Protection is **enabled**, which is the intended tradeoff — no
scripting addition, no `sudo yabai --load-sa`. The cost is that everything
touching macOS Spaces is permanently unavailable:

- `hyper - 1` .. `hyper - 9` (send window to space N)
- `hyper - x` / `hyper - z` (send window to next/prev space)
- `cmd + alt - w` (destroy space)
- space creation/destruction generally

These lines are left in `skhdrc` deliberately, so they work if SIP is ever
partially disabled. Everything else — tiling, focus, swap, warp, resize, stack,
float, display focus — works fine with SIP on.

## Key bindings

`hyper` = caps_lock (via Karabiner) = cmd + ctrl + opt + shift.

| Binding | Action |
|---|---|
| `hyper - return` | new Alacritty window |
| `hyper - ←↓↑→` | focus window west/south/north/east |
| `hyper - a` / `s` | focus next / prev display |
| `hyper - e` / `d` | send window to prev / next display, follow focus |
| `hyper - w` / `q` | focus next / prev window in stack |
| `hyper - r` | focus next window |
| `hyper - h/j/k/l` | stack window west/south/north/east |
| `hyper - f` | toggle fullscreen zoom |
| `hyper - b` | toggle parent zoom |
| `hyper - t` | toggle float (centred 2x2 grid) |
| `hyper - u` | float and fill screen |
| `hyper - [` / `]` | float and fill left / right half |
| `hyper - o` | rotate tree 90° |
| `hyper - y` / `m` | mirror y-axis / x-axis |
| `hyper - i` | toggle padding and gaps |
| `hyper - p` | toggle picture-in-picture |
| `shift + alt - a/s/w/d` | swap window west/south/north/east |
| `shift + cmd - a/s/w/d` | warp window west/south/north/east |
| `shift + ctrl - a/s/w/d` | nudge floating window by 20px |
| `shift + ctrl + alt - a/s/w/d` | grow window |
| `shift + ctrl + cmd - a/s/w/d` | shrink window |
| `shift + alt - 0` | balance space |
| `shift + alt - f` | native fullscreen |
| `ctrl + alt - h/j/k/l` | set insertion point |
| `ctrl + alt - i` | insert as stack |
| `ctrl + alt - a` / `d` / `s` | layout bsp / float / toggle |
| `shift + cmd - 1/2/3` | focus display 1/2/3 |
| `hyper - f1..f9` | send window to space N without following (needs SIP off) |

## Troubleshooting

**All hotkeys silently dead, and skhd's log blames a different app each restart.**
Stuck Secure Input — some app grabbed the secure input flag and never released it.
Restarting skhd will not fix it; only a logout/login will.

```bash
ioreg -l -w 0 | grep SecureInput   # find the offending pid
```

**yabai is running but does nothing, and windows report empty AX role/subrole.**
That is a TCC race at login — yabai started before Accessibility permissions were
available. The grant is fine; just restart it:

```bash
launchctl kickstart -k "gui/$(id -u)/com.asmvik.yabai"
```

**Rules stopped applying after a yabai upgrade.** yabai v7 renamed the rule key
`layer` to `sub-layer`, and an unknown key makes yabai reject the entire rule
silently. `yabairc` is already updated for v7.

**Reload configs**

```bash
launchctl kickstart -k "gui/$(id -u)/com.asmvik.yabai"
launchctl kickstart -k "gui/$(id -u)/com.koekeishiya.skhd"
tmux source-file ~/.tmux.conf
```
