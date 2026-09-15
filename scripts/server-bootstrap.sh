#!/usr/bin/env sh
set -eu

APP_DIR="${APP_DIR:-/srv/apps/wordpress-bedrock-frankenphp}"

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This automated bootstrap currently supports Debian/Ubuntu servers only." >&2
  exit 1
fi

$SUDO apt-get update
$SUDO apt-get install -y ca-certificates curl git

if ! command -v docker >/dev/null 2>&1; then
  . /etc/os-release

  if [ "$ID" = "ubuntu" ]; then
    DOCKER_REPO_URL=https://download.docker.com/linux/ubuntu
    DOCKER_SUITE="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
  elif [ "$ID" = "debian" ]; then
    DOCKER_REPO_URL=https://download.docker.com/linux/debian
    DOCKER_SUITE="$VERSION_CODENAME"
  else
    echo "Unsupported distribution: $ID" >&2
    exit 1
  fi

  $SUDO install -m 0755 -d /etc/apt/keyrings
  $SUDO curl -fsSL "$DOCKER_REPO_URL/gpg" -o /etc/apt/keyrings/docker.asc
  $SUDO chmod a+r /etc/apt/keyrings/docker.asc

  printf '%s\n' \
    "Types: deb" \
    "URIs: $DOCKER_REPO_URL" \
    "Suites: $DOCKER_SUITE" \
    "Components: stable" \
    "Architectures: $(dpkg --print-architecture)" \
    "Signed-By: /etc/apt/keyrings/docker.asc" \
    | $SUDO tee /etc/apt/sources.list.d/docker.sources >/dev/null

  $SUDO apt-get update
  $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

$SUDO systemctl enable --now docker

if [ -n "${USER:-}" ] && [ "$(id -u)" -ne 0 ]; then
  $SUDO usermod -aG docker "$USER" || true
fi

$SUDO mkdir -p "$APP_DIR"
$SUDO chown -R "$(id -u):$(id -g)" "$APP_DIR"

printf '%s\n' "Server bootstrap complete. Docker and Compose are installed."
