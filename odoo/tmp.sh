#!/bin/bash

# 設定來源與目的地路徑
SOURCE_COMPOSE="./compose.yaml"
DEST_DIR="./docker"
DEST_COMPOSE="$DEST_DIR/compose.yaml"
PASSWORD_FILE="$DEST_DIR/odoo_pg_pass"
ENV_FILE="$DEST_DIR/.env"

# 檢查來源檔案是否存在
if [ ! -f "$SOURCE_COMPOSE" ]; then
  echo "找不到 compose.yaml 檔案，請確認路徑是否正確。"
  exit 1
fi

# 建立目的地資料夾（如果不存在）
if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
    echo "資料夾不存在，已建立：$DEST_DIR"
fi

# 複製 compose.yaml 到 docker 資料夾
cp "$SOURCE_COMPOSE" "$DEST_COMPOSE"
echo "已複製 compose.yaml 到 $DEST_COMPOSE"

# 向使用者詢問密碼
read -s -p "請輸入密碼（將儲存到 odoo_pg_pass）： " USER_PASS
echo
echo "$USER_PASS" > "$PASSWORD_FILE"
echo "密碼已儲存到 $PASSWORD_FILE"

# 建立 .env 檔案供 docker-compose 使用
echo "POSTGRES_PASSWORD=$USER_PASS" > "$ENV_FILE"
echo ".env 檔案已建立：$ENV_FILE"

# 進入 docker 資料夾並重建容器
cd "$DEST_DIR" || exit
docker-compose down -v
docker-compose up -d --build