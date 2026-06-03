#!/bin/bash
# Start the Docker daemon in the background, then SSH in the foreground.
# The container stays alive as long as sshd runs.
set -e

# Start dockerd (Docker-in-Docker). Output goes to a log inside the container.
# --storage-driver=vfs avoids the "overlay on overlay" problem that breaks
# image extraction when the host (e.g. Docker Desktop on WSL) is itself on an
# overlay filesystem. vfs is slower but works everywhere.
dockerd --storage-driver=vfs > /var/log/dockerd.log 2>&1 &

# Wait until the Docker daemon is responsive before accepting connections.
for i in $(seq 1 30); do
    if docker info >/dev/null 2>&1; then
        echo "Docker daemon is up."
        break
    fi
    echo "Waiting for Docker daemon... ($i)"
    sleep 1
done

# Run sshd in the foreground (PID 1 stays alive).
exec /usr/sbin/sshd -D -e
