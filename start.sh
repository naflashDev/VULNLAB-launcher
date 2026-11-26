#!/usr/bin/env bash
# Descripcion: Lanzador del laboratorio en Linux/macOS. Genera el .env segun el
# modo elegido (local/shared), descarga la imagen de Docker Hub y la arranca.
# Uso: ./start.sh [local|shared]
# Autor: @naflashdev

set -euo pipefail
cd "$(dirname "$0")"

# genera_token: devuelve una cadena aleatoria hexadecimal de 32 caracteres
genera_token() {
  head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n'
}

MODO="${1:-}"
# Si no se pasa por argumento, preguntamos al usuario
if [[ -z "$MODO" ]]; then
  echo "Modo del laboratorio:"
  echo "  1) local  - solo en este equipo (alumnos)"
  echo "  2) shared - accesible desde la red del aula (profesor)"
  read -rp "Elige [1/2]: " opcion
  [[ "$opcion" == "2" ]] && MODO="shared" || MODO="local"
fi

if [[ "$MODO" != "local" && "$MODO" != "shared" ]]; then
  echo "Modo no valido: $MODO (usa local o shared)" >&2
  exit 1
fi

# Valores por modo: en shared se escucha en toda la red y se generan secretos
if [[ "$MODO" == "shared" ]]; then
  BIND="0.0.0.0"
  TOKEN="$(genera_token)"
  SECRET="$(genera_token)"
else
  BIND="127.0.0.1"
  TOKEN="profesor-local"
  SECRET=""
fi

cat > .env <<EOF
LAB_MODE=$MODO
BIND_ADDR=$BIND
PORT=${PORT:-8800}
TEACHER_TOKEN=$TOKEN
FLAG_SECRET=$SECRET
DISABLE_CHALLENGES=
LAB_VERSION=${LAB_VERSION:-latest}
EOF

docker compose pull
docker compose up -d

echo ""
echo "Bastion Seguridad en marcha (modo $MODO)"
echo "  URL:            http://localhost:${PORT:-8800}"
if [[ "$MODO" == "shared" ]]; then
  echo "  Token profesor: $TOKEN   (panel en /profesor)"
  echo "  Comparte con los alumnos la IP de este equipo y el puerto ${PORT:-8800}."
fi
