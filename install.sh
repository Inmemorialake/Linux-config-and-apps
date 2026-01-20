#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_DIR/bin"
DST="$HOME/.local/bin"

echo "🔧 Installing scripts from repo"
echo "Source: $SRC"
echo "Target: $DST"
echo

mkdir -p "$DST"

for dir in sys pkg keyring log systemd btrfs disk; do
  mkdir -p "$DST/$dir"
done

find "$SRC" -type f | while read -r file; do
  rel="${file#$SRC/}"
  target="$DST/$rel"

  echo "→ $rel"
  chmod +x "$file"
  ln -sf "$file" "$target"
done

echo
echo "✔ Installation completed"

