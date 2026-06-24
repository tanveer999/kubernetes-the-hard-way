#!/usr/bin/env bash

set -euo pipefail
#-e: Exits immediately if any command returns a non-zero (error) status.
#-u: Treats unset variables as an error and exits immediately.
#-o pipefail: Ensures that if a command in a pipeline fails (e.g., command_a | command_b), the whole pipeline returns a failure code, rather than just the last command.

VAGRANT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../vagrant" && pwd)"

# Static lab IPs from the Vagrantfile.
declare -A NODE_IPS=(
  [server]=10.240.0.10
  [node-0]=10.240.0.20
  [node-1]=10.240.0.21
)

# Check every VM against every other VM.
NODES=(server node-0 node-1)

for node in "${NODES[@]}"; do
  echo "== ${node}: OS =="
  (
    cd "$VAGRANT_DIR"
    # Confirm the guest OS matches the expected base image.
    vagrant ssh "$node" -c 'grep "^PRETTY_NAME=" /etc/os-release'
  )

  echo "== ${node}: connectivity =="
  for peer in "${NODES[@]}"; do
    [[ "$node" == "$peer" ]] && continue
    (
      cd "$VAGRANT_DIR"
      # Use TCP port 22 as the reachability check when ICMP is blocked.
      vagrant ssh "$node" -c "nc -zvw2 ${NODE_IPS[$peer]} 22"
    )
  done
done
