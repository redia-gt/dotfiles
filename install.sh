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
    echo "✅ curl instalado correctamente."
fi

# 📌 Definir usuario actual
USER_NAME=$(whoami)
export USER="$USER_NAME"  # Asegurar que envsubst pueda reemplazarlo
echo "👤 Usuario detectado: $USER_NAME"

# 📌 Verificar variables de entorno
VARIABLES=("USER" "GIT_USER" "GIT_EMAIL")

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
VARIABLES+=("SSH_PUB_KEY")

# 📌 Mostrar todas las variables
echo -e "\n📌 **Resumen de Variables**"
for VAR in "${VARIABLES[@]}"; do
    echo "$VAR = ${!VAR}"
done

# 📌 Clonar repositorio de dotfiles
echo "🔄 Clonando dotfiles..."
if [[ ! -d "$DOTFILES_DIR" ]]; then
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "✅ Dotfiles ya clonados en $DOTFILES_DIR."
fi

# 📌 Sustituir `$USER` en `flake.nix` y generar `flake.generated.nix`
echo "🔧 Configurando flake.nix..."
envsubst < "$HOME_MANAGER_DIR/flake.nix" > "$HOME_MANAGER_DIR/flake.generated.nix"
echo "✅ flake.generated.nix creado con usuario: $USER_NAME"

# 📌 Descargar `home.nix` y aplicar `envsubst`
echo "🔄 Descargando home.nix..."
mkdir -p ~/.config/home-manager
curl -sL "https://raw.githubusercontent.com/redia-gt/dotfiles/main/home-manager/home.nix" | envsubst > "$HOME/.config/home-manager/home.nix"

if [[ -f "$HOME/.config/home-manager/home.nix" ]]; then
    echo "✅ home.nix descargado correctamente."
else
    echo "❌ Error al descargar home.nix. Verifica la URL y tu conexión a internet."
    exit 1
fi

# 🚀 Ejecutar Home Manager usando `flake.generated.nix`
echo "🚀 Ejecutando Home Manager..."
nix flake update "$HOME_MANAGER_DIR"
nix build "$HOME_MANAGER_DIR#homeConfigurations.$USER.activationPackage"
home-manager switch --flake "$HOME_MANAGER_DIR/flake.generated.nix#$USER"

echo "✅ Instalación completada con éxito."
