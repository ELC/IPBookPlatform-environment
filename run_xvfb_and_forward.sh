#!/bin/bash
set -e


# Start Xvfb in the background
Xvfb :1 -screen 0 1024x768x16 &
export USER=ubuntu
export DISPLAY=:1
export OCTAVE_EXECUTABLE="$(command -v octave)"

# Wait a bit to ensure Xvfb is fully started
sleep 2

# Execute the command provided to the container
exec "$@" 2>&1 | tee .jupyter-server-log.txt
