#!/bin/bash
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | awk -F', ' '{printf "%.0f", ($1/$2)*100}'