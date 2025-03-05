#!/bin/bash

# Verificar las variables de entorno
VARIABLES=("USER" "GIT_USER" "GIT_EMAIL")

echo "🔍 Verificando variables de entorno..."

for VAR in "${VARIABLES[@]}"; do
    if [[ -z "${!VAR}" ]]; then
        echo "⚠️  $VAR no está definida. Ingresa un valor:"
        read -r VALUE
        export $VAR="$VALUE"
        echo "✅ $VAR establecida en '$VALUE'"
    else
        echo "✅ $VAR = ${!VAR}"
    fi
done

# Generar clave SSH
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "${GIT_EMAIL}" -q
SSH_PUB_KEY=$(cat "$HOME/.ssh/id_ed25519.pub")
VARIABLES+=("SSH_PUB_KEY")

# Mostrar todas las variables al final
echo -e "\n📌 **Resumen de Variables**"
for VAR in "${VARIABLES[@]}"; do
    echo "$VAR = ${!VAR}"
done

echo "🔄 Clonando el repositorio de dotfiles..."
git clone https://github.com/redia-gt/dotfiles $HOME/.dotfiles

# Reemplazar variables de entorno en los archivos .nix
echo "🔍 Buscando y reemplazando variables en archivos .nix..."

# Buscar archivos .nix en el directorio home-manager y reemplazar variables con envsubst
find "$HOME/.dotfiles/config/nixos" -type f -name "*.nix" | while read -r nixfile; do
    echo "💻 Procesando archivo: $nixfile"
    envsubst < "$nixfile" > "${nixfile}.tmp" && mv "${nixfile}.tmp" "$nixfile"
    echo "✅ Variables reemplazadas en: $nixfile"
done

echo "⚙️ Aplicando la configuración con Home Manager..."
home-manager switch --flake $HOME/.dotfiles/config/nixos -b bckp
