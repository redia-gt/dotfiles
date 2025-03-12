#!/bin/bash

set -eo pipefail  # Detiene el script si hay errores

sudo apt update && sudo apt install -y \
    gettext-base uidmap xz-utils

# 🚀 Definir variables
REPO_URL="https://github.com/redia-gt/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"
HOME_MANAGER_DIR="$DOTFILES_DIR/home-manager"
OUTPUT_DIR="$HOME/.config/home-manager"

mkdir -p $OUTPUT_DIR

# 📌 Verificar variables de entorno
VARIABLES=("USER" "GIT_USER" "GIT_EMAIL")

if [[ ! -d "$DOTFILES_DIR" ]]; then
    read -r -p "El repositorio ya esxite. Actualizando..."
    git -C "$DOTFILES_DIR" fetch origin
    git -C "$DOTFILES_DIR" reset --hard origin/main
    git -C "$DOTFILES_DIR" pull
else
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

export SSH_PUB_KEY=$(cat "$HOME/.ssh/id_ed25519.pub")
envsubst < "$HOME_MANAGER_DIR/flake.nix" > "$OUTPUT_DIR/flake.nix"
envsubst < "$HOME_MANAGER_DIR/home.nix" > "$OUTPUT_DIR/home.nix"

# 📂 Respaldar archivos conflictivos si existen
[[ -f ~/.bashrc ]] && mv ~/.bashrc ~/.bashrc.backup
[[ -f ~/.profile ]] && mv ~/.profile ~/.profile.backup

# 🚀 Instalar y ejecutar Home Manager
if ! command -v home-manager &> /dev/null; then
    nix run home-manager/master -- switch
fi

# 🛠️ Aplicar configuración de Home Manager
home-manager switch -b backup || { echo "❌ Error ejecutando home-manager"; exit 1; }
