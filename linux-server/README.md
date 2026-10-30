# Linux server tmux

Separate from the macOS `tmux.conf` at the repo root. GPU and VRAM share one script here.

```bash
ln -sf "$PWD/tmux.conf" ~/.tmux.conf
mkdir -p ~/.local/bin && ln -sf "$PWD/tmux-gpu.sh" ~/.local/bin/tmux-gpu.sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then start tmux and press `prefix` + `I`. Prefix is `C-s`.
