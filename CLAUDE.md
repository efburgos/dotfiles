# CLAUDE.md

Guía para trabajar con Claude Code en este repo.

## Qué es este repo

Dotfiles de Ezequiel gestionados con [chezmoi](https://www.chezmoi.io/). Un solo repo para macOS, Linux y Windows (WSL). Reemplaza un fork viejo de `alombarte/dotfiles` (stow + make + oh-my-zsh) — no reintroducir patrones de ese fork.

Remote: `https://github.com/efburgos/dotfiles`, branch `master`.

## Convenciones de chezmoi (importante)

Los nombres de archivo en el repo son *source state* de chezmoi, no los nombres finales:

- `dot_zshrc` → `~/.zshrc`; `dot_config/starship.toml` → `~/.config/starship.toml`
- Sufijo `.tmpl` → se renderiza como Go template con las variables de `[data]` (definidas en `.chezmoi.toml.tmpl`: `name`, `email`, `wsl`) y los datos de `.chezmoidata/`
- Prefijo `executable_` → archivo con permiso de ejecución (ej: `dot_local/bin/executable_massive-clone`)
- `.chezmoiscripts/run_once_*` → scripts que chezmoi ejecuta en `chezmoi apply`, solo cuando cambia su contenido renderizado. Cambiar `packages.yaml` re-dispara los scripts que lo usan — es el comportamiento deseado.
- `.chezmoiignore` → archivos del repo que NO se copian a `$HOME` (README, install.sh, este archivo, etc.). Todo archivo nuevo de "repo" (docs, CI, tooling) que no sea un dotfile debe agregarse ahí.

## Arquitectura de decisiones (no revertir sin preguntar)

- **Software declarado en un solo lugar**: `.chezmoidata/packages.yaml`. Refleja la máquina real auditada (brew list + /Applications + npm -g, 2026-07-31) — no reemplazar por listas genéricas.
- **mise SOLO para terraform / terragrunt / opentofu** (reemplaza tfenv/tgenv; respeta `.terraform-version` / `.terragrunt-version` por proyecto). kubectl, helm, kustomize, k9s, kubecm, flux y los CLIs de cloud van por brew.
- **Shell**: zsh + antidote (plugins, en `dot_zsh_plugins.txt`) + starship. Nada de oh-my-zsh.
- **Casks con `--adopt`**: apps que ya estaban en /Applications instaladas a mano; brew las adopta sin reinstalar.
- **Windows = WSL**: los scripts detectan WSL vía la variable `wsl` y saltean lo de escritorio. No agregar soporte Windows nativo salvo pedido explícito.

## Flujo de trabajo

- Editar siempre los archivos *fuente* del repo (ej: `dot_zshrc`), nunca los archivos aplicados en `$HOME`.
- Para agregar software: editar `packages.yaml` (sección que corresponda: brews/casks/apt/mise/npm_global); los scripts se re-ejecutan solos en el próximo `chezmoi apply`.
- Los scripts de `.chezmoiscripts/` deben ser idempotentes y con `set -euo pipefail`.
- Probar cambios: `chezmoi diff` antes de `chezmoi apply` (los corre el usuario en su Mac, no automatizar apply).

## CI

GitHub Actions (`.github/workflows/ci.yml`) corre shellcheck sobre `install.sh`, `dot_local/bin/executable_*` y los `.sh.tmpl` (quitando las líneas `{{ ... }}` y validando el bash restante). Todo script nuevo debe pasar shellcheck.

## Gotchas del entorno

- Si Claude corre git en la carpeta montada (Cowork cloud), pueden quedar `.git/index.lock` u objetos temporales que la VM no puede borrar: moverlos a `_to_delete/` y avisar al usuario para que los borre con `rm -f`.
- `_to_delete/` no es parte del repo; ignorarlo.
