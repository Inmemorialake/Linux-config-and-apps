#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# ─────────────────────────────────────────────────────────────
# Template de script estándar para Linux-config-and-apps
# ─────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────
# Auto-elevación (solo si se necesita root)
# ─────────────────────────────────────────────────────────────
# Descomentar si el script requiere permisos de root:
# if [[ $EUID -ne 0 ]]; then
#   exec sudo "$0" "$@"
# fi

# ─────────────────────────────────────────────────────────────
# Colores estandarizados
# ─────────────────────────────────────────────────────────────
readonly INFO="\033[1;36m"      # Cyan
readonly WARN="\033[1;33m"      # Amarillo
readonly ERROR="\033[1;31m"     # Rojo
readonly SUCCESS="\033[1;32m"   # Verde
readonly BOLD="\033[1m"
readonly RESET="\033[0m"

# ─────────────────────────────────────────────────────────────
# Variables globales
# ─────────────────────────────────────────────────────────────
readonly SCRIPT_NAME="$(basename "$0")"

# Variables específicas del script
DRY_RUN=false
AUTO_YES=false

# Si el script se ejecuta con sudo, preservar el usuario real:
# readonly REAL_USER="${SUDO_USER:-}"

# Si el script se auto-eleva con sudo Y además referencia $HOME/~ después de
# elevarse, usar esto en vez de $HOME: el env_reset de sudo hace que $HOME
# resuelva a /root, no al home del usuario real (esta es la clase de bug
# que tenía disk-cleanup):
# readonly REAL_HOME="$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)"

# ─────────────────────────────────────────────────────────────
# Funciones de logging
# ─────────────────────────────────────────────────────────────
info()    { echo -e "${INFO}ℹ️  [$SCRIPT_NAME]${RESET} $*"; }
warn()    { echo -e "${WARN}⚠️  [$SCRIPT_NAME]${RESET} $*"; }
error()   { echo -e "${ERROR}❌ [$SCRIPT_NAME]${RESET} $*" >&2; }
success() { echo -e "${SUCCESS}✔  [$SCRIPT_NAME]${RESET} $*"; }

# ─────────────────────────────────────────────────────────────
# Función header para títulos centrados
# ─────────────────────────────────────────────────────────────
header() {
  local title="$1"
  local emoji="${2:-}"
  local width=60
  
  echo -e "${BOLD}${INFO}"
  echo "//==========================================================//"
  
  local text="$emoji $title"
  local padding=$(( (width - ${#text}) / 2 ))
  printf "%${padding}s%s\n" "" "$text"
  
  echo "//==========================================================//"
  echo -e "${RESET}"
}

# ─────────────────────────────────────────────────────────────
# Función de ayuda
# ─────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Uso: $SCRIPT_NAME [opciones]

Descripción:
  Descripción breve de lo que hace el script

Opciones:
  --dry-run     Muestra qué se haría sin ejecutar cambios
  --yes         No pide confirmación
  -h, --help    Muestra esta ayuda

Ejemplos:
  $SCRIPT_NAME              # Ejecución normal con confirmación
  $SCRIPT_NAME --dry-run    # Ver qué se haría sin ejecutar
  $SCRIPT_NAME --yes        # Ejecución automática sin confirmación

EOF
}

# ─────────────────────────────────────────────────────────────
# Parse de argumentos
# ─────────────────────────────────────────────────────────────
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=true
        ;;
      --yes)
        AUTO_YES=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Opción desconocida: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# ─────────────────────────────────────────────────────────────
# Función principal del script
# ─────────────────────────────────────────────────────────────
main() {
  parse_args "$@"
  
  # Mostrar título
  header "Título del Script" "🚀"
  
  # Verificaciones previas
  if [[ "$DRY_RUN" == true ]]; then
    warn "Modo DRY-RUN activado: no se ejecutarán cambios"
  fi
  
  # Pedir confirmación si es necesario
  if [[ "$AUTO_YES" == false ]] && [[ "$DRY_RUN" == false ]]; then
    read -rp "¿Deseas continuar? [y/N]: " respuesta
    if [[ ! "$respuesta" =~ ^[Yy]$ ]]; then
      warn "Operación cancelada por el usuario"
      exit 0
    fi
  fi
  
  echo
  
  # ===== Lógica del script aquí =====
  info "Iniciando proceso..."
  
  # Ejemplo de ejecución condicional
  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY-RUN] Comando que se ejecutaría"
  else
    info "Ejecutando comando..."
    # Comando real aquí
  fi
  
  echo
  
  # Mensaje de finalización
  success "$SCRIPT_NAME finalizado correctamente"
}

# ─────────────────────────────────────────────────────────────
# Ejecutar función principal
# ─────────────────────────────────────────────────────────────
main "$@"
