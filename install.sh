#!/bin/bash

set -eo pipefail  # Detiene el script si hay errores

# 🚀 Definir variables
REPO_URL="https://github.com/redia-gt/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"
HOME_MANAGER_DIR="$DOTFILES_DIR/home-manager"
# 📌 Verificar variables de entorno
VARIABLES=("USER" "GIT_USER" "GIT_EMAIL")

if [[ ! -d "$DOTFILES_DIR" ]]; then
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Leer variables si no existen
for VAR in "${VARIABLES[@]}"; do
    if [[ -z "${!VAR}" ]]; then
        read -r -p "Por favor ingresa el valor de ${VAR}: " VALUE
        export "${VAR}"="${VALUE}"
    fi
done

# 🔐 Generar clave SSH si no existe
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "${GIT_EMAIL}" -q
fi

# Agregar la public key
VARIABLES+=("SSH_PUB_KEY")
export SSH_PUB_KEY=$(cat "$HOME/.ssh/id_ed25519.pub")


# 📌 Sustituir `$USER` en `flake.nix` y `home.nix` con envsubst
if [[ -s "$HOME_MANAGER_DIR/flake.nix" ]]; then
    # Sobrescribir el archivo original
    echo "$(envsubst < "$HOME_MANAGER_DIR/flake.nix")" > "$HOME_MANAGER_DIR/flake.nix"
fi

# -----------------------------------------------------------

if [[ -s "$HOME_MANAGER_DIR/home.nix" ]]; then
    # Generar un nuevo archivo con las variables sustituidas
    echo "$(envsubst < "$HOME_MANAGER_DIR/home.nix")" > "$HOME_MANAGER_DIR/home.nix"
fi
