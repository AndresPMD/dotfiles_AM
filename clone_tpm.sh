#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if Git is installed
check_git_installed() {
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install Git and try again."
        exit 1
    fi
}

# Function to clone the TPM repository
clone_tpm_repo() {
    local repo_url="https://github.com/tmux-plugins/tpm"
    local clone_dir="$HOME/.tmux/plugins/tpm"

    if [ -d "$clone_dir" ]; then
        echo "Directory $clone_dir already exists. Skipping clone."
    else
        echo "Cloning TPM repository into $clone_dir..."
        git clone "$repo_url" "$clone_dir"
        echo "TPM repository cloned successfully."
    fi
}

# Main script execution
main() {
    check_git_installed
    clone_tpm_repo
}

# Invoke the main function
main
