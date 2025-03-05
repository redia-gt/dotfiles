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

curl -sL "https://raw.githubusercontent.com/redia-gt/dotfiles/refs/heads/main/home-manager/home.nix" | \
envsubst > "$HOME/.config/home-manager/home.nix"
