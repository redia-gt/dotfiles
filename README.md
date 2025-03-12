# DOCUMENTOS ONBOARDING

## Instalación de la herramienta NIX y home manager
<a href="https://redia-gt.atlassian.net/wiki/spaces/~71202015ad3a939b8d474896889eecf90fdcc2/pages/1245185/Instalaci+n+de+Nix" target="_blank" rel="noopener noreferrer">Enlace al tutorial</a>

## SCRIPT DE INSTALACIÓN DE HOME MANAGER
```bash
bash -c "$(curl -sL https://redia-gt.github.io/dotfiles/install.sh)"
```
## Posibles Errores

Solución a posible error de ejecución de vscode en ubuntu 24

```bash
echo "kernel.apparmor_restrict_unprivileged_userns=0" | sudo tee /etc/sysctl.d/60-apparmor-namespace.conf > /dev/null

```
