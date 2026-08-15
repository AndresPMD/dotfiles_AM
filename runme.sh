#!/usr/bin/env bash
# Kept for muscle memory — install.sh is the real entry point now.
# (The old version hardcoded $HOME/dotfiles_AM; install.sh is path-relative,
#  so the clone directory can be named anything.)
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh" "$@"
