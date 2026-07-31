# dotfiles

Dotfiles de Ezequiel gestionados con [chezmoi](https://www.chezmoi.io/).
Funcionan en **macOS**, **Linux** y **Windows (WSL)** desde un único repo.

## Instalación en una máquina nueva

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply efburgos
```

Eso hace todo: instala chezmoi, clona este repo, te pregunta nombre/email para git
(solo la primera vez), instala los paquetes del sistema, mise + herramientas DevOps,
y enlaza todos los dotfiles.

Alternativa si ya tenés el repo clonado:

```sh
./install.sh
```

## Uso diario

| Comando | Qué hace |
|---|---|
| `chezmoi edit ~/.zshrc` | Edita el archivo *fuente* del dotfile |
| `chezmoi apply` | Aplica los cambios a tu `$HOME` |
| `chezmoi diff` | Muestra qué cambiaría antes de aplicar |
| `chezmoi update` | `git pull` + apply (sincroniza otra máquina) |
| `chezmoi cd` | Te lleva al repo fuente |
| `chezmoi add ~/.algo` | Empieza a gestionar un archivo existente |

## Estructura

```
.chezmoi.toml.tmpl          → config inicial (pregunta nombre/email una sola vez)
.chezmoidata/packages.yaml  → TODO el software declarado en un solo lugar
.chezmoiscripts/            → scripts de instalación (corren solos con chezmoi apply)
    run_once_before_10-packages.sh.tmpl   → brew (Mac) / apt (Linux, WSL)
    run_once_after_20-devops-tools.sh.tmpl → mise: terraform, terragrunt, kubectl…
    run_once_after_30-shell.sh.tmpl        → antidote (plugins zsh) + starship
dot_zshrc                   → ~/.zshrc (zsh + antidote + starship + mise)
dot_zsh_plugins.txt         → ~/.zsh_plugins.txt (lista de plugins de antidote)
dot_aliases                 → ~/.aliases
dot_gitconfig.tmpl          → ~/.gitconfig (tu nombre/email vía template)
dot_git_global_ignore       → ~/.git_global_ignore
dot_config/starship.toml    → prompt (contextos de aws/gcloud/azure/k8s/terraform)
dot_config/mise/config.toml → versiones globales de herramientas DevOps
dot_local/bin/              → scripts útiles (massive-clone, massive-pull)
```

### Cómo mapea al fork viejo (alombarte/dotfiles)

| Fork viejo | Acá |
|---|---|
| `stow term git ...` (symlinks) | `chezmoi apply` (copia gestionada, funciona en Windows) |
| `mac-brew.txt`, `linux-apt.txt`, `linux-snap.txt` | `.chezmoidata/packages.yaml` |
| `packages/install.sh` + `packages/{Darwin,Linux}/*.sh` | `.chezmoiscripts/run_once_*` |
| oh-my-zsh + powerlevel9k | antidote + starship |
| `.gitconfig` con datos de Albert hardcodeados | `dot_gitconfig.tmpl` con tus datos |
| `utils/massive_clone.sh`, `massive_pull.sh` | `dot_local/bin/` (en el PATH) |
| Travis CI + shellcheck | GitHub Actions + shellcheck |

### Qué NO se migró (a propósito)

- Temas de GNOME, tilix, terminator, dropbox, aliases de KrakenD, backup a S3 de Albert,
  config de nvim de Albert. Si necesitás algo de eso, está en el fork viejo.
- GPG signing de commits: desactivado por defecto. Cuando tengas tu clave,
  descomentá la sección `[commit]` en `dot_gitconfig.tmpl`.

## Herramientas DevOps (mise)

Las versiones de `terraform`, `terragrunt`, `kubectl`, `helm`, `k9s`, etc. se gestionan
con [mise](https://mise.jdx.dev/) (reemplaza tfenv/tgenv/asdf). Global en
`~/.config/mise/config.toml`; por proyecto, un `mise.toml` o `.terraform-version`
en el repo del proyecto pinnea la versión.

Los CLIs de cloud (awscli, azure-cli, gcloud, oci) se instalan como paquetes del
sistema — ver `packages.yaml`.

## Windows

El uso principal es **WSL**: dentro de WSL esto se comporta como Linux normal
(misma instalación de arriba). Los scripts detectan WSL y saltean lo que no aplica
(apps de escritorio). Si algún día querés Windows nativo, chezmoi lo soporta:
se agrega una rama `{{ if eq .chezmoi.os "windows" }}` en los templates y
paquetes vía `winget`.

## Máquinas con perfiles distintos (trabajo/personal)

chezmoi permite variar config por máquina con templates. Ejemplo típico:
email de trabajo en la laptop del trabajo — se agrega un prompt más en
`.chezmoi.toml.tmpl` y se usa la variable en `dot_gitconfig.tmpl`.
