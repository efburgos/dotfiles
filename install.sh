#!/bin/sh
# Bootstrap: instala chezmoi si falta y aplica este repo como fuente.
# Uso: ./install.sh   (desde el clon del repo)
set -e

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Instalando chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
chezmoi init --apply --source="$SCRIPT_DIR"
