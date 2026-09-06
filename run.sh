#!/bin/sh
set -euo pipefail

# run.sh — build and run the Calculator service and client examples
# Usage: ./run.sh [X] [Y]
# Defaults: X=6, Y=7

X=${1:-6}
Y=${2:-7}

# Build (try pkg-config, fall back to -lsystemd)
echo "Building bus-service and bus-client..."
if command -v pkg-config >/dev/null 2>&1; then
  CFLAGS=$(pkg-config --cflags libsystemd 2>/dev/null || true)
  LDFLAGS=$(pkg-config --libs libsystemd 2>/dev/null || true)
else
  CFLAGS=""
  LDFLAGS="-lsystemd"
fi

gcc $CFLAGS bus-service.c -o bus-service $LDFLAGS
gcc $CFLAGS bus-client.c -o bus-client $LDFLAGS

# Start server in background
echo "Starting bus-service..."
./bus-service &
BS_PID=$!
sleep 0.1

# Wait for the service to register on the session bus
echo "Waiting for net.poettering.Calculator to register on the session bus..."
MAX_WAIT=10
i=0
owner=""
while [ $i -lt $MAX_WAIT ]; do
  owner=$(dbus-send --session --dest=org.freedesktop.DBus --print-reply / \
    org.freedesktop.DBus.GetNameOwner string:net.poettering.Calculator 2>/dev/null | awk -F\" '/string/ {print $2}' || true)
  if [ -n "$owner" ]; then
    echo "Service registered as $owner"
    break
  fi
  i=$((i+1))
  sleep 0.5
done

if [ -z "$owner" ]; then
  echo "Timed out waiting for service registration; killing server (PID $BS_PID)" >&2
  kill "$BS_PID" 2>/dev/null || true
  exit 1
fi

# Run client
echo "Running bus-client $X $Y"
./bus-client "$X" "$Y"
RC=$?

# Stop server started by this script
echo "Stopping server (PID $BS_PID)"
kill "$BS_PID" 2>/dev/null || true
wait "$BS_PID" 2>/dev/null || true

exit $RC
