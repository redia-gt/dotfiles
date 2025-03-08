#!/bin/bash

set -e  # Detiene el script si hay errores

# 🚀 Definir variables
REPO_URL="https://github.com/redia-gt/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"
HOME_MANAGER_DIR="$DOTFILES_DIR/home-manager"

# 📌 Verificar si curl está instalado, si no, instalarlo
if ! command -v curl &> /dev/null; then
    echo "⚠️ curl no está instalado. Instalando..."
    sudo apt update && sudo apt install -y curl
    if ! command -v curl &> /dev/null; then
        echo "❌ No se pudo instalar curl. Asegúrate de tener permisos de sudo."
        exit 1
    fi
    echo "✅ curl instalado correctamente."
else
    echo "✅ curl ya está instalado."
fi

# 🔍 Verificar si Nix está instalado
if ! command -v nix &> /dev/null; then
    echo "⚠️ Nix no está instalado. Instalándolo..."
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# 📌 Configurar características experimentales de Nix
echo "⚙️ Configurando Nix con flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
echo "✅ Configuración de Nix completada."

# 📌 Definir usuario actual
USER_NAME=$(whoami)
echo "👤 Usuario detectado: $USER_NAME"

# 📌 Variables necesarias
VARIABLES=("USER_NAME" "GIT_USER" "GIT_EMAIL")

echo "🔍 Verificando variables de entorno..."

for VAR in "${VARIABLES[@]}"; do
    if [[ -z "${!VAR}" ]]; then
        echo "⚠️ $VAR no está definida. Ingresa un valor:"
        read -r VALUE
        export $VAR="$VALUE"
        echo "✅ $VAR establecida en '$VALUE'"
    else
        echo "✅ $VAR = ${!VAR}"
    fi
done

# 🔐 Generar clave SSH si no existe
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "$GIT_EMAIL" -q
    echo "✅ Clave SSH generada."
else
    echo "✅ Clave SSH ya existe."
fi

export SSH_PUB_KEY=$(cat "$HOME/.ssh/id_ed25519.pub")

# 📌 Clonar repositorio de dotfiles
echo "🔄 Clonando dotfiles..."
if [[ ! -d "$DOTFILES_DIR" ]]; then
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "✅ Dotfiles ya clonados en $DOTFILES_DIR."
fi

# 📌 Reemplazar "DEFAULT_USER" en flake.nix con el usuario real
echo "🔧 Configurando flake.nix..."
sed -i "s/DEFAULT_USER/$USER_NAME/g" "$HOME_MANAGER_DIR/flake.nix"

# 📌 Descargar `home.nix`
echo "🔄 Descargando home.nix..."
mkdir -p ~/.config/home-manager
curl -sL "$REPO_URL/refs/heads/main/home-manager/home.nix" | envsubst > "$HOME/.config/home-manager/home.nix"

if [[ -f "$HOME/.config/home-manager/home.nix" ]]; then
    echo "✅ home.nix descargado correctamente."
else
    echo "❌ Error al descargar home.nix. Verifica la URL y tu conexión a internet."
    exit 1
fi

# 🚀 Ejecutar Home Manager
echo "🚀 Ejecutando Home Manager..."
nix shell nixpkgs#home-manager nixpkgs#git --command home-manager switch --flake "$HOME_MANAGER_DIR#$USER_NAME"

echo "✅ Instalación completada con éxito."
