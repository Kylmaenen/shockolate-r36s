#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
echo "Running ARM64 build script inside container"
apt-get update
apt-get install -y cmake build-essential zip libsdl2-dev libsdl2-mixer-dev libfluidsynth-dev libasound2-dev pkg-config
rm -rf /work/systemshock/build || true
cmake -S /work/systemshock -B /work/systemshock/build -DENABLE_SDL2=ON -DENABLE_SOUND=ON -DENABLE_FLUIDSYNTH=ON
make -C /work/systemshock/build -j$(nproc)
if [ -f /work/systemshock/build/systemshock ]; then
  mkdir -p /work/artifact/bin /work/artifact/data
  cp /work/systemshock/build/systemshock /work/artifact/bin/
  if [ -f /work/systemshock/README_PORTMASTER.md ]; then
    cp /work/systemshock/README_PORTMASTER.md /work/artifact/
  fi
  cd /work/artifact && zip -r /work/shockolate-arm64.zip .
else
  echo "Build did not produce /work/systemshock/build/systemshock" >&2
  ls -la /work/systemshock/build || true
  exit 2
fi
