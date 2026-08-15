# ── Homebrew ──────────────────────────────────────────────────────────────────
# Apple Silicon
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel Mac
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Disable auto-setting terminal title (prevents overriding tmux window names)
DISABLE_AUTO_TITLE="true"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting colored-man-pages command-not-found)

source "$ZSH/oh-my-zsh.sh"

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="${HOME}/.cache/npm/global/bin:$PATH"

# uv env file (only present when uv was installed via curl installer, not Homebrew)
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# ── Terminal ──────────────────────────────────────────────────────────────────
export TERM=xterm-256color

# ── Secrets (tokens, keys) ────────────────────────────────────────────────────
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh

# ── Aliases ───────────────────────────────────────────────────────────────────
alias lg="lazygit"

# ── Auto-activate/deactivate .venv on directory change ────────────────────────
_auto_venv() {
  if [[ -f "$PWD/.venv/bin/activate" ]]; then
    if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
      [[ -n "$VIRTUAL_ENV" ]] && deactivate 2>/dev/null
      source "$PWD/.venv/bin/activate"
    fi
  else
    if [[ -n "$VIRTUAL_ENV" ]]; then
      local venv_project="${VIRTUAL_ENV%/.venv}"
      if [[ "$PWD" != "$venv_project" && "$PWD" != "$venv_project"/* ]]; then
        deactivate 2>/dev/null
      fi
    fi
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _auto_venv
_auto_venv

# ── Misc ──────────────────────────────────────────────────────────────────────
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
