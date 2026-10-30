#!/bin/bash
# GPU + VRAM for the tmux status bar. Prints nothing when the GPU can't be
# queried — nvidia-smi writes "Failed to initialize NVML: ..." to stdout, not
# stderr, so 2>/dev/null alone would leak it into the status line.
out=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total \
        --format=csv,noheader,nounits 2>/dev/null | head -1) || exit 0
IFS=', ' read -r util used total <<<"$out"
[[ $util =~ ^[0-9]+$ && $used =~ ^[0-9]+$ && $total =~ ^[0-9]+$ && $total -gt 0 ]] || exit 0
printf 'GPU:%d%% VRAM:%d%% ' "$util" "$((used * 100 / total))"
