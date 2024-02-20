#!/bin/sh
set -ex
cd "$(dirname "$0")"

. ./.env

docker rm -f reticulum reticulum-vscode

mkdir -p "$RETICULUM_STORAGE_DIR"

if [ "$1" = "prod" ]; then
    sudo mount -t nfs $STORAGE_NAS_LOCATION $RETICULUM_STORAGE_DIR
    #마운트 정보 유지 설정(fstab 설정)
    echo "$STORAGE_NAS_LOCATION $RETICULUM_STORAGE_DIR nfs ,defaults 0 0" | sudo tee -a /etc/fstab
fi

docker run --log-opt max-size=10m --log-opt max-file=3 -d --restart=always --name reticulum \
    -w /app/reticulum \
    -p 4000:4000 \
    -v $RETICULUM_STORAGE_DIR/dev:/app/reticulum/storage/dev \
    -v $(pwd)/dev.exs:/app/reticulum/config/dev.exs \
    -v $(pwd)/runtime.exs:/app/reticulum/config/runtime.exs \
    -v $SSL_CERT_FILE:/app/reticulum/certs/cert.pem \
    -v $SSL_KEY_FILE:/app/reticulum/certs/key.pem \
    -e PERMS_KEY="$(cat $PERMS_PRV_FILE)" \
    -e DB_HOST="$DB_HOST" \
    -e DB_USER="$DB_USER" \
    -e DB_PASSWORD="$DB_PASSWORD" \
    -e DIALOG_HOSTNAME="$DIALOG_HOSTNAME" \
    -e DIALOG_PORT="$DIALOG_PORT" \
    -e HUBS_ADMIN_INTERNAL_HOSTNAME="$HUBS_ADMIN_INTERNAL_HOSTNAME" \
    -e HUBS_CLIENT_INTERNAL_HOSTNAME="$HUBS_CLIENT_INTERNAL_HOSTNAME" \
    -e SPOKE_INTERNAL_HOSTNAME="$SPOKE_INTERNAL_HOSTNAME" \
    -e POSTGREST_INTERNAL_HOSTNAME="$POSTGREST_INTERNAL_HOSTNAME" \
    reticulum sh -c "mix phx.server"
