#!/bin/bash
set -e

Xvfb ${DISPLAY} -screen 0 1024x768x16 &

exec "$@" 2>&1 | tee .jupyter-server-log.txt
