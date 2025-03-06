#!/bin/bash

# Verificar si curl está instalado, si no, instalarlo
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

# Comprobar la versión de curl
echo "🔍 Verificando versión de curl..."
curl --version

# Verificar si Nix está instalado
if ! command -v nix &> /dev/null; then
    echo "⚠️ Nix no está instalado. Por favor, instálalo manualmente y reinicia la terminal antes de ejecutar este script."
    exit 1
fi

# Comprobar la versión de Nix
echo "🔍 Verificando versión de Nix..."
nix --version

# Habilitar características experimentales de Nix
echo "⚙️ Configurando características experimentales de Nix..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
echo "✅ Características experimentales habilitadas."

# Verificar las variables de entorno
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

# Generar clave SSH si no existe
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "${GIT_EMAIL}" -q
    echo "✅ Clave SSH generada."
else
    echo "✅ Clave SSH ya existe."
fi

SSH_PUB_KEY=$(cat "$HOME/.ssh/id_ed25519.pub")
VARIABLES+=("SSH_PUB_KEY")

# Mostrar todas las variables al final
echo -e "\n📌 **Resumen de Variables**"
for VAR in "${VARIABLES[@]}"; do
    echo "$VAR = ${!VAR}"
done

# Descargar el archivo home.nix
echo "🔄 Descargando home.nix..."
mkdir -p ~/.config/home-manager
curl -sL "https://raw.githubusercontent.com/redia-gt/dotfiles/refs/heads/main/home-manager/home.nix" | \
envsubst > "$HOME/.config/home-manager/home.nix"

if [[ -f "$HOME/.config/home-manager/home.nix" ]]; then
    echo "✅ home.nix descargado correctamente."
else
    echo "❌ Error al descargar home.nix. Verifica la URL y tu conexión a internet."
    exit 1
fi

# Ejecutar Home Manager
echo "🚀 Ejecutando Home Manager..."
nix shell nixpkgs#home-manager nixpkgs#git --command home-manager switch --flake "$HOME/.dotfiles/home-manager#home"
